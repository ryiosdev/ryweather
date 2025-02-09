//
//  WeatherDataViewModel.swift
//  ryweather
//
//  Created by Ryan Young on 2/8/25.
//

import Foundation
import Observation

enum WeatherViewState {
    case initial
    case showingCurrent(LocationModel)
    case searching(String)
    case searchResults([LocationSearchResultModel])
    case error(Error)
}

extension ContentView {
    @Observable
    class WeatherViewModel {
        
        private(set) var state: WeatherViewState = .initial
        private(set) var currentLocation: LocationModel?
        
        @ObservationIgnored private var weatherDataProvider: WeatherDataProvider
        
        init(_ weatherProvider: WeatherDataProvider = WeatherAPIDataSource(apiKey: UserDefaults.standard.string(forKey: "apikey") ?? "")) {
            print("weather provider: \(String(describing: weatherProvider))")
            weatherDataProvider = weatherProvider
        }
        
        func updateCurrentLocation(_ location: String) async throws {
            currentLocation = try await weatherDataProvider.fetchCurrentWeatherFor(location)
        }
        
    }
}
