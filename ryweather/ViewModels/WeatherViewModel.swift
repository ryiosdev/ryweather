//
//  WeatherViewModel.swift
//  ryweather
//
//  Created by Ryan Young on 2/8/25.
//

import Foundation
import Observation
import SwiftData
import os

@Observable @MainActor
class WeatherViewModel {
    private let logger = Logger()

    // TODO: Don't support empty list of locations, always keep the last one and prevent delete so you don't have to code "zero locations" corner caes
    var locations = [LocationModel(name: "San Antonio"),
                     LocationModel(name: "New York"),
                     LocationModel(name: "Seattle")]
    
    @ObservationIgnored private var weatherDataProvider: WeatherDataProvider
    
    init(_ weatherProvider: WeatherDataProvider = WeatherAPIDataSource(apiKey: UserDefaults.standard.string(forKey: "apikey") ?? "")) {
        logger.debug("new WeatherViewModel with weather provider: \(String(describing: weatherProvider))")
        self.weatherDataProvider = weatherProvider
    }
    
    //CRUD operations for locations array.
    func add(_ location: LocationModel) {
        locations.append(location)
    }
    
    func locationIndex(_ id: LocationModel.ID?) -> Int? {
        guard let id else { return nil }
        return locations.firstIndex(where: { $0.id == id })
    }
    
    func location(with id: UUID) -> LocationModel? {
        locations.first(where: { $0.id == id })
    }
    
    func contains(_ location: LocationModel) -> Bool {
        contains(location.id)
    }
    
    func contains(_ id: LocationModel.ID?) -> Bool {
        locationIndex(id) != nil
    }
    
    func update(_ location: LocationModel) {
        if let index = locationIndex(location.id) {
            locations[index] = location
        }
    }
    
    func delete(_ location: LocationModel) {
        delete(location.id)
    }
    
    func delete(_ id: LocationModel.ID) {
        if let index = locationIndex(id) {
            locations.remove(at: index)
        }
    }
}

extension WeatherViewModel {
    func fetchCurrentWeatehr(for location: LocationModel) async {
        if let weatherModel = try? await weatherDataProvider.fetchCurrentWeather(for: location.name) {
            if let index = locationIndex(location.id) {
                locations[index].updateCurrentWeather(weatherModel)
                logger.debug("fetched current weather for location[\(index)] : \(location.name)")
            }
        }
    }

    // TODO: more of a UI op, move to view?...
    func formatedTemp(_ temp: Double?) -> String {
        if let temp = temp {
            // TODO: C/F support...
            return String(format: "%.0fºF", temp)
        }
        return "--ºF"
    }

}
