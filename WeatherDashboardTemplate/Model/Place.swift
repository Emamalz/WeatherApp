//
//  Place.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftData
import CoreLocation

@Model
final class Place {

    @Attribute(.unique) var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var lastUsedAt: Date

    @Relationship(deleteRule: .cascade)
    var annotations: [AnnotationModel] = []

    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double,
        lastUsedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.lastUsedAt = lastUsedAt
    }
}

@Model
final class AnnotationModel: Identifiable {

    @Attribute(.unique) var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double

    var place: Place?

    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double,
        place: Place? = nil
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.place = place
    }
}
