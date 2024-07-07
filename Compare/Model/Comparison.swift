//
//  Comparison.swift
//  Compare
//
//  Created by Aanchal Patial on 07/07/24.
//

import UIKit

struct ComparisonTextInput: Codable {
    let firstKeyword: String
    let secondKeyword: String
    let question: String
}

struct ComparisonImageInput: Codable {
    let firstImageData: Data
    let secondImageData: Data
    let question: String

    init(firstImage: UIImage, secondImage: UIImage, question: String) {
        firstImageData = firstImage.pngData() ?? Data()
        secondImageData = secondImage.pngData() ?? Data()
        self.question = question
    }
}

struct ComparisonOutput: Codable {
    let introduction: String
    let comparisonTable: [[String]]
    let conclusion: String

    enum CodingKeys: String, CodingKey {
        case introduction = "Introduction"
        case comparisonTable = "Comparison Table"
        case conclusion = "Conclusion"
    }
}

struct ComparisonResult: Hashable, Codable {
    let id: UUID
    let textInput: ComparisonTextInput?
    let imageInput: ComparisonImageInput?
    let output: ComparisonOutput

    static func == (lhs: ComparisonResult, rhs: ComparisonResult) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
