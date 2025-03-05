//
//  LocationList.swift
//  ryweather
//
//  Created by Ryan Young on 2/10/25.
//

import SwiftUI

struct LocationList: View {
    @Bindable var viewModel: WeatherViewModel

    var body: some View {
        List(viewModel.locations, selection: $viewModel.selectedLocation) { location in
            @Bindable var location = location
            NavigationLink(value: location) {
                SavedLocationRow(location: location, tempUnit: viewModel.selectedTempUnit)
                    .task {
                        guard location.currentWeather == nil else { return }
                        let weather = await viewModel.getCurrentWeather(for: location.id)
                        location.currentWeather = weather
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            withAnimation {
                                viewModel.delete(location: location)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
#if os(macOS)
        .contextMenu(forSelectionType: LocationModel.self) { locations in
            Button("Delete", role: .destructive) {
                withAnimation {
                    for location in locations {
                        viewModel.delete(location: location)                }
                }
            }
        }
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
    }
}
