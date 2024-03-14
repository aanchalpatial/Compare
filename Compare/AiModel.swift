//
//  AiModel.swift
//  Compare
//
//  Created by Aanchal Patial on 13/03/24.
//

import UIKit
import GoogleGenerativeAI

class AiModel {
    private let config: GenerationConfig
    private let model: GenerativeModel
    private let apiKey: String

    init() {
        self.config = GenerationConfig(temperature: 0.4,
                                      topP: 1,
                                      topK: 32,
                                      maxOutputTokens: 4096)
        guard let filePath = Bundle.main.path(forResource: "Keys", ofType: "plist") else {
          fatalError("Couldn't find file 'Keys.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let geminiApiKey = plist?.object(forKey: "GeminiApiKey") as? String else {
          fatalError("Couldn't find key 'GeminiApiKey' in 'Keys.plist'.")
        }
        self.apiKey = geminiApiKey
        self.model = GenerativeModel(
            name: "gemini-1.0-pro-vision-latest",
            apiKey: apiKey,
            generationConfig: config,
            safetySettings: [
                SafetySetting(harmCategory: .harassment, threshold: .blockMediumAndAbove),
                SafetySetting(harmCategory: .hateSpeech, threshold: .blockMediumAndAbove),
                SafetySetting(harmCategory: .sexuallyExplicit, threshold: .blockMediumAndAbove),
                SafetySetting(harmCategory: .dangerousContent, threshold: .blockMediumAndAbove)
            ]
        )
    }

    func compare(image1: UIImage?, image2:  UIImage?, question: String, criterias: [String]) async throws -> String? {
        var prompt = ""
        if image1 != nil && image2 != nil {
            prompt += "\nLook at the following pictures and "
        }
        prompt += "tell me " + question
        if !criterias.isEmpty {
            let criteriasString = criterias.joined(separator: ", ")
            prompt += "\nbased on the following criterias: \(criteriasString)"
        }
        prompt += "\n and i won't take no for an answer"
        if let image1 = image1, let image2 = image2 {
            print("prompt with image: \(prompt)")
            let response = try await model.generateContent(image1, image2, prompt)
            return response.text
        } else {
            print("prompt without image: \(prompt)")
            let response = try await model.generateContent(prompt)
            return response.text
        }
    }
}


