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
    //saved locations...
    var locations: [LocationModel] = []
    
    var selectedTempUnit: WeatherTempModel.TempUnit
    
    var searchText: String = ""
    var searchResults: [LocationModel] = []
    var selectedSearchLocation: LocationModel?
    
    @ObservationIgnored private var modelContext: ModelContext
    @ObservationIgnored private var weatherDataProvider: WeatherDataProvider
    
    init(config: ViewModelConfiguration) {
        self.modelContext = config.modelContext()
        self.weatherDataProvider = config.weatherDataProvider()
        
        self.selectedTempUnit = .fahrenheit
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
    func fetchCurrentWeather(for location: LocationModel) async throws -> WeatherModel? {
        let weatherModel = try await weatherDataProvider.fetchCurrentWeather(for: location.searchText)
        return weatherModel
    }
        
    func onSearchTextChanged(from oldValue: String, to newValue: String) {
        // TODO: also add a debounce time buffer
        // TODO: also check the Task/threading, may need to queue these up
        if searchText.count >= 3 && oldValue != newValue  && newValue != selectedSearchLocation?.searchText {
            logger.debug("seaching due to searchText changing to : '\(newValue)'")
            Task {
                do {
                    let result = try await weatherDataProvider.search(for: newValue)
                    
                    //TODO: do we need the searchText String in the response model, it should match `self.searchText`
                    searchResults = result.locations
                } catch {
                    logger.error("failed to get search result: \(error)")
                }
            }
        } else if searchText.count < 3 {
            searchResults = []
        }
    }

    func onSubmitOfSearch() {
        logger.debug(">>> onSubmit of search: \(self.searchText) saving search matching location to 'selectedSearchLocation'")
        let location = searchResults.first { $0.searchText == self.searchText }
        guard let location = location else { return }
        Task {
            do {
                let weatherModel = try await weatherDataProvider.fetchCurrentWeather(for: location.searchText)
                
                // TODO:
//                selectedSearchLocation = //LocationModel(location.name, id: location.id, currentWeather: weatherModel)
                
                
            } catch {
                logger.error("onSubmit, failed to get searched weather data: \(error)")
                
            }
        }
    }
}
