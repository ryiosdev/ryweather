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
        if let location = viewModel.selectedLocation ?? viewModel.detailViewLocation {
            VStack {
                CurrentWeatherView(location: location, tempUnit: viewModel.selectedTempUnit)
                    .task {
                        if location.currentWeather == nil {
                            await viewModel.updateCurrentWeather(for: location)
                        }
                    }
                if !viewModel.locations.contains(where: {$0.id == location.id} ) {
                    Button("Add") {
                        withAnimation {
                            viewModel.add(location)
                            
                        }
                    }
                }
            }
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
            tempView()
            conditionImage()
            locationName()
            Group {
                Text(location.currentWeather?.condition.text ?? "Searching...") // the "Searching..." is a placeholder string for redaction
                Text("Feels Like: " + String(format: "%.0fº", location.currentWeather?.feelsLike(in: tempUnit) ?? "--"))
            }
            .foregroundStyle(.secondary)
            .redacted(reason: location.currentWeather == nil ? .placeholder : [])
        }
    }
    
    @ViewBuilder
    func tempView() -> some View {
        Group {
            if let temp = location.currentWeather?.temp(in: tempUnit) {
                Text(String(format: " %.0fº", temp)) //The extra white space is to help center the digits
            } else {
                Text("--")
            }
        }
        .font(.system(size: 64 * scale, weight: .light, design: .rounded))
    }
    
    @ViewBuilder
    func conditionImage() -> some View {
        // Don't show the `AsysncImage` if `currentWeather` (while loading) or the `iconUrl` is `nil`
        if let iconUrl = location.currentWeather?.condition.iconUrl {
            AsyncImage(url: URL(string: iconUrl)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                } else if phase.error != nil {
                    EmptyView()
                        .onAppear {
                            logger.debug("AsysncImage error: \(String(describing: phase.error!))")
                        }
                } else {
                    EmptyView()
                        .onAppear {
                            logger.debug("AsysncImage not loaded yet.")
                        }
                }
            }
            .frame(width: 100 * scale, height: 100 * scale)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder func locationName() -> some View {
        VStack {
            Text(location.name)
                .font(.title)
            Text(location.region)
                .font(.caption)
            Text(location.country)
                .font(.caption2)
        }
    }
}

