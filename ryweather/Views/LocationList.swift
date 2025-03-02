//
//  LocationList.swift
//  ryweather
//
//  Created by Ryan Young on 2/10/25.
//

import SwiftUI

struct LocationList: View {
#if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#endif
    @Bindable var viewModel: WeatherViewModel
    
    var body: some View {
        List() {//selection: $viewModel.selectedLocationId) {
            ForEach(viewModel.locations, id: \.id) { location in
                SavedLocationRow(location: location, tempUnit: viewModel.selectedTempUnit)
                    .task {
                        await viewModel.updateCurrentWeather(for: location)
                    }
                    .onTapGesture {
                        //TODO: this is still a bit backwards, the List's selection binding should drive what's in the view (
                        viewModel.detailViewLocation = location
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            withAnimation {
                                viewModel.delete(location: location)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
#if os(macOS)
        // macOS right click delete
//        .contextMenu(forSelectionType: Item.ID.self) { ids in
//            // if at least one side bar row selected
//            if viewModel.shouldShowDeleteButton(for: ids) {
//                Button("Delete", role: .destructive) {
//                    withAnimation {
//                        viewModel.deleteSideBarItems(ids: ids)
//                    }
//                }
//            }
//        }
//        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
    }
}
