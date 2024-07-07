//
//  TutorialView.swift
//  Compare
//
//  Created by Aanchal Patial on 07/07/24.
//

import SwiftUI

struct TutorialView: View {
    var body: some View {
        Spacer(minLength: 16)
        Text("Welcome 🤗🤗 to compareIt!")
            .font(.custom("Verdana", size: 20))
            .fontWeight(.medium)
            .padding([.bottom], 4)
        Text("Your one-stop app for comparing anything!")
            .font(.custom("Verdana", size: 16))
            .fontWeight(.thin)
            .foregroundStyle(.gray)

        List {
            Text("1️⃣ Toggle to compare using Text - Two text boxes will appear. Enter the text you want to compare in each box.")
            Text("2️⃣ Or, Toggle to compare using Image - Two image boxes will appear. Enter the image you want to compare in each box.")
            Text("3️⃣ Ask the question based on which you want to compare.")
            Text("⭐️ Bonus tip: you can also add specific target criterias for detailed comparison.")
        }
        .font(.custom("Verdana", size: 14))
    }
}

#Preview {
    TutorialView()
}
