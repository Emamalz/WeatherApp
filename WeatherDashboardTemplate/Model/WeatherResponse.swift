//
//  WeatherResponse.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import Foundation

// MARK: - Root Response
struct WeatherResponse: Codable {
    let lat: Double
    let lon: Double
    let timezone: String
    let current: CurrentWeather
    let daily: [DailyWeather]
}

struct CurrentWeather: Codable {
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let temp: Double
    let feelsLike: Double
    let pressure: Int
    let humidity: Int
    let windSpeed: Double
    let weather: [WeatherCondition]

    enum CodingKeys: String, CodingKey {
        case dt
        case sunrise
        case sunset
        case temp
        case feelsLike = "feels_like"
        case pressure
        case humidity
        case windSpeed = "wind_speed"
        case weather
    }
}

// MARK: - Daily Forecast (8-day tab)
struct DailyWeather: Codable {
    let dt: Int
    let temp: Temperature
    let weather: [WeatherCondition]
    let summary: String?

    enum CodingKeys: String, CodingKey {
        case dt, temp, weather, summary
    }
}

// MARK: - Temperatures
struct Temperature: Codable {
    let min: Double
    let max: Double
}

// MARK: - Weather Condition
struct WeatherCondition: Codable {
    let main: String
    let description: String
    let icon: String
}

