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
final class CompareViewModel2: ObservableObject {

    @Published var inputType: InputType = .text
    @Published var firstKeyword: String = ""
    @Published var secondKeyword: String = ""
    @Published var firstImage: UIImage?
    @Published var secondImage: UIImage?
    @Published var question: String = ""
    @Published var criteriaList = [String]()
    @Published var criteria: String = ""
    @Published var playbackMode: LottiePlaybackMode = .paused(at: .currentFrame)
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
                let response = try await service.compareUsingText(firstText: firstKeyword,
                                                                  secondText: secondKeyword,
                                                                  question: question,
                                                                  criterias: criteriaList)
                await MainActor.run {
                    handleResponse(response: response)
                }
            } catch {
                print(error)
                await MainActor.run {
                    handleResponse(response: nil)
                }
            }
            await MainActor.run {
                playbackMode = .paused(at: .currentFrame)
            }
        }
    }

    func compareUsingImage() {
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
                let response = try await service.compareUsingImage(firstImage: firstImage,
                                                                   secondImage: secondImage,
                                                                   question: question,
                                                                   criterias: criteriaList)
                await MainActor.run {
                    handleResponse(response: response)
                }
            } catch {
                print(error)
                await MainActor.run {
                    handleResponse(response: nil)
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

    private func handleResponse(response: String?) {
        playbackMode = .paused(at: .currentFrame)
        if let response = response {
            if let sections = parseResponseJsonToSections(response: response) {
                comparisonResult = sections
            } else {
                alertType = .parsingError
                presentAlert = true
            }
        } else {
            alertType = .noResponse
            presentAlert = true
        }
    }

    private func parseResponseJsonToSections(response: String) -> ComparisonResult? {
        guard let data = response.data(using: .utf8) else {
            return nil
        }
        do {
            let sections = try JSONDecoder().decode(ComparisonResult.self, from: data)
            return sections
        } catch {
            print("Error converting JSON to string array: \(error)")
            return nil
        }
    }
}
