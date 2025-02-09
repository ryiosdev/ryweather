//
//  WeatherDataViewModel.swift
//  ryweather
//
//  Created by Ryan Young on 2/8/25.
//

import Foundation
import Observation
import SwiftData

//enum WeatherViewState {
//    case initial
//    case showingCurrent(LocationModel)
//    case searching(String)
//    case searchResults([LocationSearchResultModel])
//    case error(Error)
//}

extension ContentView {
    @Observable
    class WeatherViewModel {
        var modelContext: ModelContext
        private(set) var currentLocation: LocationModel?
        
        @ObservationIgnored private var weatherDataProvider: WeatherDataProvider
        
        init(_ modelContext: ModelContext,
            weatherProvider: WeatherDataProvider = WeatherAPIDataSource(apiKey: UserDefaults.standard.string(forKey: "apikey") ?? "")) {
            self.modelContext = modelContext
            print("weather provider: \(String(describing: weatherProvider))")
            self.weatherDataProvider = weatherProvider
            
//            do {
//                let models = try modelContext.fetch(FetchDescriptor<LocationModel>())
//                if let firstModel = models.first {
//                    self.currentLocation = firstModel
//                }
//            } catch {
//                print("Fetch failed")
//            }
        }
        
        func fetchCurrentWeather(for location: String) async throws {
            let updatedLcationModel = try await weatherDataProvider.fetchCurrentWeather(for: location)
            self.currentLocation = updatedLcationModel
        }
    }
}
