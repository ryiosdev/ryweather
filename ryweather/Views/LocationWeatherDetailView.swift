//
//  LocationWeatherView.swift
//  ryweather
//
//  Created by Ryan Young on 2/10/25.
//

import SwiftUI

struct LocationWeatherDetailView: View {
    @Bindable var viewModel: WeatherViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        if let location = viewModel.selectedLocation {
            @Bindable var location = location
            VStack {
                CurrentWeatherView(location: location, tempUnit: viewModel.selectedTempUnit)
                if !viewModel.locations.contains(where: {$0.id == location.id} ) {
                    Button("Add") {
                        withAnimation {
                            viewModel.add(location)
                            
                        }
                    }
                }
            }
//            .redacted(reason: location.currentWeather == nil ? .placeholder : [])
        } else {
            Text("Select a Location")
                .foregroundStyle(.secondary)
        }
    }
}

struct CurrentWeatherView: View {
    @ScaledMetric var scale: CGFloat = 1.0
    var location: LocationModel
    var tempUnit: WeatherTempModel.TempUnit

    var body: some View {
        VStack(spacing: 5) {
            
            VStack {
                Text(tempText())
                    .font(.system(size: 64 * scale, weight: .light, design: .rounded))
                Text(feelsLIkeText())
                    .foregroundStyle(.secondary)
            }

            if let url = weatherIconURL() {
                AsyncImage(url: url) { image in
                    image
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 64 * scale, height: 64 * scale)
            }
            Text(conditionText())
                .foregroundStyle(.secondary)
            
            Text(location.name)
                .font(.headline)
            Text("\(location.region), \(location.country)")
                .font(.subheadline)
        }
    }
    
    private func tempText() -> String {
        if let temp = location.currentWeather?.temp(in: tempUnit) {
            return String(format: "%.0fº", temp)
        } else {
            return "--"
        }
    }
    
    private func weatherIconURL() -> URL? {
        if let iconURL = location.currentWeather?.condition.iconUrl {
            return URL(string: iconURL)
        }
        return nil
    }
    
    private func feelsLIkeText() -> String {
        if let feelsLike = location.currentWeather?.feelsLike(in: tempUnit) {
            return "Feels Like: " + String(format: "%.0fº", feelsLike)
        } else {
            return "Feels Like: --"
        }
    }
    
    private func conditionText() -> String {
        location.currentWeather?.condition.text ?? "Searching..."
    }
}
