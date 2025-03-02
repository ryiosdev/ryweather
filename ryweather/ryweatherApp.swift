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
    private let config: ViewModelConfiguration
    
    @State private var viewModel: WeatherViewModel
        
    init() {
        var inMem = false
#if DEBUG
        //if within the preview or unit tests, use in mem storage
        if CommandLine.arguments.contains("debug_store_data_in_mem_only") {
            inMem = true
        }
#endif        
        let apiKey = UserDefaults.standard.string(forKey: "apikey") ?? ""
        
        config = DefaultViewModelConfig(inMemoryOnly: inMem, weatherAPIKey: apiKey)
        
        let viewModel = WeatherViewModel(modelContext: config.modelContainer.mainContext,
                                         weatherDataProvider: config.weatherDataProvider)
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
        .modelContainer(config.modelContainer)

    }
}
