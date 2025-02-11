//
//  WeatherDataProvider.swift
//  ryweather
//
//  Created by Ryan Young on 2/8/25.
//

import Foundation
import os

protocol WeatherDataProvider {
    func search(for location: String) async throws -> LocationSearchResultModel
    func fetchCurrentWeather(for location: String) async throws -> LocationModel
}

enum WeatherDataError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

struct WeatherAPIDataSource {
    static let logger = Logger()
    let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
        WeatherAPIDataSource.logger.debug("new WeatherAPIDataSource with apiKey: \(apiKey)")
    }

    enum EndpointURIs: String {
        case current = "/current.json"
        case search = "/search.json"
    }
        
    private func urlWithAPIKey(_ scheme: String = "https://",
                               _ domain: String = "api.weatherapi.com",
                               _ version: String = "/V1",
                               endpoint: EndpointURIs) throws -> URL {
        
        guard let url = URL(string: scheme + domain + version + endpoint.rawValue) else {
            throw WeatherDataError.invalidURL
        }
        return url.appending(queryItems: [URLQueryItem(name: "key", value: apiKey)])
    }
}

extension WeatherAPIDataSource: WeatherDataProvider {
    func search(for location: String) async throws -> LocationSearchResultModel {
        let url = try urlWithAPIKey(endpoint: .search).appending(queryItems: [URLQueryItem(name: "q", value: location)])
        
        WeatherAPIDataSource.logger.debug("search url = \(url)")
        //TODO: add search
        //return LocationSearchResultModel(userQueryString: "", locations: [])
        throw WeatherDataError.invalidData
    }

    func fetchCurrentWeather(for location: String) async throws -> LocationModel {
        let url = try urlWithAPIKey(endpoint: .current).appending(queryItems: [URLQueryItem(name: "q", value: location)])

        WeatherAPIDataSource.logger.debug("current weather url = \(url)")

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            WeatherAPIDataSource.logger.warning("non-200 response: \(String(describing: response))")
            throw WeatherDataError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let jsonModel = try decoder.decode(CurrentWetherJsonResponse.self, from: data)
            return jsonModel.toLocationModel()
        } catch {
            WeatherAPIDataSource.logger.error("failed to decode json: \(error)")
            throw WeatherDataError.invalidData
        }
    }
    
    //https://www.weatherapi.com/docs/#apis-realtime
    private struct CurrentWetherJsonResponse: Codable {
        let location: Location
        let current: Current
        
        struct Location: Codable {
            let name: String
            let region: String
            let country: String
        }
        
        struct Current: Codable {
            let tempC: Double
            let tempF: Double
            let feelslikeC: Double
            let feelslikeF: Double
            let isDay: Bool
            let condition: Condition
            struct Condition: Codable {
                let text: String
                let icon: String
            }
        }
        
        func toLocationModel() -> LocationModel {
            let condtion = WeatherConditionModel(text: current.condition.text,
                                                 iconUrl: "https:" + current.condition.icon)
            // TODO: pass bck both C and F temps.. let user decide in a setting switch.
            let currentWeather = WeatherModel(temp: current.tempF,
                                              feelsLike: current.feelslikeF,
                                              isDay: current.isDay,
                                              condition: condtion)
            let location = LocationModel(name: location.name,
                                 currentWeather: currentWeather)
            WeatherAPIDataSource.logger.debug("new LocationModel named : \(location.name) id: \(location.id)")
            return location
        }
    }
}
