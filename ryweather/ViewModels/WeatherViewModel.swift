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
    var selectedLocation: LocationModel? //side bar selected item

    var selectedTempUnit: WeatherTempModel.TempUnit
    
    var searchText: String = ""
    var searchResults: [String : LocationModel] = [:]
    var orderedSearchResultsKeys: [String] = []
    
    
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
        logger.debug("Added location : \(location.name) id : \(location.id)")
        fetchSavedLocations()
    }
    
    func delete(location: LocationModel) {
        location.savedAt = nil
        modelContext.delete(location)
        try? modelContext.save()
        
        if let index = locations.firstIndex(of: location) {
            let beforeIndex = locations.index(before: index)
            if selectedLocation == location, beforeIndex >= locations.startIndex {
                selectedLocation = locations[beforeIndex]
            }
            locations.remove(at: index)
        }
        fetchSavedLocations()
    }
}

// Actions and model transformation methods
@MainActor
extension WeatherViewModel {
    func getCurrentWeather(for locationId: Int) async -> WeatherModel? {
        logger.debug("updating current weather for : \(locationId)")
        do {
            let weatherModel = try await weatherDataProvider.fetchCurrentWeather(for: "id:\(locationId)")
            return weatherModel
        } catch {
            logger.error("Error fetching weather: \(error.localizedDescription)")
        }
        return nil
    }

    func onSearchTextChanged(to newValue: String) {
        guard newValue.count >= 3 else {
            searchResults = [:]
            orderedSearchResultsKeys = []
            return
        }
        logger.debug("searchText triggered with newValue : '\(newValue)'")

        //TODO: save this task, only run new version if not already running, cancel on search submit.
        Task {
            do {
                var newSearchResults : [String: LocationModel] = [:]
                var orderedKeys: [String] = []
                
                let result = try await weatherDataProvider.search(for: newValue)
                logger.debug("task updating searchResults with count : \(result.locations.count)")
                result.locations.forEach { location in
                    orderedKeys.append(location.searchText)
                    newSearchResults[location.searchText] = location
                }
                
                searchResults = newSearchResults
                orderedSearchResultsKeys = orderedKeys
            } catch {
                logger.error("failed to get search result: \(error.localizedDescription)")
            }
        }
    }

    func onSubmitOfSearch() {
        logger.debug("on submit of search with text : '\(self.searchText)'")
        // note, the search doesn't need to be called again,
        // since the last text change would have triggered an update to search results.
        
        // if search matches a location already saved, select it
        if let savedLocation = locations.first(where: { $0.searchText.lowercased() == searchText.lowercased()}) {
            selectedLocation = savedLocation
        // if user tapped a search suggestion, then searchText will equal the search result key
        } else if let location = searchResults[searchText] {
            selectedLocation = location
        // if search results isn't empty, then auto-complete to the first search result
        } else if let key = orderedSearchResultsKeys.first {
            selectedLocation = searchResults[key]
        }
        
        //TODO: check if selected location's current weather was recently set (add timestamp to check against)
        if let selected = selectedLocation {
            Task {
                selected.currentWeather = await getCurrentWeather(for: selected.id)
            }
        }
    }
    
    func onDismissOfSheetDetailView() {
        selectedLocation = nil
    }
}
