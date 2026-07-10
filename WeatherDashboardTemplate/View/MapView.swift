import SwiftUI
import MapKit
import SwiftData

struct MapView: View {

    @EnvironmentObject var vm: MainAppViewModel

    struct POI: Identifiable {
        let id = UUID()
        let name: String
        let coordinate: CLLocationCoordinate2D
    }

    private var pois: [POI] {
        vm.pois.map {
            POI(
                name: $0.name,
                coordinate: CLLocationCoordinate2D(
                    latitude: $0.latitude,
                    longitude: $0.longitude
                )
            )
        }
    }

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
            span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        )
    )

    var body: some View {
        GeometryReader { geo in
            ZStack {

                Image("sky3")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    Map(position: $cameraPosition) {
                        ForEach(pois) { poi in
                            Annotation(poi.name, coordinate: poi.coordinate) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.red)
                                    .onTapGesture {
                                        withAnimation(.easeInOut) {
                                            cameraPosition = .region(
                                                MKCoordinateRegion(
                                                    center: poi.coordinate,
                                                    span: MKCoordinateSpan(
                                                        latitudeDelta: 0.01,
                                                        longitudeDelta: 0.01
                                                    )
                                                )
                                            )
                                        }
                                    }
                                    .simultaneousGesture(
                                        LongPressGesture(minimumDuration: 0.6)
                                            .onEnded { _ in
                                                let query = poi.name.replacingOccurrences(of: " ", with: "+")
                                                if let url = URL(string: "https://www.google.com/search?q=\(query)") {
                                                    UIApplication.shared.open(url)
                                                }
                                            }
                                    )
                            }
                        }
                    }
                    .frame(height: geo.size.height * 0.55)
                    .onChange(of: vm.mapRegion.center.latitude) { _ in
                        cameraPosition = .region(vm.mapRegion)
                    }

                    Text("Top 5 Tourist Attractions in \(vm.activePlaceName)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.9))

                    Spacer()

                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(pois) { poi in
                            HStack(spacing: 12) {

                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.orange)

                                Text(poi.name)
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .semibold))

                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                focus(on: poi.coordinate)
                            }
                        }
                    }
                    .padding(.leading, 50)
                    .padding(.bottom, 70)
                }
            }
        }
    }

    private func focus(on coordinate: CLLocationCoordinate2D) {
        withAnimation(.easeInOut) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                )
            )
        }
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    MapView()
        .environmentObject(vm)
}
