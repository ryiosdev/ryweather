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
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all), preferredCompactColumn: .constant(.sidebar)) {
            LocationList(viewModel: viewModel)
        } detail: {
            NavigationStack {
                LocationWeatherDetailView(viewModel: viewModel)
            }
            .navigationBarBackButtonHidden(false)
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
            ForEach(viewModel.orderedSearchResultsKeys, id: \.self) { searchTextKey in
                if let location = viewModel.searchResults[searchTextKey] {
                    SuggestionRow(location: location)
                        .searchCompletion(searchTextKey)
                }
            }
        }
        .onChange(of: viewModel.searchText) { _, newValue in
            withAnimation{
                viewModel.onSearchTextChanged(to: newValue)
            }
        }
        .onSubmit(of: .search) {
//            withAnimation {
                viewModel.onSubmitOfSearch()
//            }
        }
    }
}
