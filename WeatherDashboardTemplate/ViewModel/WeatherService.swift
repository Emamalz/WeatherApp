//
//  WeatherService.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import Foundation

@MainActor
final class WeatherService {

    private let apiKey = "62c751b66af2450121e6d3c86dc4eac3"

        func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {

            let urlString =
                "https://api.openweathermap.org/data/3.0/onecall" +
                "?lat=\(lat)" +
                "&lon=\(lon)" +
                "&exclude=minutely,alerts" +
                "&units=metric" +
                "&appid=\(apiKey)"

            guard let url = URL(string: urlString) else {
                throw WeatherMapError.invalidURL(urlString)
            }

            let (data, response): (Data, URLResponse)
            do {
                (data, response) = try await URLSession.shared.data(from: url)
            } catch {
                throw WeatherMapError.networkError(error)
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherMapError.invalidResponse(statusCode: -1)
            }

            guard httpResponse.statusCode == 200 else {
                throw WeatherMapError.invalidResponse(statusCode: httpResponse.statusCode)
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                return try decoder.decode(WeatherResponse.self, from: data)
            } catch {
                throw WeatherMapError.decodingError(error)
            }
        }
    }
