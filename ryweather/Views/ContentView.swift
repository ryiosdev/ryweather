//
//  ContentView.swift
//  ryweather
//
//  Created by Ryan Young on 3/1/25.
//

import SwiftUI

struct ContentView: View {
    @Bindable var viewModel: WeatherViewModel

    @State private var selectedLocationId: LocationModel.ID?
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all), preferredCompactColumn: .constant(.sidebar)) {
            LocationList(selectedLocationId: $selectedLocationId, searchText: $viewModel.searchText)
        } detail: {
            LocationWeatherView(selectedLocationId: $selectedLocationId)
        }
    }
}
