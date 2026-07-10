//
//  WeatherAdviceCategory.swift
//  WeatherDashboard
//
//  Created by girish lukka on 11/10/2025.
//

import Foundation
import SwiftUI

enum WeatherAdviceCategory: String {
    case freezing, cold, mild, warm, hot, unknown

    static func from(temp: Double, description: String) -> WeatherAdviceCategory {
        let normalized = description.lowercased()
        if temp < 0 { return .freezing }
        else if temp < 10 { return .cold }
        else if temp < 20 { return .mild }
        else if temp < 28 { return .warm }
        else { return .hot }
    }

    var icon: String {
        switch self {
        case .freezing: return "snowflake"
        case .cold: return "cloud.snow.fill"
        case .mild: return "cloud.sun.fill"
        case .warm: return "sun.max.fill"
        case .hot: return "thermometer.sun.fill"
        case .unknown: return "questionmark.circle"
        }
    }

    var adviceText: String {
        switch self {
        case .freezing:
            return "It's freezing outside — bundle up and stay warm!"
        case .cold:
            return "A bit chilly today — wear a jacket or coat."
        case .mild:
            return "Mild weather — a light sweater should do."
        case .warm:
            return "Comfortably warm — perfect for outdoor activities. Don't forget sunscreen!"
        case .hot:
            return "Very hot today! Stay hydrated, wear light clothing, and apply sunscreen."
        case .unknown:
            return "Weather is unpredictable — dress in layers and check before heading out."
        }
    }

    var color: Color {
        switch self {
        case .freezing: return .blue
        case .cold: return .cyan
        case .mild: return .green
        case .warm: return .orange
        case .hot: return .red
        case .unknown: return .gray
        }
    }
}

extension WeatherAdviceCategory {

    static func iconForCondition(_ condition: String?) -> String {
        guard let condition = condition?.lowercased() else {
            return "questionmark.circle"
        }

        switch condition {
        case "clear":
            return "sun.max.fill"
        case "clouds":
            return "smoke.fill"
        case "rain":
            return "cloud.rain.fill"
        case "drizzle":
            return "cloud.drizzle.fill"
        case "thunderstorm":
            return "cloud.bolt.rain.fill"
        case "snow":
            return "cloud.snow.fill"
        case "mist", "fog", "haze":
            return "cloud.fog.fill"
        default:
            return "smoke.fill"
        }
    }
}
