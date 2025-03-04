//
//  LocationList.swift
//  ryweather
//
//  Created by Ryan Young on 2/10/25.
//

import SwiftUI

struct LocationList: View {
#if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#endif
    @Bindable var viewModel: WeatherViewModel

    var body: some View {
        List(viewModel.locations, id: \.self, selection: $viewModel.selectedLocation) { location in
            NavigationLink(value: location) {
                SavedLocationRow(location: location, tempUnit: viewModel.selectedTempUnit)
                    .task {
                        await viewModel.updateCurrentWeather(for: location)
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
