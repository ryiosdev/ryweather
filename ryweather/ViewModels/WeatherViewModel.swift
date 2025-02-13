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
    func formatedTemp(for location: LocationModel) -> String {
        if let temp = location.currentWeather?.temp(in: self.selectedTempUnit) {
            return String(format: "%.0fº", temp) //+ formattedTempUnit()
        }
        return "--"
    }

    func weatherConditionText(for location: LocationModel) -> String {
        location.currentWeather?.condition.text ?? "searching..."
    }
    
    func shouldShowRedactedText(for location: LocationModel) -> Bool {
        location.currentWeather == nil
    }
    
    func formattedTempUnit() -> String {
        switch(selectedTempUnit) {
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
}
