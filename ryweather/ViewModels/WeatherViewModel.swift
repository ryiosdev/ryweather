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
    var selectedLocationId: LocationModel.ID?

    var selectedTempUnit: WeatherTempModel.TempUnit
    
    var searchText: String = ""
    var searchResults: [LocationModel] = []
    var selectedSearchLocation: LocationModel?
    
    private var modelContext: ModelContext
    @ObservationIgnored private var weatherDataProvider: WeatherDataProvider
    
    init(modelContext: ModelContext, weatherDataProvider: WeatherDataProvider) {
        self.modelContext = modelContext
        self.weatherDataProvider = weatherDataProvider
        self.selectedTempUnit = .fahrenheit
        
        fetchSavedLocations()
    }
    
    private func fetchSavedLocations() {
        do {
            let descriptor = FetchDescriptor<LocationModel>(sortBy: [SortDescriptor(\.savedAt)])
            locations = try modelContext.fetch(descriptor)
        } catch {
            print("Fetch failed")
        }
    }
    
    //CRUD operations for locations array.
    func add(_ location: LocationModel) {
        location.savedAt = Date()
        modelContext.insert(location)
        try? modelContext.save()
        fetchSavedLocations()
    }
    
    func locationIndex(_ id: LocationModel.ID?) -> Int? {
        guard let id else { return nil }
        return locations.firstIndex(where: { $0.id == id })
    }
    
    func location(with id: Int?) -> LocationModel? {
        guard let id else { return nil }
        return locations.first(where: { $0.id == id })
    }
    
    func delete(location: LocationModel) {
        location.savedAt = nil
        modelContext.delete(location)
        try? modelContext.save()
        fetchSavedLocations()
    }
    
    func showDetailsForSaved(location: LocationModel) {
        selectedLocationId = location.id
        selectedSearchLocation = nil
    }
}

// Actions and model transformation methods
extension WeatherViewModel {
    func fetchCurrentWeather(for location: LocationModel) async throws {
        let weatherModel = try await weatherDataProvider.fetchCurrentWeather(for: location.searchText)
        location.currentWeather = weatherModel
        try? modelContext.save()
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
//                try await fetchCurrentWeather(for: location)
                // TODO:

                //TEMP HACK
                add(location)
                
            } catch {
                logger.error("onSubmit, failed to get searched weather data: \(error)")
                
            }
        }
    }
}
