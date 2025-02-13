//
//  ryweatherApp.swift
//  ryweather
//
//  Created by Ryan Young on 2/7/25.
//

import SwiftUI
import OSLog

let logger = Logger(subsystem: "com.ryweather.ryweather", category: "general")

@main
struct ryweatherApp: App {
    @State private var viewModel = WeatherViewModel()
    @State private var selectedLocationId: LocationModel.ID?
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

// global preview helper to set mock WeatherViewModel
struct SampleWeatherViewModel: PreviewModifier {
    typealias Context = WeatherViewModel
    
    struct SampleWeatherDataProvider: WeatherDataProvider {
        func search(for searchText: String) async throws -> LocationSearchResultModel {
            LocationSearchResultModel(searchText: searchText, locations: [LocationModel("San Jose")])
        }
        
        func fetchCurrentWeather(for locationDescription: String) async throws -> WeatherModel {
            return WeatherModel(temps: [.init(unit: .fahrenheit, value: 90), .init(unit: .celsius, value: 32)],
                         condition: .init(text: "Partly Cloudy",
                                          iconUrl: "https://cdn.weatherapi.com/weather/64x64/night/116.png"))
        }
    }
    
    static func makeSharedContext() async throws -> Context {
        
        let viewModel = WeatherViewModel(WeatherViewModel.defaultLocations, .fahrenheit, SampleWeatherDataProvider())
        for location in viewModel.locations {
            do {
                try await viewModel.fetchCurrentWeather(for: location)
            } catch {
                print("preview caught error while calling fetchCurrentWeather")
            }
        }
        return viewModel
    }
    
    func body(content: Content, context: Context) -> some View {
        return content.environment(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleWeatherViewModel: Self = .modifier(SampleWeatherViewModel())
}
