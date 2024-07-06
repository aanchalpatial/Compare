//
//  PrimaryTabView.swift
//  Compare
//
//  Created by Aanchal Patial on 05/07/24.
//

import SwiftUI

struct PrimaryTabView: View {

    var body: some View {
        TabView {
            CompareView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            SavedResultListView(results: [])
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
        }
    }
}

#Preview {
    PrimaryTabView()
}
