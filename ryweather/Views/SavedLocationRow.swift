//
//  SavedLocationRow.swift
//  ryweather
//
//  Created by Ryan Young on 3/1/25.
//

import SwiftUI

struct SavedLocationRow: View {
    var location: LocationModel
    var tempUnit: WeatherTempModel.TempUnit
    
    var body: some View {
        HStack {
            Text(location.name)
            Spacer()
            if let temp = location.currentWeather?.temp(in: tempUnit) {
                Text(String(format: "%.0fº", temp))
            }
        }
    }
}
