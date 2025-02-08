//
//  WeatherSearchViewModel.swift
//  ryweather
//
//  Created by Ryan Young on 2/8/25.
//

import SwiftUI

enum WeatherSearchState {
    case initial
    case searching(String)
    case results([LocationSearchResultModel])
    case error(Error)
}

extension ContentView {
    @Observable
    class WeatherSearchViewModel {
        var state: WeatherSearchState = .initial
        private(set) var currentLocation: LocationModel?
        
        private var weatherDataProvider: WeatherDataProvider
        
        init(_ weatherProvider: WeatherDataProvider = WeatherAPIDataSource(apiKey: "not your API key")) {
            weatherDataProvider = weatherProvider
        }
        
        func updateCurrentLocation(_ location: String) async throws {
            currentLocation = try await weatherDataProvider.fetchCurrentWeatherFor(location)
        }
        
    }
}
