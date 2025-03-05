//
//  LocationWeatherView.swift
//  ryweather
//
//  Created by Ryan Young on 2/10/25.
//

import SwiftUI

struct LocationWeatherDetailView: View {
    @Bindable var viewModel: WeatherViewModel
    var body: some View {
        if let location = viewModel.selectedLocation {
            @Bindable var location = location
            VStack(spacing: 15) {
                CurrentWeatherView(location: location, tempUnit: viewModel.selectedTempUnit)
                if !viewModel.locations.contains(where: {$0.id == location.id} ) {
                    Button("Add") {
                        withAnimation {
                            viewModel.add(location)
                            
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }.task {
                location.currentWeather = await viewModel.getCurrentWeather(for: location.id)
            }
        } else {
            Text("Select a Location")
                .foregroundStyle(.secondary)
        }
    }
}

struct CurrentWeatherView: View {
    @ScaledMetric var scale: CGFloat = 1.0
    @Bindable var location: LocationModel
    var tempUnit: WeatherTempModel.TempUnit

    var body: some View {
        VStack(spacing: 5) {
            VStack {
                tempText()
                    .font(.system(size: 64 * scale, weight: .light, design: .rounded))
                feelsLIkeText()
                    .foregroundStyle(.secondary)
            }

            VStack {
                if let url = location.currentWeather?.condition.iconUrl {
                    CacheableImage(url: url)
                        .frame(width: 64 * scale, height: 64 * scale)
                }
                conditionText()
                    .foregroundStyle(.secondary)
            }
            
            VStack {
                Text(location.name)
                    .font(.headline)
                Text("\(location.region), \(location.country)")
                    .font(.subheadline)
            }
        }
    }
    
    @ViewBuilder func tempText() -> some View {
        if let temp = location.currentWeather?.temp(in: tempUnit) {
            Text(String(format: "%.0fº", temp))
        } else {
            Text("--")
        }
    }
    
    @ViewBuilder func feelsLIkeText() -> some View {
        if let feelsLike = location.currentWeather?.feelsLike(in: tempUnit) {
            Text("Feels Like: " + String(format: "%.0fº", feelsLike))
        } else {
            Text("Feels Like: --")
        }
    }
    
    @ViewBuilder func conditionText() -> some View {
        Text(location.currentWeather?.condition.text ?? "Searching...")
    }
}
