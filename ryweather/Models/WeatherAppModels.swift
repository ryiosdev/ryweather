//
//  RYWeatherAppModels.swift.swift
//  ryweather
//
//  Created by Ryan Young on 2/8/25.
//
import Foundation
import SwiftData

struct LocationSearchResultModel {
    var searchText: String
    var locations: [LocationModel]
}

@Model
class LocationModel: Identifiable, Hashable {
    @Attribute(.unique) var id: Int
    var name: String
    var region: String
    var country: String
    var searchText: String
    var savedAt: Date?
    @Attribute(.ephemeral) var currentWeather: WeatherModel? = nil
    
    init(id: Int, name: String, region: String, country: String, searchText: String) {
        self.id = id
        self.name = name
        self.region = region
        self.country = country
        self.searchText = searchText
    }
}

struct WeatherModel: Codable, Equatable {
    var temps: [WeatherTempModel]
    var condition: WeatherConditionModel
    
    func temp(in unit: WeatherTempModel.TempUnit) -> Double? {
        temps.first(where: { $0.unit == unit })?.value
    }
    
    func feelsLike(in unit: WeatherTempModel.TempUnit) -> Double? {
        temps.first(where: { $0.unit == unit })?.feelsLike
    }
}

struct WeatherTempModel: Codable, Equatable {
    enum TempUnit: String, Codable {
        case celsius
        case fahrenheit
    }
    var unit: TempUnit
    var value: Double
    var feelsLike: Double?
}

struct WeatherConditionModel: Codable, Equatable {
    var text: String
    var iconUrl: URL?
}
