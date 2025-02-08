//
//  ContentView.swift
//  ryweather
//
//  Created by Ryan Young on 2/7/25.
//

import SwiftUI
import SwiftData




struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    
    @State private var viewModel = WeatherSearchViewModel()
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
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
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
//        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
            
//        }
        Task {
            do {
                try await viewModel.updateCurrentLocation("78260")
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

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
