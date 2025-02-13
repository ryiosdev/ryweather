//
//  WeatherDataProvider.swift
//  ryweather
//
//  Created by Ryan Young on 2/8/25.
//

import Foundation

protocol WeatherDataProvider {
    func search(for searchText: String) async throws -> LocationSearchResultModel
    func fetchCurrentWeather(for locationDescription: String) async throws -> WeatherModel
}

enum WeatherDataError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
