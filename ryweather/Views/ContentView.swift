//
//  ContentView.swift
//  ryweather
//
//  Created by Ryan Young on 2/7/25.
//

import SwiftData
import SwiftUI
import os

struct ContentView: View {
    private let logger = Logger()
    @State private var selectedLocationId: LocationModel.ID?
    
    init() {
        logger.debug("new ContentView")
    }
    
    var body: some View {
        NavigationSplitView {
            LocationList(selectedLocationId: $selectedLocationId)
        } detail: {
            LocationWeatherView(locationId: $selectedLocationId)
        }.onAppear {
            logger.debug("Contentview appeared")
        }
    }
}

#Preview {
    ContentView()
}

