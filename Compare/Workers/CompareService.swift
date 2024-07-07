//
//  CompareService.swift
//  Compare
//
//  Created by Aanchal Patial on 04/07/24.
//

import Foundation
import UIKit

protocol CompareServiceProtocol: AnyObject {
    func compareUsingText(firstText: String, secondText: String, question: String, criterias: [String]) async throws -> String?
    func compareUsingImage(firstImage: UIImage, secondImage: UIImage, question: String, criterias: [String]) async throws -> String?
}

// MARK: - Worker
final class CompareService: CompareServiceProtocol {
    private let aiModel = AiModel()
    func compareUsingText(firstText: String, secondText: String, question: String, criterias: [String]) async throws -> String? {
        let response = try await aiModel.compare(firstInput: firstText,
                                                 secondInput: secondText,
                                                 question: question,
                                                 criterias: criterias)
        return response
    }
    
    func compareUsingImage(firstImage: UIImage, secondImage: UIImage, question: String, criterias: [String]) async throws -> String? {
        let response = try await aiModel.compare(firstImage: firstImage,
                                                 secondImage: secondImage,
                                                 question: question,
                                                 criterias: criterias)
        return response
    }
}
