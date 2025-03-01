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
                        .searchCompletion(suggestion.searchText ?? "")
                }
            })
        }
        .onChange(of: searchText) { oldValue, newValue in
            viewModel.onSearchTextChanged(from: oldValue, to: newValue)
        }
        .onSubmit(of: .search) {
            //deselect anytyhing previously saved and shown.
            selectedLocationId = nil
            // TODO: programatically push to detail view
            viewModel.onSubmitOfSearch()
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

        }
    }
}

