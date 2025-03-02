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
    var modelContainer: ModelContainer { get }
    var weatherDataProvider: WeatherDataProvider { get }
}

// MARK: Default Implementation
extension ViewModelConfiguration {
    func weatherDataProvider() -> WeatherDataProvider {
        WeatherAPIDataSource(apiKey: UserDefaults.standard.string(forKey: "apikey") ?? "")
    }
}

struct DefaultViewModelConfig: ViewModelConfiguration {
    var modelContainer: ModelContainer
    var weatherDataProvider: WeatherDataProvider
    
    init(inMemoryOnly: Bool = false, weatherAPIKey: String) {
        //Use this code to blow away the macOS app's previous SwiftData store.
//        let urlApp = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
//        let url = urlApp!.appendingPathComponent("default.store")
//        if FileManager.default.fileExists(atPath: url.path) {
//            print("macOS: delete the swiftData .store* files here if crash on launch: \(url.absoluteString)")
//        }
        let schema = Schema([LocationModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemoryOnly)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        weatherDataProvider = WeatherAPIDataSource(apiKey: weatherAPIKey)
    }
}


// MARK: Preview Implementation
// TODO:


// MARK: Unit Test Implementation
// TODO:
