//
//  MockWeatherAPIDataSource.swift
//  ryweather
//
//  Created by Ryan Young on 3/20/25.
//

import Foundation

struct MockWeatherAPIDataSource  {
    enum MockWeatherDataFiles: String {
        case searchResults = "search_results"
        case searchResultsNoResults = "search_results_no_results"
        case searchResultsError = "search_results_error"
        case currentWeather = "current_weather"
        case currentWeatherNoResults = "current_weather_no_results"
        case currentWeatherError = "current_weather_error"
    }

    let search: MockWeatherDataFiles
    let current: MockWeatherDataFiles
    
    init(_ searchFile: MockWeatherDataFiles = .searchResults, _ currentFile: MockWeatherDataFiles = .currentWeather) {
        search = searchFile
        current = currentFile
    }
}
extension MockWeatherAPIDataSource: WeatherAPIURLRequestHandler {
    func searchData(from url: URL) async throws -> (Data, URLResponse) {
        // TODO: validate url, but don't use it..
        
        guard let file = Bundle.main.url(forResource: search.rawValue, withExtension: "json") else {
            throw WeatherDataError.invalidURL
        }
        
        do {
            let data = try Data(contentsOf: file)
            guard let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else {
                throw WeatherDataError.invalidResponse
            }
                            
            return (data, urlResponse)
        } catch {
            throw WeatherDataError.invalidData
        }
    }
    
    func currentData(from url: URL) async throws -> (Data, URLResponse) {
        // TODO: validate url, but don't use it..

        guard let file = Bundle.main.url(forResource: current.rawValue, withExtension: "json") else {
            throw WeatherDataError.invalidURL
        }
        
        do {
            let data = try Data(contentsOf: file)
            guard let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else {
                throw WeatherDataError.invalidResponse
            }

            return (data, urlResponse)
        } catch {
            throw WeatherDataError.invalidData
        }
    }
}

extension MockWeatherAPIDataSource: WeatherDataProvider {
    func search(for searchText: String) async throws -> LocationSearchResultModel {
        throw NSError(domain: "", code: 0, userInfo: nil)
    }
    
    func fetchCurrentWeather(for locationDescription: String) async throws -> WeatherModel {
        throw NSError(domain: "", code: 0, userInfo: nil)
    }
}


