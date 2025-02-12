//
//  LocationList.swift
//  ryweather
//
//  Created by Ryan Young on 2/10/25.
//

import SwiftUI
import os

struct LocationList: View {
    private let logger = Logger()

    @Binding var selectedLocationId: LocationModel.ID?
    @Environment(WeatherViewModel.self) private var viewModel
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            if (viewModel.locations.isEmpty) {
                placeolderRow()
            } else {
                List(viewModel.locations, selection: $selectedLocationId) { location in
                    NavigationLink(value: location.id) {
                        locationRow(location)
                    }
                }
                .navigationDestination(for: LocationModel.self) { _ in
                    LocationWeatherView(locationId: $selectedLocationId)
                }
                .onAppear {
                    logger.debug("LocationList appeared")
                }
            }
        }
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
#endif
        }
    }
    
    @ViewBuilder func locationRow(_ location: LocationModel) -> some View {
        HStack {
            Text(location.name)
            Spacer()
            Text(viewModel.formatedTemp(location.currentWeather?.temp))
        }.task {
            await viewModel.fetchCurrentWeatehr(for: location)
        }
    }
    
    @ViewBuilder func placeolderRow() -> some View {
        HStack {
            Button("Select a location") {
                bringUpSearch()
            }
        }
    }
    func bringUpSearch() {
        logger.debug("bring up search")

    }

}

//#Preview {
//    LocationList()
//}
