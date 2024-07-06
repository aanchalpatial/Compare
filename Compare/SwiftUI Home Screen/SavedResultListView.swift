//
//  SavedResultsView.swift
//  Compare
//
//  Created by Aanchal Patial on 05/07/24.
//

import SwiftUI

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

struct SavedResultListView: View {
    private let savedResultService: SaveResultServiceProtocol = SaveResultService()
    @State private var isLoading = false
    @State var results = [ComparisonResult]()

    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView()
            } else if results.isEmpty {
                Text("No saved results")
                    .font(.custom("Verdana", size: 18))
                    .foregroundStyle(.gray)
            }
            else {
                List {
                    ForEach(results, id: \.self) { result in
                        if let textInput = result.textInput {
                            let text = "\(textInput.firstKeyword) 🆚 \(textInput.secondKeyword) - \(result.id)"
                            NavigationLink(text, value: result)
                        } else if let imageInput = result.imageInput {
                            NavigationLink(value: result) {
                                HStack {
                                    Image(uiImage: UIImage(data: imageInput.firstImageData) ?? UIImage())
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.placeholder)
                                        }
                                    Text("🆚")
                                    Image(uiImage: UIImage(data: imageInput.secondImageData) ?? UIImage())
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
                    .onDelete(perform: { indexSet in
                        removeResult(indexSet: indexSet)
                    })
                }
                .navigationTitle("Saved results")
                .navigationDestination(for: ComparisonResult.self) { result in
                    ResultView(result: result)
                }

            }
        }
        .font(.custom("Verdana", size: 14))
        .onAppear(perform: {
            isLoading = true
            fetchSavedResults()
        })
    }

    func fetchSavedResults() {
        Task {
            let results = await (try? savedResultService.getAllResults()) ?? []
            await MainActor.run {
                self.results = results
                isLoading = false
            }
        }
    }

    func removeResult(indexSet: IndexSet) {
        if let index = indexSet.first {
            let id = results[index].id
            results.remove(atOffsets: indexSet)
            Task {
                try? await savedResultService.removeResult(for: id)
            }
        }
    }
}

#Preview {
    let input = ComparisonTextInput(firstKeyword: "messi", secondKeyword: "ronaldo", question: "who is a better footballer?")
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
    let result = ComparisonResult(id: UUID(), textInput: input, imageInput: nil, output: output)
    let image = UIImage(systemName: "applelogo")!
    let imageInput = ComparisonImageInput(firstImage: image, secondImage: image, question: "who is a better footballer? who is a better footballer?")
    let result2 = ComparisonResult(id: UUID(), textInput: nil, imageInput: imageInput, output: output)
    let results = [result, result2]
    return SavedResultListView(results: results)
}
