//
//  RYWeatherAppModels.swift.swift
//  ryweather
//
//  Created by Ryan Young on 2/8/25.
//
import Foundation

struct LocationSearchResultModel: Identifiable, Hashable {
    let id = UUID()
    var userQueryString: String
    var locations: [LocationModel]
}

struct LocationModel: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var currentWeather: WeatherModel?
}

struct WeatherModel: Hashable {
    var temp: Double
    var feelsLike: Double?
    var isDay = true
    var condition: WeatherConditionModel?
}

struct WeatherConditionModel: Hashable {
    var text: String
    var iconUrl: String
}

