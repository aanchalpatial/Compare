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
    private let textModel: GenerativeModel
    private let visionModel: GenerativeModel
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
        self.visionModel = GenerativeModel(
            name: "gemini-1.0-pro-vision-latest",
            apiKey: apiKey,
            generationConfig: config,
            safetySettings: [
                SafetySetting(harmCategory: .harassment, threshold: .blockNone),
                SafetySetting(harmCategory: .hateSpeech, threshold: .blockNone),
                SafetySetting(harmCategory: .sexuallyExplicit, threshold: .blockNone),
                SafetySetting(harmCategory: .dangerousContent, threshold: .blockNone)
            ]
        )
        self.textModel = GenerativeModel(
            name: "gemini-1.0-pro-001",
            apiKey: apiKey,
            generationConfig: config,
            safetySettings: [
                SafetySetting(harmCategory: .harassment, threshold: .blockNone),
                SafetySetting(harmCategory: .hateSpeech, threshold: .blockNone),
                SafetySetting(harmCategory: .sexuallyExplicit, threshold: .blockNone),
                SafetySetting(harmCategory: .dangerousContent, threshold: .blockNone)
            ]
        )
    }

    func compare(firstImage: UIImage, secondImage:  UIImage, question: String, criterias: [String]) async throws -> String? {
        var prompt = "\nLook at the following pictures and tell me " + question
        if !criterias.isEmpty {
            let criteriasString = criterias.joined(separator: ", ")
            prompt += "\nbased on the following criterias: \(criteriasString)"
        }
        prompt += "\n and i won't take no for an answer"
        print("prompt with image: \(prompt)")
        let response = try await visionModel.generateContent(firstImage, secondImage, prompt)
        return response.text
    }

    func compare(firstInput: String, secondInput:  String, question: String, criterias: [String]) async throws -> String? {
        var prompt = "\ntell me " + question + ", " + firstInput + " or " + secondInput
        if !criterias.isEmpty {
            let criteriasString = criterias.joined(separator: ", ")
            prompt += "\nbased on the following criterias: \(criteriasString)"
        }
        prompt += "\n and i won't take no for an answer"
        print("prompt with text: \(prompt)")
        let response = try await textModel.generateContent(prompt)
        return response.text
    }
}


