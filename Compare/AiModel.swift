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
    private let promptEnding = """
            response should consist of the following 3 sections
            Introduction: start with introductory lines,
            Comparison Table: then compare them in a table format based on given criterias as well as onother key aspects also
            Conclusion: summarize your findings and identify which option might be a better choice
            and i won't take no for an answer, and don't say it's subjective, and don't say it's individual preference

        For example:
        Question: which is a better footwear brand: nike or bata?

        Response:
        **INTRODUCTION**
        Hey there! If you're a sneaker enthusiast, you might often find yourself torn between two popular footwear brands: Nike and Bata. 
        Both have their strengths and weaknesses, and the "best" choice ultimately depends on your individual needs.
        However, we'll do an in-depth comparison of Nike and Bata here, considering various factors like price, comfort, and other aspects, to help you reach an informed purchase decision.


        **COMPARISON TABLE**
        | Feature | Nike | Bata |
        |---|---|---|
        | Price | $60-$200 | $20-$100 |
        | Comfort | 5/5 | 4/5 |
        | Durability | 4/5 | 3/5 |
        | Style | 5/5 | 3/5 |
        | Brand Recognition | 5/5 | 4/5 |


        **CONCLUSION**
        Based on the comparison above, it's evident that both Nike and Bata have distinct advantages. Nike excels in comfort, style, and brand recognition, while Bata offers a more affordable option with decent comfort levels. Ultimately, the choice between Nike and Bata depends on your budget, priorities, and personal preferences.

        If you're looking for premium footwear with the latest technology, a wider style selection, and don't mind paying a higher price, Nike is your go-to choice. However, if you prioritize affordability and still want reliable and comfortable footwear, Bata fits the bill. The brand might not offer the same level of style and technological advancements as Nike, but it delivers good value for money.
        """

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
            prompt += "\ngiven criterias are: \(criteriasString)"
        }
        prompt += promptEnding
        print("prompt with image: \(prompt)")
        let response = try await visionModel.generateContent(firstImage, secondImage, prompt)
        return response.text
    }

    func compare(firstInput: String, secondInput:  String, question: String, criterias: [String]) async throws -> String? {
        var prompt = "\ntell me " + question + ", " + firstInput + " or " + secondInput
        if !criterias.isEmpty {
            let criteriasString = criterias.joined(separator: ", ")
            prompt += "\ngiven criterias are: \(criteriasString)"
        }
        prompt += promptEnding
        print("prompt with text: \(prompt)")
        let response = try await textModel.generateContent(prompt)
        return response.text
    }
}


