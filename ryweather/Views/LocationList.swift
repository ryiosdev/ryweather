//
//  LocationList.swift
//  ryweather
//
//  Created by Ryan Young on 2/10/25.
//

import SwiftUI

struct LocationList: View {
    @Binding var selectedLocationId: LocationModel.ID?
    var viewModel: WeatherViewModel

    var body: some View {
        List(viewModel.locations, selection: $selectedLocationId) { location in
            NavigationLink(value: location.id) {
                locationRow(location)
            }
        }
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
    }
    
    @ViewBuilder func locationRow(_ location: LocationModel) -> some View {
        HStack {
            Text(viewModel.rowDisplayName(for: location))
            Spacer()
            Text(viewModel.formatedTemp(for: location))
        }.task {
            if location.currentWeather == nil {
                do {
                    try await viewModel.fetchCurrentWeatehr(for: location)
                } catch is CancellationError {
                    logger.error("fetch task : cancelled!?")
                } catch {
                    logger.error("fetch task : This is fine! \(error)")
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedLocationId: LocationModel.ID? = UUID()
    @Previewable let mockViewModel = WeatherViewModel(nil, [.init(name: "Sample Location",
                                                                  currentWeather: .init(temps: [.init(unit: .fahrenheit, value: 90)],
                                                                                        condition: .init(text: "cloudy")))])
    LocationList(selectedLocationId: $selectedLocationId, viewModel: mockViewModel)
}
