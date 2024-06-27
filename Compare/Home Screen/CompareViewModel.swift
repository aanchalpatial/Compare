//
//  CompareViewModel.swift
//  Compare
//
//  Created by Aanchal Patial on 25/06/24.
//

import Foundation
import UIKit

protocol CompareBusinessLogic: AnyObject {
    var freePremiumDaysLeft: Int { get }
    var comparisonResult: ComparisonResult? { get }
    var placeholderImage: UIImage { get }
    func compareUsingText(_ firstInput: String?, _ secondInput: String?, _ question: String?, criterias: [String])
    func compareUsingImage(_ firstImage: UIImage?, _ secondImage: UIImage?, _ question: String?, criterias: [String])
}
// MARK: - ViewModel
final class CompareViewModel: CompareBusinessLogic {

    weak var view: CompareDisplayLogic?
    private let aiModel = AiModel()
    private let service: CompareServiceProtocol
    private let maxFreePremiumDays = 14
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
    var comparisonResult: ComparisonResult?
    let placeholderImage = UIImage(systemName: "plus")!

    init(service: CompareServiceProtocol = CompareService()) {
        self.service = service
    }

    func compareUsingText(_ firstInput: String?, _ secondInput: String?, _ question: String?, criterias: [String]) {
        guard let firstInput = firstInput,
              !firstInput.isEmpty,
              let secondInput = secondInput,
              !secondInput.isEmpty,
              let question = question,
              !question.isEmpty else {
            view?.showAlert(type: .requiredTextError)
            return
        }
        view?.startLoadingAnimations()
        Task {
            do {
                let response = try await aiModel.compare(firstInput: firstInput,
                                                         secondInput: secondInput,
                                                         question: question, 
                                                         criterias: criterias)
                handleResponse(response: response, errorMessage: "Sorry ... no response available")
            } catch {
                print(error)
                handleResponse(response: nil, errorMessage: "We are facing some error, please retry after sometime ...")
            }
            view?.stopLoadingAnimations()
        }
    }

    func compareUsingImage(_ firstImage: UIImage?, _ secondImage: UIImage?, _ question: String?, criterias: [String]) {
        guard let firstImage = firstImage,
              firstImage != placeholderImage,
              let secondImage = secondImage,
              secondImage != placeholderImage else {
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
                let response = try await aiModel.compare(firstImage: firstImage,
                                                         secondImage: secondImage,
                                                         question: question,
                                                         criterias: criterias)
                handleResponse(response: response, errorMessage: "Sorry ... no response available")
            } catch {
                print(error)
                handleResponse(response: nil, errorMessage: "We are facing some error, please retry after sometime ...")
            }
            view?.stopLoadingAnimations()
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

protocol CompareServiceProtocol: AnyObject {}
// MARK: - Worker
final class CompareService: CompareServiceProtocol {}

enum AlertType {
    case logout, premium, requiredTextError, requiredImageError, parsingError, noResponse

    var title: String {
        switch self {
        case .logout:
            "Logout"
        case .premium:
            "Buy premium"
        case .requiredTextError:
            "Text missing"
        case .requiredImageError:
            "Images missing"
        case .parsingError:
            "Sorry"
        case .noResponse:
            "Sorry"
        }
    }

    var message: String {
        switch self {
        case .logout:
            "Are you sure?"
        case .premium:
            "Free trail has expired"
        case .requiredTextError:
            "Required text fields are empty"
        case .requiredImageError:
            "Please add both images"
        case .parsingError:
            "Please try again later"
        case .noResponse:
            "No response available"
        }
    }
}
