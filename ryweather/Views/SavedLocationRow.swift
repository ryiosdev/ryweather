//
//  SavedLocationRow.swift
//  ryweather
//
//  Created by Ryan Young on 3/1/25.
//

import SwiftUI

struct SavedLocationRow: View {
    let location: LocationModel
    let tempUnit: WeatherTempModel.TempUnit
        
    var body: some View {
        HStack(spacing: 5) {
            Text(location.name)
            Spacer()
            if let weather = location.currentWeather {
                if let temp = weather.temp(in: tempUnit) {
                    Text(String(format: "%.0fº", temp))
                }
//                if let url = weather.condition.iconUrl {
//                    CacheableImage(url: url)
//                }
            }
        }
    }
}
