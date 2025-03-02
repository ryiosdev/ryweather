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
//    var selectedLocationId: LocationModel.ID?

    var selectedTempUnit: WeatherTempModel.TempUnit
    
    var searchText: String = ""
    var searchResults: [LocationModel] = []
    
    var detailViewLocation: LocationModel?
    
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
            logger.error("Fetch failed : \(error)")
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
}

// Actions and model transformation methods
extension WeatherViewModel {
    func updateCurrentWeather(for location: LocationModel) async {
        logger.debug("updating current weather for : \(location.name)")
        do {
            let weatherModel = try await weatherDataProvider.fetchCurrentWeather(for: location.searchText)
            location.currentWeather = weatherModel
            if locations.contains(location) {
                try modelContext.save()
            }
        } catch {
            logger.error("Error fetching weather: \(error)")
        }
    }

    func onSearchTextChanged(from oldValue: String, to newValue: String) {
        // TODO: also add a debounce time buffer
        // TODO: also check the Task/threading, may need to queue these up
        if searchText.count >= 3 && oldValue != newValue  && newValue != detailViewLocation?.searchText {
            logger.debug("searching due to searchText changing to : '\(newValue)'")
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
        logger.debug("on submit of search with text : '\(self.searchText)'")
        if let location = searchResults.first(where: { $0.searchText == self.searchText }) {
            detailViewLocation = location
        } else {
            // check for partial matches
            let locations = searchResults.filter( { $0.name.lowercased().contains(searchText.lowercased()) } )
            
            // if partial match, auto complete to the first item in the list.
            if locations.count > 0 {
                detailViewLocation = searchResults[0]
            } else {
                // no match
                detailViewLocation = nil
            }
        }
        if let location = detailViewLocation {
            searchText = ""
            Task {
                await updateCurrentWeather(for: location)
            }
        }
    }
    
    func onDismissOfSheetDetailView() {
        detailViewLocation = nil
    }
}
