//
//  LocationWeatherView.swift
//  ryweather
//
//  Created by Ryan Young on 2/10/25.
//

import SwiftUI
import os

struct LocationWeatherView: View {
    let logger = Logger()
    @Binding var locationId: LocationModel.ID?
    @Environment(WeatherViewModel.self) private var viewModel
    @ScaledMetric var scale: CGFloat = 1.0
    
    private var location: Binding<LocationModel> {
        Binding {
            guard let id = locationId, let location = viewModel.location(with: id) else {
                return LocationModel(name: "")
            }
            return location
        } set: { newLocation in
            viewModel.update(newLocation)
        }
    }
    
    var body: some View {
        if !viewModel.contains(locationId) {
            Text("Select a Location")
                .foregroundStyle(.secondary)
        } else {
            //TODO: move this to a view builder..
            VStack(spacing: 10) {
                Text(location.wrappedValue.name)
                    .font(.title)
                HStack {
                    AsyncImage(url: URL(string: location.wrappedValue.currentWeather?.condition?.iconUrl ?? "")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                        } else if phase.error != nil {
                            Image(systemName: "bolt")
                        } else {
                            EmptyView()
                        }
                    }
                    .frame(width: scaledImageDimention(), height: scaledImageDimention())
                    
                    Text(formatedTemp(location.wrappedValue.currentWeather?.temp))
                        .font(.largeTitle)
                }
                VStack {
                    Text(location.wrappedValue.currentWeather?.condition?.text ?? "placeholder-condition")
                    Text("Feels Like: " + formatedTemp(location.wrappedValue.currentWeather?.feelsLike))
                }
                .foregroundStyle(.secondary)
                .redacted(reason: location.wrappedValue.currentWeather == nil ? .placeholder : [])
            }
        }
    }
    
    private func scaledImageDimention() -> CGFloat {
        location.wrappedValue.currentWeather != nil ? 64 * scale : 0
    }
    
    private func formatedTemp(_ temp: Double?) -> String {
        if let temp = temp {
            // TODO: C/F support...
            return String(format: "%.0fºF", temp)
        }
        return "--ºF"
    }
}

#Preview {
    //TODO: break this down into a viewBuilder for the preview
    @Previewable @State var locId: LocationModel.ID?
//    let condition = WeatherConditionModel(text: "Overcast", iconUrl: "https://cdn.weatherapi.com/weather/64x64/day/122.png")
//    let weather = WeatherModel(temp: 90,  feelsLike: 100, condition: condition)
//    let location = LocationModel(name: "San Antonio", currentWeather: weather)
//    
    LocationWeatherView(locationId: $locId)
}
