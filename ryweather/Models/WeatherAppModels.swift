//
//  RYWeatherAppModels.swift.swift
//  ryweather
//
//  Created by Ryan Young on 2/8/25.
//
import Foundation

struct LocationSearchResultModel {
    var searchText: String
    var locations: [LocationModel]
}

struct LocationModel: Identifiable, Hashable {
    let id: Int
    let name: String
    var region: String?
    var country: String?
    var searchText: String?
    var currentWeather: WeatherModel?
    
    init(_ name: String, id: Int = 0, currentWeather: WeatherModel? = nil) {
        self.name = name
        self.id = id
        self.currentWeather = currentWeather
    }
    
    init(id: Int, name: String, region: String, country: String, searchText: String) {
        self.id = id
        self.name = name
        self.region = region
        self.country = country
        self.searchText = searchText
    }
}

struct WeatherModel: Hashable {
    var temps: [WeatherTempModel]
    var condition: WeatherConditionModel
    
    func temp(in unit: WeatherTempModel.TempUnit) -> Double? {
        temps.first(where: { $0.unit == unit })?.value
    }
    
    func feelsLike(in unit: WeatherTempModel.TempUnit) -> Double? {
        temps.first(where: { $0.unit == unit })?.feelsLike
    }
}

struct WeatherTempModel: Hashable {
    enum TempUnit: String {
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
