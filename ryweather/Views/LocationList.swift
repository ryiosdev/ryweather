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
        List(selection: $viewModel.selectedLocationId) {
            ForEach(viewModel.locations) { location in
                SavedLocationRow(location: location, tempUnit: viewModel.selectedTempUnit)
                    .task {
                        do {
                            try await viewModel.fetchCurrentWeather(for: location)
                        } catch {
                            logger.error("Error fetching weather: \(error)")
                        }
                    }
                    .onTapGesture {
                        viewModel.showDetailsForSaved(location: location)
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
#if os(iOS)
//        // TODO: maybe it makes more sense to put this in DetailView or ContainerView
//        .sheet(isPresented: $viewModel.isSheetDetailPresented,
//               onDismiss: {
//            withAnimation {
//                viewModel.onDismissOfSheetDetailView()
//            }
//        }, content: {
//            SheetDetailView(viewModel: viewModel)
//        })
#elseif os(macOS)
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
