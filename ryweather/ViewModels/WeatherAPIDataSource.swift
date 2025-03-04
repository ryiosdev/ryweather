//
//  WeatherAPIDataSource.swift
//  ryweather
//
//  Created by Ryan Young on 2/13/25.
//

import Foundation

struct WeatherAPIDataSource {
    let apiKey: String
    let scheme: String
    let domain: String
    let version: String
    
    enum EndpointURIs: String {
        case current = "/current.json"
        case search = "/search.json"
    }

    init(apiKey: String,
         scheme: String = "https://",
         domain: String = "api.weatherapi.com",
         version: String = "/V1") {
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
    func search(for searchText: String) async throws -> LocationSearchResultModel {
        let url = try urlWithAPIKey(endpoint: .search).appending(queryItems: [URLQueryItem(name: "q", value: searchText)])
        logger.debug("location search url = \(url)")
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            logger.warning("non-200 response: \(response.description)")
            throw WeatherDataError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let jsonLocationsArray = try decoder.decode([LocationSearchJsonResponse.Location].self, from: data)
            return LocationSearchJsonResponse.toSearchResultModel(jsonLocationsArray, searchText: searchText)
        } catch {
            logger.error("failed to decode json: \(error)")
            throw WeatherDataError.invalidData
        }
    }
    
    //https://www.weatherapi.com/docs/#apis-search
    private struct LocationSearchJsonResponse {
        struct Location: Codable {
            let id: Int
            let name: String
            let region: String
            let country: String
            let url: String
        }
        // Transforms the json response model into a WeatherModel used by the app
        static func toSearchResultModel(_ array: [Location], searchText: String) -> LocationSearchResultModel {
            let locationModels = array.map { json in
                LocationModel(id: json.id,
                              name: json.name,
                              region: json.region,
                              country: json.country,
                              searchText: json.url.replacingOccurrences(of: "-", with: " "))
            }
            let searchResultModel = LocationSearchResultModel(searchText: searchText, locations: locationModels)
            return searchResultModel
        }
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
