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
        logger.debug("Added location : \(location.name) id : \(location.id)")
        fetchSavedLocations()
    }
    
    func delete(location: LocationModel) {
        location.savedAt = nil
        modelContext.delete(location)
        try? modelContext.save()
        fetchSavedLocations()
    }
}

// Actions and model transformation methods
@MainActor
extension WeatherViewModel {
    func updateCurrentWeather(for location: LocationModel) async {
        logger.debug("updating current weather for : \(location.name)")
        do {
            let weatherModel = try await weatherDataProvider.fetchCurrentWeather(for: "id:\(location.id)")
            await MainActor.run {
                location.currentWeather = weatherModel
            }
        } catch {
            logger.error("Error fetching weather: \(error)")
        }
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
                logger.error("failed to get search result: \(error)")
            }
        }
    }

    func onSubmitOfSearch() {
        logger.debug("on submit of search with text : '\(self.searchText)'")
        
        if let savedLocation = locations.first(where: { $0.searchText.lowercased() == searchText.lowercased()}) {
            selectedLocation = savedLocation
        } else if let location = searchResults[searchText] {
            detailViewLocation = location
        } else if let prefixMatchKey = orderedSearchResultsKeys.first(where: {
            $0.lowercased().hasPrefix(searchText.lowercased())
        }) {
            detailViewLocation = searchResults[prefixMatchKey]
        } else {
            // no match
            detailViewLocation = nil
        }
    }
    
    func onDismissOfSheetDetailView() {
        detailViewLocation = nil
    }
}
