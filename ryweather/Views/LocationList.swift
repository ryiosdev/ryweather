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
    @State private var selection: LocationModel?
    
    var body: some View {
        List(viewModel.locations, id: \.self, selection: $selection) { location in
            NavigationLink {
                LocationWeatherDetailView(viewModel: viewModel)
                    .onAppear {
                        viewModel.detailViewLocation = location
                    }
            } label: {
                SavedLocationRow(location: location, tempUnit: viewModel.selectedTempUnit)
                    .task {
                        await viewModel.updateCurrentWeather(for: location)
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
        .onChange(of: selection) { oldValue, newValue in
            print("selection changed from \(oldValue?.name ?? "") to \(newValue?.name ?? "")")
            viewModel.detailViewLocation = newValue
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
