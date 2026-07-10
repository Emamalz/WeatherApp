//
//  WeatherMapError.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 19/10/2025.
//

import Foundation

enum WeatherMapError: Error, LocalizedError, Identifiable {

    case invalidURL(String)
    case networkError(Error)
    case decodingError(Error)
    case geocodingFailed(String)
    case invalidResponse(statusCode: Int)
    case missingData(message: String)

    var id: String { localizedDescription }

    var errorDescription: String? {
        switch self {

        case .invalidURL:
            return """
            A configuration error occurred.
            Please try again later.
            """

        case .networkError:
            return """
            A network connection error occurred.
            The operation couldn’t be completed.
            """

        case .decodingError:
            return """
            Weather data could not be read.
            Please try again later.
            """

        case .geocodingFailed:
            return """
            The location could not be found.
            Please enter a valid city name.
            """

        case .invalidResponse:
            return """
            The server returned an error.
            Data is currently unavailable.
            """

        case .missingData(let message):
            return message
        }
    }
}
