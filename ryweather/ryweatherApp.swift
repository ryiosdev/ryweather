//
//  ryweatherApp.swift
//  ryweather
//
//  Created by Ryan Young on 2/7/25.
//

import SwiftUI

@main
struct ryweatherApp: App {
    @State private var viewModel = WeatherViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)

        }
    }
}
