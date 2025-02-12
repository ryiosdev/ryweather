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
    func fetchCurrentWeather(for locationDescription: String) async throws -> WeatherModel
}

enum WeatherDataError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

struct WeatherAPIDataSource {
    let logger = Logger()
    let apiKey: String

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
        
        logger.debug("search url = \(url)")
        //TODO: add search
        //return LocationSearchResultModel(userQueryString: "", locations: [])
        throw WeatherDataError.invalidData
    }

    func fetchCurrentWeather(for locationDescription: String) async throws -> WeatherModel {
        let url = try urlWithAPIKey(endpoint: .current).appending(queryItems: [URLQueryItem(name: "q", value: locationDescription)])

        logger.debug("current weather url = \(url)")

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            logger.warning("non-200 response: \(response.description)")
            throw WeatherDataError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let jsonResponse = try decoder.decode(CurrentWetherJsonResponse.self, from: data)
            logger.debug("current weather response: \(String(describing:jsonResponse))")
            return jsonResponse.toWeatherModel()
        } catch {
            logger.error("failed to decode json: \(error)")
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
            let isDay: Int
            let condition: Condition
            struct Condition: Codable {
                let text: String
                let icon: String
            }
        }
        
        func toWeatherModel() -> WeatherModel {
            let condtion = WeatherConditionModel(text: current.condition.text,
                                                 iconUrl: "https:" + current.condition.icon)
            // TODO: pass bck both C and F temps.. let user decide in a setting switch.
            let currentWeather = WeatherModel(temp: current.tempF,
                                              feelsLike: current.feelslikeF,
                                              isDay: current.isDay == 1,
                                              condition: condtion)
            return currentWeather
        }
    }
}
