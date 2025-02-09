//
//  ContentView.swift
//  ryweather
//
//  Created by Ryan Young on 2/7/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    // ViewModels
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    @State private var viewModel: WeatherViewModel
    @State private var locationQuery = ""

    init(_ modelContext: ModelContext) {
        let weatherViewModel = WeatherViewModel(modelContext)
        _viewModel = State(initialValue: weatherViewModel)
    }

    var body: some View {
        NavigationSplitView {
            List {
                if let location = viewModel.currentLocation {
                    Text(location.name)
                }
                if let temp = viewModel.currentLocation?.currentWeather?.temp {
                    Text("Temp: \(temp)ºF")
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
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                ToolbarItem {
                    Button(action: queryWeather) {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)

        }
    }

    private func queryWeather() {
        Task {
            do {
                try await viewModel.fetchCurrentWeather(for: "San Antonio")
            } catch {
                print(error)
            }
            print("updated temp: \(String(describing: viewModel.currentLocation?.currentWeather?.temp))")
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

//#Preview {
//    ContentView
//        .modelContainer(for: Item.self, inMemory: true)
//}
