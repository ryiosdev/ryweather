//
//  LocationWeatherView.swift
//  ryweather
//
//  Created by Ryan Young on 2/10/25.
//

import SwiftUI

struct LocationWeatherView: View {
    @Binding var selectedLocationId: LocationModel.ID?
    @Environment(WeatherViewModel.self) private var viewModel

    private var location: Binding<LocationModel> {
        Binding {
            guard let id = selectedLocationId, let loc = viewModel.location(with: id) else {
                return LocationModel(name: "")
            }
            return loc
        } set: { updatedLocation in
            viewModel.update(updatedLocation)
        }
    }
    
    var body: some View {
        ZStack {
            if viewModel.contains(selectedLocationId) {
                CurrentWeatherView(location: location)
                    .navigationTitle(location.wrappedValue.name)
            } else {
                Text("Select a Location")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct CurrentWeatherView: View {
    @Environment(WeatherViewModel.self) private var viewModel
    @ScaledMetric var scale: CGFloat = 1.0
    @Binding var location: LocationModel

    var body: some View {
        VStack(spacing: 10) {
            Text(location.name)
                .font(.title)
            HStack {
                // Don't show the `AsysncImage` if `currentWeather` (while loading) or the `iconUrl` is `nil`
                // when `location` get trigger for an update, it will
                if let iconUrl = location.currentWeather?.condition.iconUrl {
                    AsyncImage(url: URL(string: iconUrl)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                                .onAppear {
                                    logger.debug("AsysncImage loaded")
                                }
                        } else if phase.error != nil {
                            Image(systemName: "bolt")
                                .onAppear {
                                    logger.debug("AsysncImage error: \(String(describing: phase.error!))")
                                }
                        } else {
                            EmptyView()
                                .onAppear {
                                    logger.debug("AsysncImage not loaded yet")
                                }
                        }
                    }
                    .frame(width: 64 * scale, height: 64 * scale)
                }
                
                Text(viewModel.formatedTemp(for: location))
                    .font(.largeTitle)
            }
            VStack {
                Text(viewModel.weatherConditionText(for: location))
                Text("Feels Like: " + viewModel.formatedFeelsLike(for: location))
            }
            .foregroundStyle(.secondary)
            .redacted(reason: viewModel.shouldShowRedactedText(for: location) ? .placeholder : [])
        }
    }
}

