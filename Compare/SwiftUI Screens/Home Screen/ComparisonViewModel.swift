//
//  CompareViewModel2.swift
//  Compare
//
//  Created by Aanchal Patial on 04/07/24.
//

import UIKit
import SwiftUI
import Lottie

// MARK: - ViewModel
final class ComparisonViewModel: ObservableObject {

    @Published var inputType: InputType = UserDefaults.standard.bool(forKey: UserDefaults.Keys.inputTypeSwitch.rawValue) ? .text : .image
    @Published var firstKeyword: String = ""
    @Published var secondKeyword: String = ""
    @Published var firstImage: UIImage?
    @Published var secondImage: UIImage?
    @Published var question: String = ""
    @Published var criteriaList = [String]()
    @Published var criteria: String = ""
    @Published var playbackMode: LottiePlaybackMode = .paused(at: .currentFrame)
    @Published var resultSaved = false
    @Published var comparisonResult: ComparisonResult?
    @Published var presentHamburgerSheet = false
    @Published var presentPremiumSheet = false
    @Published var presentTutorialSheet = false
    @Published var presentAlert = false
    @Published var alertType: AlertType = .requiredTextError

    private let service: CompareServiceProtocol
    private let freeTrialDaysLimit = 14
    var remainingFreeTrialDays: Int {
        if let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            if let installDate = try! FileManager.default.attributesOfItem(atPath: documentsFolder.path)[.creationDate] as? Date,
               let daysSinceInstallation = Calendar.current.dateComponents([.day], from: installDate, to: Date()).day {
                if daysSinceInstallation <= freeTrialDaysLimit {
                    return freeTrialDaysLimit - daysSinceInstallation
                } else {
                    return 0
                }
            }
        }
        return freeTrialDaysLimit
    }

    init(service: CompareServiceProtocol = CompareService()) {
        self.service = service
    }

    func compareButtonPressed() {
        guard remainingFreeTrialDays > 0 else {
            alertType = .premium
            presentAlert = true
            return
        }
        comparisonResult = nil
        switch inputType {
        case .text:
            compareUsingText()
        case .image:
            compareUsingImage()
        }
    }

    func addCategoryButtonPressed() {
        if !criteria.isEmpty {
            withAnimation {
                criteriaList.append(criteria)
            }
            criteria.removeAll()
        } else {
            alertType = .requiredTextError
            presentAlert = true
        }
    }

    func compareUsingText() {
        resultSaved = false
        guard !firstKeyword.isEmpty,
              !secondKeyword.isEmpty,
              !question.isEmpty else {
            alertType = .requiredTextError
            presentAlert = true
            return
        }
        playbackMode = .playing(.fromProgress(0, toProgress: 1, loopMode: .loop))
        Task {
            do {
                let textInput = ComparisonTextInput(firstKeyword: firstKeyword,
                                                    secondKeyword: secondKeyword,
                                                    question: question)
                let response = try await service.compareUsingText(firstText: firstKeyword,
                                                                  secondText: secondKeyword,
                                                                  question: question,
                                                                  criterias: criteriaList)
                await MainActor.run {
                    handleResponse(response: response, for: textInput)
                }
            } catch {
                print(error)
                await MainActor.run {
                    alertType = .noResponse
                    presentAlert = true
                }
            }
            await MainActor.run {
                playbackMode = .paused(at: .currentFrame)
            }
        }
    }

    func compareUsingImage() {
        resultSaved = false
        guard let firstImage = firstImage,
              let secondImage = secondImage else {
            alertType = .requiredImageError
            presentAlert = true
            return
        }
        guard !question.isEmpty else {
            alertType = .requiredTextError
            presentAlert = true
            return
        }
        playbackMode =  .playing(.fromProgress(0, toProgress: 1, loopMode: .loop))
        Task {
            do {

                let imageInput = ComparisonImageInput(firstImage: firstImage, 
                                                      secondImage: secondImage,
                                                      question: question)
                let response = try await service.compareUsingImage(firstImage: firstImage,
                                                                   secondImage: secondImage,
                                                                   question: question,
                                                                   criterias: criteriaList)
                await MainActor.run {
                    handleResponse(response: response, for: imageInput)
                }
            } catch {
                print(error)
                await MainActor.run {
                    alertType = .noResponse
                    presentAlert = true
                }
            }
            await MainActor.run {
                playbackMode = .paused(at: .currentFrame)
            }
        }
    }

    func logout() {
        KeychainItem.deleteUserIdentifierFromKeychain()
        UserDefaults.standard.reset()
//        self.premiumButton.isHidden = false
    }

    private func handleResponse(response: String?, for textInput: ComparisonTextInput) {
        playbackMode = .paused(at: .currentFrame)
        if let response = response {
            if let output = parseResponseJsonToOutput(response: response) {
                let result = ComparisonResult(id: UUID(),
                                              textInput: textInput,
                                              imageInput: nil,
                                              output: output)
                comparisonResult = result
            } else {
                alertType = .parsingError
                presentAlert = true
            }
        } else {
            alertType = .noResponse
            presentAlert = true
        }
    }

    private func handleResponse(response: String?, for imageInput: ComparisonImageInput) {
        playbackMode = .paused(at: .currentFrame)
        if let response = response {
            if let output = parseResponseJsonToOutput(response: response) {
                let result = ComparisonResult(id: UUID(),
                                              textInput: nil,
                                              imageInput: imageInput,
                                              output: output)
                comparisonResult = result
            } else {
                alertType = .parsingError
                presentAlert = true
            }
        } else {
            alertType = .noResponse
            presentAlert = true
        }
    }

    private func parseResponseJsonToOutput(response: String) -> ComparisonOutput? {
        guard let data = response.data(using: .utf8) else {
            return nil
        }
        do {
            let sections = try JSONDecoder().decode(ComparisonOutput.self, from: data)
            return sections
        } catch {
            print("Error converting JSON to string array: \(error)")
            return nil
        }
    }
}
