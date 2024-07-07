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
        TabView {
            CompareView(savedResults: $savedResultsStore.results)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .backgroundStyle(.black)
            SavedResultListView(savedResults: $savedResultsStore.results)
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
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
