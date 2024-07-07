//
//  BlackBackgroundButtonView.swift
//  Compare
//
//  Created by Aanchal Patial on 04/07/24.
//

import SwiftUI

struct PrimaryButtonView: View {
    let title: String
    let handler: (() -> Void)?

    var body: some View {
        Button {
            handler?()
        } label: {
            Text(title)
                .frame(maxWidth: .infinity, minHeight: 32)
        }
        .fontWeight(.medium)
        .foregroundStyle(.white)
        .padding(8)
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    PrimaryButtonView(title: "title", handler: nil)
}
