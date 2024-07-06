//
//  PrimaryTabView.swift
//  Compare
//
//  Created by Aanchal Patial on 05/07/24.
//

import SwiftUI

struct PrimaryTabView: View {
    @State var selectedTab = 1

    var body: some View {
        TabView {
            CompareView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(1)
            SavedResultListView(results: [])
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    PrimaryTabView()
}
