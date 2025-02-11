//
//  LocationList.swift
//  ryweather
//
//  Created by Ryan Young on 2/10/25.
//

import SwiftUI

struct LocationList: View {
    @Binding var selectedLocationId: LocationModel.ID?
    @Environment(WeatherViewModel.self) private var viewModel
    @State private var searchText: String = ""
    
    var body: some View {
        List(viewModel.locations, selection: $selectedLocationId) { location in
            NavigationLink(value: location.id) {
                HStack {
                    Text(location.name)
                    Spacer()
                    Text(viewModel.formatedTemp(location.currentWeather?.temp))
                }
            }
        }
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
#endif
        }
    }
}

//#Preview {
//    LocationList()
//}
