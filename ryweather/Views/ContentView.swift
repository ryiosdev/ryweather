//
//  ContentView.swift
//  ryweather
//
//  Created by Ryan Young on 3/1/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Bindable var viewModel: WeatherViewModel

    private var isSheetDetailPresented: Binding<Bool> { Binding (
        get: {
            guard horizontalSizeClass == .compact else { return false }
            if let detailViewLocation = viewModel.detailViewLocation {
                return detailViewLocation.savedAt == nil 
            } else {
                return false
            }
        },
        set: { isPresented in
            if !isPresented {
                self.viewModel.onDismissOfSheetDetailView()
            }
        })
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all), preferredCompactColumn: .constant(.sidebar)) {
            LocationList(viewModel: viewModel)
        } detail: {
            LocationWeatherDetailView(viewModel: viewModel)
        }
        .sheet(isPresented: isSheetDetailPresented) {
            LocationWeatherDetailView(viewModel: viewModel)
        }
#if os(macOS)
        .searchable(text: $viewModel.searchText,
                    placement: .automatic,
                    prompt: "City Name, Airport, or Zip Code")
#else
        .searchable(text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "City Name, Airport, or Zip Code")
#endif
        .searchSuggestions {
            ForEach(viewModel.searchResults) { suggestedLocation in
                SuggestionRow(location: suggestedLocation)
                    .searchCompletion(suggestedLocation.searchText)
            }
        }
        .onChange(of: viewModel.searchText) { oldValue, newValue in
            viewModel.onSearchTextChanged(from: oldValue, to: newValue)
        }
        .onSubmit(of: .search) {
            withAnimation {
                viewModel.onSubmitOfSearch()
            }
        }
    }
}
