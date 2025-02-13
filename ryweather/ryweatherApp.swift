//
//  ryweatherApp.swift
//  ryweather
//
//  Created by Ryan Young on 2/7/25.
//

import SwiftUI
import OSLog

let logger = Logger(subsystem: "com.ryweather.ryweather", category: "general    ")

@main
struct ryweatherApp: App {
    @State private var viewModel = WeatherViewModel()
    @State private var selectedLocationId: LocationModel.ID?

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                LocationList(selectedLocationId: $selectedLocationId, viewModel: viewModel)
            } detail: {
                LocationWeatherView(selectedLocationId: $selectedLocationId)
            }
            .environment(viewModel)

        }
    }
}
