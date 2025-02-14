//
//  LocationList.swift
//  ryweather
//
//  Created by Ryan Young on 2/10/25.
//

import SwiftUI

struct LocationList: View {
    @Binding var selectedLocationId: LocationModel.ID?
    @Binding var searchText: String
    
    @Environment(WeatherViewModel.self) private var viewModel
    @Environment(\.isSearching) var isSearching

    var body: some View {
        NavigationStack {
            List(viewModel.locations, selection: $selectedLocationId) { location in
                NavigationLink(value: location.id) {
                    locationRow(location)
                }
            }
            .searchable(text: $searchText, suggestions: {
                ForEach(viewModel.searchResults) { suggestion in
                    searchResultRow(suggestion)
                        .searchCompletion("")
                }
            })
        }
        .onChange(of: searchText, { oldValue, newValue in
            // TODO: move this logic to ViewModel
            // also add a debounce time buffer
            // also check the Task/threading, may need to queue these up
            if searchText.count > 2 && oldValue != newValue {
                logger.debug("? : \(searchText)")
                Task {
                    do {
                        try await viewModel.searchForLocationsUsingSearchText()
                    } catch {
                        logger.error("failed to get search result: \(error)")
                    }
                }
            }
        })
        .onSubmit(of: .search) {
            selectedLocationId = nil
            viewModel.selectedSearchLocation = viewModel.searchResults.first
            logger.debug(">>> onSubmit of search: \(String(describing: viewModel.selectedSearchLocation))")
        }
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
    }
    
    @ViewBuilder func locationRow(_ location: LocationModel) -> some View {
        HStack {
            Text(location.name)
            Spacer()
            if let temp = location.currentWeather?.temp(in: viewModel.selectedTempUnit) {
                Text(String(format: "%.0fº", temp))
            }
        }.task {
            if location.currentWeather == nil {
                do {
                    try await viewModel.fetchCurrentWeather(for: location)
                } catch is CancellationError {
                    logger.warning("fetch task : cancelled!? (maybe view disappeared)")
                } catch {
                    logger.error("fetch task : This is fine! \(error)")
                }
            }
        }
    }
    
    @ViewBuilder func searchResultRow(_ location: LocationModel) -> some View {
        VStack(alignment: .leading) {
            Text(location.name + (location.region == nil ? "" : ", " + location.region!))
            Text(location.country ?? "")
                .font(.caption)
        }.onTapGesture {
            selectedLocationId = nil
            viewModel.selectedSearchLocation = location
            logger.debug(">>> search result tapped: \(String(describing: viewModel.selectedSearchLocation))")
        }
    }
}

#Preview(traits: .sampleWeatherViewModel) {
    @Previewable @State var id: LocationModel.ID? = 0
    @Previewable @State var searchText: String = ""
    NavigationStack {
        LocationList(selectedLocationId: $id, searchText: $searchText)
    }
}
