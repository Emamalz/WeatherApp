import SwiftUI
import SwiftData

struct VisitedPlacesView: View {

    @EnvironmentObject var vm: MainAppViewModel

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy  •  HH:mm 'GMT'"
        formatter.timeZone = .gmt
        return formatter
    }()

    var body: some View {
        ZStack {

            LinearGradient(
                colors: [
                    Color.blue.opacity(0.35),
                    Color.pink.opacity(0.35)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 12) {

                HStack(spacing: 6) {
                    Text("Visited Places")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Image(systemName: "mappin")
                        .foregroundColor(.red)
                }
                .padding(.horizontal)

                if vm.visited.isEmpty {
                    Spacer()
                    Text("No saved locations yet")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {

                    List {
                        ForEach(vm.visited) { place in
                            VStack(alignment: .leading, spacing: 6) {

                                Text(place.name)
                                    .font(.headline)

                                Text(
                                    String(
                                        format: "Lat: %.4f, Lon: %.4f",
                                        place.latitude,
                                        place.longitude
                                    )
                                )
                                .font(.caption)
                                .foregroundColor(.secondary)

                                Text(
                                    dateFormatter.string(from: place.lastUsedAt)
                                )
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())

                            .onTapGesture {
                                Task {
                                    await vm.loadLocation(fromPlace: place)
                                    vm.selectedTab = 0
                                    vm.appError = .missingData(
                                        message: "\(place.name) loaded from storage."
                                    )
                                }
                            }

                            .onLongPressGesture {
                                let query = place.name.replacingOccurrences(
                                    of: " ",
                                    with: "+"
                                )
                                if let url = URL(
                                    string: "https://www.google.com/search?q=\(query)"
                                ) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.map { vm.visited[$0] }.forEach { place in
                                vm.delete(place: place)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .padding(.top, 32)
        }
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    VisitedPlacesView()
        .environmentObject(vm)
}
