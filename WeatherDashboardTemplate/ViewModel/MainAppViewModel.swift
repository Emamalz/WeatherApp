import SwiftUI
import SwiftData
import MapKit

@MainActor
final class MainAppViewModel: ObservableObject {

    @Published var query = ""
    @Published var currentWeather: CurrentWeather?
    @Published var forecast: [DailyWeather] = []
    @Published var pois: [AnnotationModel] = []
    @Published var mapRegion = MKCoordinateRegion()
    @Published var visited: [Place] = []
    @Published var isLoading = false
    @Published var appError: WeatherMapError?
    @Published var activePlaceName: String = ""
    @Published var selectedTab: Int = 0

    private let defaultPlaceName = "London"

    private let weatherService = WeatherService()
    private let locationManager = LocationManager()
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context

        if let results = try? context.fetch(
            FetchDescriptor<Place>(
                sortBy: [SortDescriptor(\Place.lastUsedAt, order: .reverse)]
            )
        ) {
            self.visited = results
        }

        if visited.isEmpty {
            Task { await loadDefaultLocation() }
        } else if let mostRecent = visited.first {
            Task { await loadLocation(fromPlace: mostRecent) }
        }
    }

    func submitQuery() {
        let city = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !city.isEmpty else {
            appError = .missingData(message: "Please enter a valid location.")
            return
        }

        Task {
            do {
                try await loadLocation(byName: city)
                query = ""
            } catch {
                await revertToDefaultWithAlert(message: "The location could not be found.")
            }
        }
    }

    func loadDefaultLocation() async {
        do {
            isLoading = true

            let result = try await locationManager.geocodeAddress(defaultPlaceName)
            activePlaceName = result.name

            try await loadWeatherAndForecast(
                lat: result.lat,
                lon: result.lon
            )

            let annotations = try await locationManager.findPOIs(
                lat: result.lat,
                lon: result.lon
            )

            pois = annotations

            mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: result.lat, longitude: result.lon),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )

        } catch {
            appError = .networkError(error)
        }

        isLoading = false
    }

    func loadLocation(byName name: String) async throws {
        isLoading = true
        defer { isLoading = false }

        if let existing = visited.first(where: {
            $0.name.lowercased() == name.lowercased()
        }) {
            await loadLocation(fromPlace: existing)
            appError = .missingData(message: "Loaded \(existing.name) from storage.")
            selectedTab = 0
            return
        }

        let result = try await locationManager.geocodeAddress(name)

        try await loadWeatherAndForecast(
            lat: result.lat,
            lon: result.lon
        )

        let annotations = try await locationManager.findPOIs(
            lat: result.lat,
            lon: result.lon
        )

        let place = Place(
            name: result.name,
            latitude: result.lat,
            longitude: result.lon,
            lastUsedAt: Date()
        )
        place.annotations = annotations

        context.insert(place)
        try context.save()

        visited.insert(place, at: 0)
        pois = annotations
        activePlaceName = result.name

        focus(
            on: CLLocationCoordinate2D(
                latitude: result.lat,
                longitude: result.lon
            )
        )

        appError = .missingData(message: "\(result.name) saved successfully.")
        selectedTab = 0
    }

    func loadLocation(fromPlace place: Place) async {
        isLoading = true
        defer { isLoading = false }

        do {
            place.lastUsedAt = Date()
            try context.save()

            activePlaceName = place.name

            try await loadWeatherAndForecast(
                lat: place.latitude,
                lon: place.longitude
            )

            pois = place.annotations

            focus(
                on: CLLocationCoordinate2D(
                    latitude: place.latitude,
                    longitude: place.longitude
                )
            )

        } catch {
            await revertToDefaultWithAlert(message: "Failed to load saved location.")
        }
    }

    private func loadWeatherAndForecast(lat: Double, lon: Double) async throws {
        let response = try await weatherService.fetchWeather(lat: lat, lon: lon)
        currentWeather = response.current
        forecast = Array(response.daily.prefix(8))
    }

    private func revertToDefaultWithAlert(message: String) async {
        appError = .missingData(message: message)
        selectedTab = 0
        await loadDefaultLocation()
    }

    func focus(on coordinate: CLLocationCoordinate2D, zoom: Double = 0.02) {
        mapRegion = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: zoom, longitudeDelta: zoom)
        )
    }

    func delete(place: Place) {
        context.delete(place)
        visited.removeAll { $0.id == place.id }

        do {
            try context.save()
        } catch {
            appError = .networkError(error)
        }
    }
}
