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
    
    init() {
        let config = DefaultViewModelConfig()
        let viewModel = WeatherViewModel(config: config)
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
            .environment(viewModel) //TODO: move this out of env..
        }
    }
}
