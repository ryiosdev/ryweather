//
//  ryweatherApp.swift
//  ryweather
//
//  Created by Ryan Young on 2/7/25.
//

import SwiftUI
import OSLog
import SwiftData

let logger = Logger(subsystem: "com.ryiosdev.ryweather", category: "general")

@main
struct RYWeatherApp: App {
    @State private var viewModel: WeatherViewModel
    @State private var selectedLocationId: LocationModel.ID?
    
    init() {
        let config = DefaultViewModelConfig()
        let viewModel = WeatherViewModel(config: config)
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                LocationList(selectedLocationId: $selectedLocationId, searchText: $viewModel.searchText)
            } detail: {
                LocationWeatherView(selectedLocationId: $selectedLocationId)
            }
            .environment(viewModel)
        }
    }
}
