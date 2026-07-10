//
//  LocationManager.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import Foundation
import CoreLocation
@preconcurrency import MapKit

@MainActor
final class LocationManager {

    // MARK: - Geocoding
    func geocodeAddress(_ address: String) async throws -> (name: String, lat: Double, lon: Double) {

        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.geocodeAddressString(address)

        guard let placemark = placemarks.first,
              let location = placemark.location
        else {
            throw WeatherMapError.geocodingFailed(address)
        }

        let name =
            placemark.locality ??
            placemark.name ??
            address

        return (
            name: name,
            lat: location.coordinate.latitude,
            lon: location.coordinate.longitude
        )
    }

    // MARK: - Find Points of Interest
    func findPOIs(lat: Double, lon: Double, limit: Int = 5) async throws -> [AnnotationModel] {

        let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)

        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )

        let request = MKLocalSearch.Request()
        request.region = region
        request.naturalLanguageQuery = "Tourist Attractions"
        request.resultTypes = .pointOfInterest

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        let annotations = response.mapItems.compactMap { item -> AnnotationModel? in
            guard let name = item.name else { return nil }
            return AnnotationModel(
                name: name,
                latitude: item.placemark.coordinate.latitude,
                longitude: item.placemark.coordinate.longitude
            )
        }

        return Array(annotations.prefix(limit))
    }
}
