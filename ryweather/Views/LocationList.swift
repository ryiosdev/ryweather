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
            .searchable(text: $searchText) {
                ForEach(viewModel.searchResult) { suggestion in
                    searchResultRow(suggestion)
                        .searchCompletion(suggestion.name)
                }
            }
        }
        .onSubmit(of: .search) {
            logger.debug(">>> searchText: \(searchText)")
            Task {
                try? await viewModel.searchLocationsUsingSearchText()
            }
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
            logger.debug(">>> search result tapped: \(String(describing: location))")
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
