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
class LocationModel {
    var name: String
    var currentWeather: WeatherModel?
    
    init(name: String, currentWeather: WeatherModel? = nil) {
        self.name = name
        self.currentWeather = currentWeather
    }
}

@Model
class WeatherModel  {
    var temp: Double
    var humidity: Int?
    var feelsLike: Double?
    var uvIndex: Double?
    var condition: WeatherConditionModel
    
    init(temp: Double, humidity: Int? = nil, feelsLike: Double? = nil, uvIndex: Double? = nil, condition: WeatherConditionModel) {
        self.temp = temp
        self.humidity = humidity
        self.feelsLike = feelsLike
        self.uvIndex = uvIndex
        self.condition = condition
    }
}

@Model
class WeatherConditionModel {
    var text: String
    var iconUrl: String?
    
    init(text: String, iconUrl: String? = nil) {
        self.text = text
        self.iconUrl = iconUrl
    }
}

