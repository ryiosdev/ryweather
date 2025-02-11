//
//  ContentView.swift
//  ryweather
//
//  Created by Ryan Young on 2/7/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    
    @State private var selectedLocationId: LocationModel.ID?
    
    init() {
        print("new ContentView")
    }
    
    var body: some View {
        NavigationSplitView {
            LocationList(selectedLocationId: $selectedLocationId)
        } detail: {
            LocationWeatherView(locationId: $selectedLocationId)
        }
    }
}

#Preview {
    ContentView()
}

