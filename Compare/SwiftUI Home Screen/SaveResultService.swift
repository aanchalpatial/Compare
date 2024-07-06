//
//  SaveResultService.swift
//  Compare
//
//  Created by Aanchal Patial on 06/07/24.
//

import Foundation

protocol SaveResultServiceProtocol: AnyObject {
    func save(result: ComparisonResult) async throws
    func removeResult(for id: UUID) async throws
    func getAllResults() async throws -> [ComparisonResult]
}

// MARK: - Worker
final class SaveResultService: SaveResultServiceProtocol {

    
    let resultsDictionaryUserDefaultsKey = "favorites-dictionary"

    init() {
        if UserDefaults.standard.data(forKey: resultsDictionaryUserDefaultsKey) == nil {
            let resultsDictionary: [UUID: ComparisonResult] = [:]
            let data = try? JSONEncoder().encode(resultsDictionary)
            UserDefaults.standard.set(data, forKey: resultsDictionaryUserDefaultsKey)
        }
    }

    func save(result: ComparisonResult) async throws {
        if let data = UserDefaults.standard.data(forKey: resultsDictionaryUserDefaultsKey) {
            var resultsDictionary = try JSONDecoder().decode([UUID: ComparisonResult].self, from: data)
            resultsDictionary[result.id] = result
            let data = try JSONEncoder().encode(resultsDictionary)
            UserDefaults.standard.set(data, forKey: resultsDictionaryUserDefaultsKey)
        } else {
            throw NSError(domain: "No results dictionary exists", code: 0)
        }
    }
    
    func removeResult(for id: UUID) async throws {
        if let data = UserDefaults.standard.data(forKey: resultsDictionaryUserDefaultsKey) {
            var resultsDictionary = try JSONDecoder().decode([UUID: ComparisonResult].self, from: data)
            resultsDictionary.removeValue(forKey: id)
            let data = try JSONEncoder().encode(resultsDictionary)
            UserDefaults.standard.set(data, forKey: resultsDictionaryUserDefaultsKey)
        } else {
            throw NSError(domain: "No results dictionary exists", code: 0)
        }
    }

    func getAllResults() async throws -> [ComparisonResult] {
        var results = [ComparisonResult]()
        if let data = UserDefaults.standard.data(forKey: resultsDictionaryUserDefaultsKey) {
            let resultsDictionary = try JSONDecoder().decode([UUID: ComparisonResult].self, from: data)
            for (_, result) in resultsDictionary {
                results.append(result)
            }
        }
        return results
    }
}
