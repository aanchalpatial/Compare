//
//  CompareViewModel.swift
//  Compare
//
//  Created by Aanchal Patial on 25/06/24.
//

import UIKit

protocol CompareBusinessLogic: AnyObject {
    var freePremiumDaysLeft: Int { get }
    var comparisonResult: ComparisonOutput? { get }
    var placeholderImageName: String { get }
    func compareUsingText(firstText: String?, secondText: String?, question: String?, criterias: [String])
    func compareUsingImage(firstImage: UIImage?, secondImage: UIImage?, question: String?, criterias: [String])
}
// MARK: - ViewModel
final class CompareViewModel: CompareBusinessLogic {

    weak var view: CompareDisplayLogic?
    private let service: CompareServiceProtocol
    private let maxFreePremiumDays = 140
    var freePremiumDaysLeft: Int {
        if let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            if let installDate = try! FileManager.default.attributesOfItem(atPath: documentsFolder.path)[.creationDate] as? Date,
               let daysSinceInstallation = Calendar.current.dateComponents([.day], from: installDate, to: Date()).day {
                if daysSinceInstallation <= maxFreePremiumDays {
                    return maxFreePremiumDays - daysSinceInstallation
                } else {
                    return 0
                }
            }
        }
        return maxFreePremiumDays
    }
    var comparisonResult: ComparisonOutput?
    let placeholderImageName = "plus"

    init(service: CompareServiceProtocol = CompareService()) {
        self.service = service
    }

    func compareUsingText(firstText: String?, secondText: String?, question: String?, criterias: [String]) {
        guard let firstText = firstText,
              !firstText.isEmpty,
              let secondText = secondText,
              !secondText.isEmpty,
              let question = question,
              !question.isEmpty else {
            view?.showAlert(type: .requiredTextError)
            return
        }
        view?.startLoadingAnimations()
        Task {
            do {
                let response = try await service.compareUsingText(firstText: firstText,
                                                                  secondText: secondText,
                                                                  question: question,
                                                                  criterias: criterias)
                await MainActor.run {
                    handleResponse(response: response, errorMessage: "Sorry ... no response available")
                }
            } catch {
                print(error)
                await MainActor.run {
                    handleResponse(response: nil, errorMessage: "We are facing some error, please retry after sometime ...")
                }
            }
            await MainActor.run {
                view?.stopLoadingAnimations()
            }
        }
    }

    func compareUsingImage(firstImage: UIImage?, secondImage: UIImage?, question: String?, criterias: [String]) {
        guard let firstImage = firstImage,
              !firstImage.isEqual(UIImage(systemName: placeholderImageName)),
              let secondImage = secondImage,
              !secondImage.isEqual(UIImage(systemName: placeholderImageName)) else {
            view?.showAlert(type: .requiredImageError)
            return
        }
        guard let question = question,
              !question.isEmpty else {
            view?.showAlert(type: .requiredTextError)
                return
        }
        view?.startLoadingAnimations()
        Task {
            do {
                let response = try await service.compareUsingImage(firstImage: firstImage,
                                                                   secondImage: secondImage,
                                                                   question: question,
                                                                   criterias: criterias)
                await MainActor.run {
                    handleResponse(response: response, errorMessage: "Sorry ... no response available")
                }
            } catch {
                print(error)
                await MainActor.run {
                    handleResponse(response: nil, errorMessage: "We are facing some error, please retry after sometime ...")
                }
            }
            await MainActor.run {
                view?.stopLoadingAnimations()
            }
        }
    }

    private func handleResponse(response: String?, errorMessage: String?) {
        if let response = response {
            if let sections = parseResponseJsonToSections(response: response) {
                self.comparisonResult = sections
                view?.reloadTableView()
            } else {
                view?.showAlert(type: .parsingError)
            }
        } else {
            view?.showAlert(type: .noResponse)
        }
    }

    private func parseResponseJsonToSections(response: String) -> ComparisonOutput? {
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
