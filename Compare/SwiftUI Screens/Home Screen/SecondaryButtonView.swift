//
//  BlackBorderButtonView.swift
//  Compare
//
//  Created by Aanchal Patial on 04/07/24.
//

import SwiftUI

struct SecondaryButtonView: View {
    let title: String
    var width: CGFloat = .infinity
    let handler: (() -> Void)?

    var body: some View {
        Button {
            handler?()
        } label: {
            Text(title)
                .frame(maxWidth: width)
        }
        .fontWeight(.medium)
        .foregroundStyle(.black)
        .padding(8)
        .background(.white)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke()
        }
    }
}

#Preview {
    SecondaryButtonView(title: "title", handler: nil)
}
