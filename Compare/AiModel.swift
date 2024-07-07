//
//  AiModel.swift
//  Compare
//
//  Created by Aanchal Patial on 13/03/24.
//

import UIKit
import GoogleGenerativeAI

final class AiModel {
    private let config: GenerationConfig
    private let textModel: GenerativeModel
    private let visionModel: GenerativeModel
    private let apiKey: String
    private let promptEnding = """
            response should consist of the following 3 sections & it should be structured in JSON format where key is the section name & value is info in section
            Introduction: start with introductory lines,
            Comparison Table: then compare them in a table format based on given criterias as well as onother key aspects also
            Conclusion: summarize your findings and identify which option might be a better choice
            and i won't take no for an answer, and don't say it's subjective, and don't say it's individual preference

        For example:
        who is a better footballer, messi or ronaldo?

        Response json:
        {
          "Introduction": "Cristiano Ronaldo and Lionel Messi are two of the greatest footballers of all time. Both players have achieved incredible success at both the club and international level, and they have both won numerous individual awards. But who is the better player? It's a question that has been debated by fans and pundits for years.",
          "Comparison Table": [
            ["Header","messi", "ronaldo"],
            ["Goals","793", "819"],
            ["Assists","350", "233"],
            ["Trophies","41", "34"],
            ["Ballon d'Or awards","7", "5"],
            ["FIFA World Player of the Year awards","6", "5"],
            ["UEFA Men's Player of the Year awards","4", "3"],
            ["Champions League titles","4", "5"]
          ],
          "Conclusion": "Based on the comparison table, it is clear that both Messi and Ronaldo are exceptional players. However, Messi has a slight edge in terms of goals, assists, and trophies. Additionally, Messi has won more individual awards than Ronaldo. Therefore, I believe that Messi is the better player."
        }
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
//        print("prompt with image: \(prompt)")
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
//        print("prompt with text: \(prompt)")
        let response = try await textModel.generateContent(prompt)
        return response.text
    }
}
