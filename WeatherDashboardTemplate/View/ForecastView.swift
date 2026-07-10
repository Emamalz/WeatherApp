import SwiftUI
import Charts
import SwiftData   

struct ForecastView: View {

    @EnvironmentObject var vm: MainAppViewModel

    var body: some View {
        ZStack {

            // MARK: - Background
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.35),
                    Color.pink.opacity(0.35)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

    
            if vm.forecast.isEmpty {
                ProgressView("Loading forecast…")
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // MARK: - Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("8 Day Forecast – \(vm.activePlaceName)")
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text("Daily Highs and Lows (°C)")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }

                        // MARK: - Grouped Bar Chart
                        Chart {
                            ForEach(vm.forecast.prefix(8), id: \.dt) { day in

                                BarMark(
                                    x: .value(
                                        "Day",
                                        DateFormatterUtils.formattedDateWithWeekdayAndDay(
                                            from: TimeInterval(day.dt)
                                        )
                                    ),
                                    y: .value("Low", Int(day.temp.min))
                                )
                                .foregroundStyle(Color.blue)
                                .position(by: .value("Type", "Low"))

                                BarMark(
                                    x: .value(
                                        "Day",
                                        DateFormatterUtils.formattedDateWithWeekdayAndDay(
                                            from: TimeInterval(day.dt)
                                        )
                                    ),
                                    y: .value("High", Int(day.temp.max))
                                )
                                .foregroundStyle(Color.orange)
                                .position(by: .value("Type", "High"))
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .trailing) { value in
                                AxisGridLine()
                                    .foregroundStyle(Color.black.opacity(0.1))

                                AxisValueLabel {
                                    if let temp = value.as(Int.self) {
                                        Text("\(temp)°")
                                    }
                                }
                                .foregroundStyle(.secondary)
                            }
                        }
                        .frame(height: 240)
                        .padding()
                        .background(Color.white.opacity(0.25))
                        .cornerRadius(16)
                        .shadow(
                            color: Color.black.opacity(0.08),
                            radius: 8,
                            x: 0,
                            y: 4
                        )

                        // MARK: - Detailed Daily Summary
                        Text("Detailed Daily Summary")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(vm.forecast.prefix(8), id: \.dt) { day in
                                VStack(alignment: .leading, spacing: 4) {

                                    Text(
                                        DateFormatterUtils.formattedDateWithWeekdayAndDay(
                                            from: TimeInterval(day.dt)
                                        )
                                    )
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                    Text(day.summary ?? "No summary available.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text(
                                        "Low: \(Int(day.temp.min))°  High: \(Int(day.temp.max))°"
                                    )
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.25))
                        .cornerRadius(16)
                        .shadow(
                            color: Color.black.opacity(0.08),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    ForecastView()
        .environmentObject(
            MainAppViewModel(context: ModelContext(ModelContainer.preview))
        )
}
