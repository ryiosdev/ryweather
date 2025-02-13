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
                return LocationModel("")
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
        VStack(spacing: 5) {
            tempView()
            conditionImage()
            locationName()
            Group {
                Text(location.currentWeather?.condition.text ?? "searching...")
                Text("Feels Like: " + String(format: "%.0fº", location.currentWeather?.feelsLike(in: viewModel.selectedTempUnit) ?? "--"))
            }
            .foregroundStyle(.secondary)
            .redacted(reason: viewModel.shouldShowRedactedText(for: location) ? .placeholder : [])
        }
    }
    
    @ViewBuilder
    func tempView() -> some View {
        Group {
            if let temp = location.currentWeather?.temp(in: viewModel.selectedTempUnit) {
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
        Text(location.name)
            .font(.title)
    }
    
    func systemImageName(for unit: WeatherTempModel.TempUnit) -> String {
        switch (unit) {
        case .celsius:
            "degreesign.celsius"
        case .fahrenheit:
            "degreesign.fahrenheit"
        }
    }
}

#Preview(traits: .sampleWeatherViewModel) {
    @Previewable @State var id: LocationModel.ID? = 0
    LocationWeatherView(selectedLocationId: $id)
}
