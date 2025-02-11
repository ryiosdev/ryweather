//
//  WeatherDataProvider.swift
//  ryweather
//
//  Created by Ryan Young on 2/8/25.
//

import Foundation

protocol WeatherDataProvider {
    func search(for location: String) async throws -> LocationSearchResultModel
    func fetchCurrentWeather(for location: String) async throws -> LocationModel
}

enum WeatherDataError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

struct WeatherAPIDataSource: WeatherDataProvider {
    let apiKey: String
    let domain = "https://api.weatherapi.com"
    let version = "/v1"
    
    enum EndpointURIs: String {
        case current = "/current.json"
        case search = "/search.json"
    }
    
    private func urlWithKey(for endpoint: EndpointURIs) throws -> URL {
        guard let url = URL(string: domain + version + endpoint.rawValue) else {
            throw WeatherDataError.invalidURL
        }
        return url.appending(queryItems: [URLQueryItem(name: "key", value: apiKey)])
    }
    
    func search(for location: String) async throws -> LocationSearchResultModel {
        let url = try urlWithKey(for: .search).appending(queryItems: [URLQueryItem(name: "q", value: location)])
        
        print("url = \(url)")
        //TODO: add search
        //return LocationSearchResultModel(userQueryString: "", locations: [])
        throw WeatherDataError.invalidData
    }

    func fetchCurrentWeather(for location: String) async throws -> LocationModel {
        let url = try urlWithKey(for: .current).appending(queryItems: [URLQueryItem(name: "q", value: location)])

        print("url = \(url)")

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            print("non-200 response: \(String(describing: response))")
            throw WeatherDataError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let jsonModel = try decoder.decode(CurrentWetherJsonResponse.self, from: data)
            return jsonModel.toLocationModel()
        } catch {
            print(error)
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
            return LocationModel(name: location.name,
                                 currentWeather: currentWeather)
        }
    }
}
