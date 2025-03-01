//
//  ViewModelConfiguration.swift
//  ryweather
//
//  Created by Ryan Young on 3/1/25.
//

import Foundation
import SwiftData

@MainActor
protocol ViewModelConfiguration {
    var schema: Schema { get }
    var inMemory: Bool { get }
    func modelContext() -> ModelContext
    func weatherDataprovider() -> WeatherDataProvider
}

// Default Implementation
extension ViewModelConfiguration {
    var schema: Schema {
        Schema([ Item.self ])
    }
    
    var inMemory: Bool {
        var inMem = false
#if DEBUG
        //if within the preview or unit tests, use in mem storage
        if CommandLine.arguments.contains("debug_store_data_in_mem_only") {
            inMem = true
        }
#endif
        return inMem
    }
    
    func modelContext() -> ModelContext {
//        let urlApp = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
//        let url = urlApp!.appendingPathComponent("default.store")
//        if FileManager.default.fileExists(atPath: url.path) {
//            print("macOS: delete the swiftData .store* files here if crash on launch: \(url.absoluteString)")
//        }
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {

            let container = try ModelContainer(for: schema, configurations: config)
            return container.mainContext
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    func weatherDataprovider() -> WeatherDataProvider {
        WeatherAPIDataSource(apiKey: UserDefaults.standard.string(forKey: "apikey") ?? "")
    }
}

struct DefaultViewModelConfig: ViewModelConfiguration { }
