//
//  ResultView.swift
//  Compare
//
//  Created by Aanchal Patial on 05/07/24.
//

import SwiftUI

struct ResultView: View {
    var result: ComparisonResult
    let placeholderImage = UIImage(systemName: "plus")!
    var body: some View {
        List {
            Section("Input") {

                if let textInput = result.textInput {
                    HStack {
                        Text(textInput.question)
                        Spacer()
                    }
                    HStack {
                        Text(textInput.firstKeyword)
                        Text("🆚")
                        Text(textInput.secondKeyword)
                        Spacer()
                    }

                } else if let imageInput = result.imageInput {
                    HStack {
                        Text(imageInput.question)
                        Spacer()
                    }
                    HStack {
                        let firstImage = UIImage(data: imageInput.firstImageData) ?? UIImage()
                        Image(uiImage: firstImage)
                            .resizable()
                            .frame(width: 150, height: 150)
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.black)
                            }
                        Spacer()
                        let secondImage = UIImage(data: imageInput.secondImageData) ?? UIImage()
                        Image(uiImage: secondImage)
                            .resizable()
                            .frame(width: 150, height: 150)
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.black)
                            }
                    }
                }
            }
            Section("Introduction") {
                Text(result.output.introduction)
            }

            Section("Comparison Table") {
                Grid(alignment: .leading) {
                    ForEach(result.output.comparisonTable, id: \.self) { row in

                        GridRow {
                            ForEach(row, id: \.self) { cell in
                                if row == result.output.comparisonTable.first {
                                    Text(cell)
                                        .fontWeight(.semibold)
                                } else {
                                    Text(cell)
                                }
                            }
                        }
                        Divider()
                    }

                }
                .fixedSize(horizontal: false, vertical: true)
            }

            Section("Conclusion") {
                Text(result.output.conclusion)
            }
        }
        .font(.custom("Verdana", size: 14))
        .navigationBarTitleDisplayMode(.inline)
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
    let imageInput = ComparisonImageInput(firstImage: image, secondImage: image, question: "who is a better footballer?")
    let result2 = ComparisonResult(id: UUID(), textInput: nil, imageInput: imageInput, output: output)
    return ResultView(result: result2)
}
