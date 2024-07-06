//
//  SavedResultsView.swift
//  Compare
//
//  Created by Aanchal Patial on 05/07/24.
//

import SwiftUI

struct ComparisonTextInput {
    let firstKeyword: String
    let secondKeyword: String
}

struct ComparisonImageInput {
    let firstImage: UIImage
    let secondImage: UIImage
}

struct ComparisonResult: Hashable {
    static func == (lhs: ComparisonResult, rhs: ComparisonResult) -> Bool {
        lhs.question == rhs.question
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(question)
    }

    let textInput: ComparisonTextInput?
    let imageInput: ComparisonImageInput?
    let question: String
    let output: ComparisonOutput
}

struct SavedResultListView: View {
    var results: [ComparisonResult]
    var body: some View {
        NavigationStack {
            List {
                ForEach(results, id: \.self) { result in
                    if let textInput = result.textInput {
                        let text = "\(textInput.firstKeyword) 🆚 \(textInput.secondKeyword)"
                        NavigationLink(text, value: result)
                    } else if let imageInput = result.imageInput {
                        NavigationLink(value: result) {
                            HStack {
                                Image(uiImage: imageInput.firstImage)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(.placeholder)
                                    }
                                Text("🆚")
                                Image(uiImage: imageInput.secondImage)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(.placeholder)
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Saved results")
            .navigationDestination(for: ComparisonResult.self) { result in
                ResultView(result: result)
            }
        }
    }
}

#Preview {
    let input = ComparisonTextInput(firstKeyword: "messi", secondKeyword: "ronaldo")
    let question = "who is a better footballer? who is a better footballer? who is a better footballer? who is a better footballer?"
    let output = ComparisonOutput(introduction: "Cristiano Ronaldo and Lionel Messi are two of the greatest footballers of all time. Both players have achieved incredible success at both the club and international level, and they have both won numerous individual awards. But who is the better player? It's a question that has been debated by fans and pundits for years.",
                                  comparisonTable: [
                                    ["Header","messi", "ronaldo"],
                                    ["Goals","793", "819"],
                                    ["Assists","350", "233"],
                                    ["Trophies","41", "34"],
                                    ["Ballon d'Or awards","7", "5"],
                                    ["FIFA World Player of the Year awards","6", "5"],
                                    ["UEFA Men's Player of the Year awards","4", "3"],
                                    ["Champions League titles","4", "5"]],
                                  conclusion: "Based on the comparison table, it is clear that both Messi and Ronaldo are exceptional players. However, Messi has a slight edge in terms of goals, assists, and trophies. Additionally, Messi has won more individual awards than Ronaldo. Therefore, I believe that Messi is the better player.")
    let result = ComparisonResult(textInput: input, imageInput: nil, question: question, output: output)
    let image = UIImage(systemName: "applelogo")!
    let imageInput = ComparisonImageInput(firstImage: image, secondImage: image)
    let result2 = ComparisonResult(textInput: nil, imageInput: imageInput, question: "some question?", output: output)
    let results = [result, result2]
    return SavedResultListView(results: results)
}
