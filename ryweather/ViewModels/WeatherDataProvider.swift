//
//  WeatherDataProvider.swift
//  ryweather
//
//  Created by Ryan Young on 2/8/25.
//

import Foundation

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
    let apiKey: String
    let scheme: String
    let domain: String
    let version: String
    
    enum EndpointURIs: String {
        case current = "/current.json"
        case search = "/search.json"
    }

    init(apiKey: String = UserDefaults.standard.string(forKey: "apikey") ?? "", scheme: String = "https://", domain: String = "api.weatherapi.com", version: String = "/V1") {
        self.apiKey = apiKey
        self.scheme = scheme
        self.domain = domain
        self.version = version
        logger.debug("new WeatherAPIDataSource with apiKey: \(apiKey)")
    }
    
    private func urlWithAPIKey(endpoint: EndpointURIs) throws -> URL {
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
            let condition: Condition
            struct Condition: Codable {
                let text: String
                let icon: String
            }
        }
        
        // Transforms the json response model into a WeatherModel used by the app
        func toWeatherModel() -> WeatherModel {
            let tempC = WeatherTempModel(unit: .celsius,
                                         value: current.tempC,
                                         feelsLike: current.feelslikeC)
            
            let tempF = WeatherTempModel(unit: .fahrenheit,
                                         value: current.tempF,
                                         feelsLike: current.feelslikeF)
        
            let condition = WeatherConditionModel(text: current.condition.text,
                                                  iconUrl: "https:" + current.condition.icon)
            let weather = WeatherModel(temps: [tempC, tempF],
                                       condition: condition)
            return weather
        }
    }
}
