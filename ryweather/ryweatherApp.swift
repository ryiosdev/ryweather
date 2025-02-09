//
//  ryweatherApp.swift
//  ryweather
//
//  Created by Ryan Young on 2/7/25.
//

import SwiftUI
import SwiftData

@main
struct ryweatherApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Item.self, LocationModel.self])
        }
    }
}
