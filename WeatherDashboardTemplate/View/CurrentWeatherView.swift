import SwiftUI
import SwiftData

struct CurrentWeatherView: View {

    @EnvironmentObject var vm: MainAppViewModel

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

            if let current = vm.currentWeather {

                let advice = WeatherAdviceCategory.from(
                    temp: current.temp,
                    description: current.weather.first?.description ?? ""
                )

                VStack(alignment: .leading, spacing: 22) {

                    // MARK: - Header
                    HStack {
                        Text(vm.activePlaceName)
                            .font(.title2)
                            .fontWeight(.semibold)

                        Spacer()

                        Text(
                            DateFormatterUtils.formattedDateWithStyle(
                                from: current.dt,
                                style: .full
                            )
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }

                    // MARK: - Framed Weather Container
                    VStack(alignment: .leading, spacing: 35) {

                        // MARK: - Temperature + Icon Row
                        HStack(alignment: .top) {

                            VStack(alignment: .leading, spacing: 20) {
                                Text("\(Int(current.temp))°C")
                                    .font(.system(size: 56, weight: .bold))

                                Text(current.weather.first?.description.capitalized ?? "")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)

                                HStack(spacing: 16) {
                                    if let today = vm.forecast.first {
                                        Label("\(Int(today.temp.max))°C", systemImage: "arrow.up")
                                        Label("\(Int(today.temp.min))°C", systemImage: "arrow.down")
                                    }
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            }

                            Spacer()

                            Image(
                                systemName: WeatherAdviceCategory.iconForCondition(
                                    current.weather.first?.main
                                )
                            )
                            .font(.system(size: 50))
                            .foregroundColor(.black)
                            .offset(y: 6)
                        }

                        // MARK: - Soft Divider
                        Rectangle()
                            .fill(Color.black.opacity(0.08))
                            .frame(height: 1)

                        VStack(alignment: .leading, spacing: 30) {

                            Text("Details")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            detailRow(
                                icon: "gauge",
                                label: "Pressure",
                                value: "\(current.pressure) hPa"
                            )

                            detailRow(
                                icon: "sunrise",
                                label: "Sunrise",
                                value: DateFormatterUtils.formattedDate12Hour(
                                    from: TimeInterval(current.sunrise)
                                )
                            )

                            detailRow(
                                icon: "sunset",
                                label: "Sunset",
                                value: DateFormatterUtils.formattedDate12Hour(
                                    from: TimeInterval(current.sunset)
                                )
                            )
                        }


                        // MARK: - Advice Card
                        HStack(spacing: 20) {
                            Image(systemName: advice.icon)
                                .font(.system(size: 55))
                                .foregroundColor(advice.color)

                            Text(advice.adviceText)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(advice.color.opacity(0.25))
                        .cornerRadius(14)
                         
                    }
                
                .padding(20)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black.opacity(0.2), lineWidth: 1)
                )

                    Spacer()
                }
                .padding()

            } else {
                ProgressView("Loading weather…")
            }
        }
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.subheadline)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    CurrentWeatherView()
        .environmentObject(
            MainAppViewModel(
                context: ModelContext(ModelContainer.preview)
            )
        )
}
