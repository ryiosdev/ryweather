//
//  RYWeatherAppModels.swift.swift
//  ryweather
//
//  Created by Ryan Young on 2/8/25.
//
import Foundation

struct LocationSearchResultModel: Identifiable, Codable {
    var id: UUID = UUID()
    var userQueryString: String
    var locations: [LocationModel]
}

struct LocationModel: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String?
    var currentWeather: WeatherModel?
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

