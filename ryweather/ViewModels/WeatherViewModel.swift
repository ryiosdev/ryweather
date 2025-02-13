//
//  WeatherViewModel.swift
//  ryweather
//
//  Created by Ryan Young on 2/8/25.
//

import Foundation
import Observation
import SwiftData

@Observable @MainActor
class WeatherViewModel {
    static let defaultLocations: [LocationModel] = [LocationModel("San Antonio", id: 0),
                                                    LocationModel("New York", id: 1),
                                                    LocationModel("London", id: 2),
                                                    LocationModel("Anchorage", id: 3),
                                                    LocationModel("Tokyo", id: 4)]
    var locations: [LocationModel]
    var selectedTempUnit: WeatherTempModel.TempUnit
    var searchText: String = ""
    
    var filteredLocations: [LocationModel] {
        guard !searchText.isEmpty else {
            return []
        }
        return locations.filter { location in
            location.name.lowercased().contains(searchText.lowercased())
        }
    }

        
    @ObservationIgnored private var weatherDataProvider: WeatherDataProvider?
    
    init(_ locs: [LocationModel] = WeatherViewModel.defaultLocations,
         _ temp: WeatherTempModel.TempUnit = .fahrenheit,
         _ provider: WeatherDataProvider? = WeatherAPIDataSource(apiKey: UserDefaults.standard.string(forKey: "apikey") ?? "")) {
        self.locations = locs
        self.selectedTempUnit = temp
        self.weatherDataProvider = provider
    }
    
    //CRUD operations for locations array.
    func add(_ location: LocationModel) {
        locations.append(location)
    }
    
    func locationIndex(_ id: LocationModel.ID?) -> Int? {
        guard let id else { return nil }
        return locations.firstIndex(where: { $0.id == id })
    }
    
    func location(with id: Int?) -> LocationModel? {
        guard let id else { return nil }
        return locations.first(where: { $0.id == id })
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
        if let index = locationIndex(id), locations.count > 1 {
            locations.remove(at: index)
        }
    }
}

// Sharde helper model transformation functions
extension WeatherViewModel {
    func tempUnitString(_ unit: WeatherTempModel.TempUnit) -> String {
        switch(unit) {
        case .celsius:
            return "C"
        case .fahrenheit:
            return "F"
        @unknown default: // Future Kelvin support? 
            return ""
        }
    }
    
    func fetchCurrentWeather(for location: LocationModel) async throws {
        if let weatherModel = try await weatherDataProvider?.fetchCurrentWeather(for: location.name) {
            if let index = locationIndex(location.id) {
                locations[index] = LocationModel(location.name, id: location.id, currentWeather: weatherModel)
            }
        }
    }
    
    func search(for description: String) async throws {
        logger.debug(">>> searching for \(description)...")
        try await weatherDataProvider?.search(for: description)
    }
}
