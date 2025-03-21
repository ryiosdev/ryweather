//
//  WeatherAPIDataSource.swift
//  ryweather
//
//  Created by Ryan Young on 2/13/25.
//

import Foundation

struct WeatherAPIConfig {
    let apiKey: String
    var scheme: String = "https"
    var domain: String = "api.weatherapi.com"
    var path: String = "V1"
}

protocol WeatherAPIURLRequestHandler {
    func searchData(from url: URL) async throws -> (Data, URLResponse)
    func currentData(from url: URL) async throws -> (Data, URLResponse)
}

/// A `WeatherDataProvider` implementation that pulls weather data from http://www.weatherapi.com
struct WeatherAPIDataSource {
    private let apiKey: String
    private let scheme: String
    private let domain: String
    private let path: String
    var urlHandler: WeatherAPIURLRequestHandler?
    
    enum EndpointURIs: String {
        case current = "current.json"
        case search = "search.json"
    }

    init(config: WeatherAPIConfig) {
        self.apiKey = config.apiKey
        self.scheme = config.scheme
        self.domain = config.domain
        self.path = config.path
        logger.debug("new WeatherAPIDataSource with apiKey: \(config.apiKey)")
    }
    
    private func urlWithAPIKey(for endpoint: EndpointURIs) throws -> URL {
        var urlString = scheme
        urlString += "://"
        urlString += domain
        urlString += "/"
        urlString += path
        urlString += "/"
        urlString += endpoint.rawValue
        
        guard let url = URL(string: urlString) else {
            throw WeatherDataError.invalidURL
        }
        return url.appending(queryItems: [URLQueryItem(name: "key", value: apiKey)])
    }
}

extension WeatherAPIDataSource: WeatherAPIURLRequestHandler {
    func searchData(from url: URL) async throws -> (Data, URLResponse) {
        // Use the provided urlHandler if it exists, if not, then default to URLSession.shared.data()
        if let urlHandler = urlHandler {
            return try await urlHandler.searchData(from: url)
        }
        return try await URLSession.shared.data(from: url)
    }
    
    func currentData(from url: URL) async throws -> (Data, URLResponse) {
        // Use the provided urlHandler if it exists, if not, then default to URLSession.shared.data()
        if let urlHandler = urlHandler {
            return try await urlHandler.currentData(from: url)
        }
        return try await URLSession.shared.data(from: url)
    }
}

extension WeatherAPIDataSource: WeatherDataProvider {
    func search(for searchText: String) async throws -> LocationSearchResultModel {
        // TODO: searchText input validation
        let url = try urlWithAPIKey(for: .search).appending(queryItems: [URLQueryItem(name: "q", value: searchText)])
        logger.debug("location search url = \(url)")
        
        let (data, response) = try await searchData(from: url)
        
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
    
    func fetchCurrentWeather(for locationDescription: String) async throws -> WeatherModel {
        let url = try urlWithAPIKey(for: .current).appending(queryItems: [URLQueryItem(name: "q", value: locationDescription)])
        logger.debug("current weather url = \(url)")
        let (data, response) = try await currentData(from: url)

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
}

/// Root JSON object for location Search (Auto complete)
///
/// [Search API](https://www.weatherapi.com/docs/#apis-search)
struct LocationSearchJsonResponse {
    struct Location: Codable {
        let id: Int
        let name: String
        let region: String
        let country: String
        let url: String
    }
    
    //
    static func from(data: Data, searchText: String) throws -> LocationSearchResultModel {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let array = try decoder.decode([LocationSearchJsonResponse.Location].self, from: data)
        let searchResultModel = toSearchResultModel(array, searchText: searchText)
        return searchResultModel
    }
    
    // Transforms the json response model into a WeatherModel used by the app
    static func toSearchResultModel(_ array: [Location], searchText: String) -> LocationSearchResultModel {
        let locationModels = array.map { location in
            LocationModel(id: location.id,
                          name: location.name,
                          region: location.region,
                          country: location.country,
                          searchText: location.url.replacingOccurrences(of: "-", with: " "))
        }
        let searchResultModel = LocationSearchResultModel(searchText: searchText, locations: locationModels)
        return searchResultModel
    }
}

/// Root JSON object for Current location weather
///
/// [Current weather API](https://www.weatherapi.com/docs/#apis-realtime)
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
                                              iconUrl: URL(string: "https:" + current.condition.icon))
        let weather = WeatherModel(temps: [tempC, tempF],
                                   condition: condition)
        return weather
    }
}
