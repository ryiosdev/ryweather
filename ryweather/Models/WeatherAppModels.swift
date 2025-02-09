//
//  RYWeatherAppModels.swift.swift
//  ryweather
//
//  Created by Ryan Young on 2/8/25.
//
import Foundation
import SwiftData

struct LocationSearchResultModel {
    var userQueryString: String
    var locations: [LocationModel]
}

@Model
class LocationModel: Identifiable {
    var id: UUID
    var name: String?
    @Transient var currentWeather: WeatherModel?
    
    init(id: UUID = UUID(), name: String? = nil, currentWeather: WeatherModel? = nil) {
        self.id = id
        self.name = name
        self.currentWeather = currentWeather
    }
}

struct WeatherModel: Identifiable, Codable {
    var id: UUID = UUID()
    var temp: Double
    var humidity: Int?
    var feelsLike: Double?
    var uvIndex: Double?
    var condition: WeatherConditionModel
}

struct WeatherConditionModel: Identifiable, Codable {
    var id: UUID = UUID()
    var text: String
    var iconUrl: String?
}

