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

struct LocationModel {
    var name: String
    var currentWeather: WeatherModel?
}

struct WeatherModel  {
    var temp: Double
    var humidity: Int?
    var feelsLike: Double?
    var uvIndex: Double?
    var condition: WeatherConditionModel
}

struct WeatherConditionModel {
    var text: String
    var iconUrl: String?
}

