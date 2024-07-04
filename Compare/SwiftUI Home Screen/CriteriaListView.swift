//
//  CriteriaListView.swift
//  Compare
//
//  Created by Aanchal Patial on 04/07/24.
//

import SwiftUI

struct CriteriaListView: View {
    @Binding var criterias: [String]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(content: {
                ForEach(criterias.indices, id: \.self) { index in
                    Button {
                        withAnimation {
                            criterias.removeAll(where: { $0 == criterias[index] })
                        }
                    } label: {
                        HStack {
                            Text(criterias[index])
                            Image(systemName: "xmark")

                        }
                    }
                    .foregroundStyle(.black)
                    .padding(6)
                    .background(.white)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                    }
                }
            })
        }
    }
}

#Preview {
    @State var criterias: [String] = ["abc", "xyz"]
    return CriteriaListView(criterias: $criterias)
}
