//
//  PrimaryTabView.swift
//  Compare
//
//  Created by Aanchal Patial on 05/07/24.
//

import SwiftUI

struct PrimaryTabView: View {

    @StateObject private var savedResultsStore = SavedResultsService()

    var body: some View {
        return TabView {
            CompareView(savedResults: $savedResultsStore.results)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(1)
            SavedResultListView(savedResults: $savedResultsStore.results)
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
                .tag(2)
        }
        .task {
            try? await savedResultsStore.load()
        }
        .onChange(of: savedResultsStore.results) {
            Task {
                try? await savedResultsStore.save()
            }
        }
    }
}

#Preview {
    PrimaryTabView()
}
