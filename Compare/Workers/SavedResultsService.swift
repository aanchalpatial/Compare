//
//  SavedResultsService.swift
//  Compare
//
//  Created by Aanchal Patial on 06/07/24.
//

import Foundation

// MARK: - Worker
final class SavedResultsService: ObservableObject {

    @Published var results = [ComparisonResult]()


    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("persisted.results")
    }


    func load() async throws {
        let task = Task<[ComparisonResult], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let dailyScrums = try JSONDecoder().decode([ComparisonResult].self, from: data)
            return dailyScrums
        }
        let savedResults = try await task.value
        await MainActor.run {
            self.results = savedResults
        }
    }


    func save() async throws {
        let task = Task {
            let data = try JSONEncoder().encode(results)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
}
