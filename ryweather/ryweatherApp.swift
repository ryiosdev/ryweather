//
//  ryweatherApp.swift
//  ryweather
//
//  Created by Ryan Young on 2/7/25.
//

import SwiftData
import SwiftUI

@main
struct ryweatherApp: App {
    let container: ModelContainer

    var body: some Scene {
        WindowGroup {
            ContentView(self.container.mainContext)
        }
        .modelContainer(container)
    }

    init() {
        container = try! ModelContainer(for: Item.self)
    }
}
