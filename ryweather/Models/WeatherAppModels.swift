//
//  RYWeatherAppModels.swift.swift
//  ryweather
//
//  Created by Ryan Young on 2/8/25.
//
import Foundation

struct LocationSearchResultModel: Identifiable, Hashable {
    let id = Int()
    var userQueryString: String
    var locations: [LocationModel]
}

struct LocationModel: Identifiable, Hashable {
    let id: Int
    var name: String
    var currentWeather: WeatherModel?
    
    init(_ name: String, id: Int = 0, currentWeather: WeatherModel? = nil) {
        self.name = name
        self.id = id
        self.currentWeather = currentWeather
    }
}

struct WeatherModel: Hashable {
    var temps: [WeatherTempModel]
    var condition: WeatherConditionModel
    
    func temp(in unit: WeatherTempModel.TempUnit) -> Double {
        temps.first(where: { $0.unit == unit })?.value ?? 0.0
    }
    
    func feelsLike(in unit: WeatherTempModel.TempUnit) -> Double? {
        temps.first(where: { $0.unit == unit })?.feelsLike
    }
}

struct WeatherTempModel: Hashable {
    enum TempUnit: String, CaseIterable {
        case celsius
        case fahrenheit
    }
    var unit: TempUnit
    var value: Double
    var feelsLike: Double?
}

struct WeatherConditionModel: Hashable {
    var text: String
    var iconUrl: String?
}
