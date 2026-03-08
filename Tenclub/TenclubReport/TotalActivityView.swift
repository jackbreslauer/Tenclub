//
//  TotalActivityView.swift
//  TenclubReport
//
//  Created by Jack Breslauer on 2/27/26.
//

import SwiftUI
import Charts

struct TotalActivityView: View {
    let totalActivity: String  // JSON-encoded [DailyPickups]

    private var dailyData: [DailyPickups] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = totalActivity.data(using: .utf8),
              let decoded = try? decoder.decode([DailyPickups].self, from: data) else {
            return []
        }
        return decoded
    }

    private var todayPickups: Int {
        guard let today = dailyData.first,
              Calendar.current.isDateInToday(today.date) else {
            return 0
        }
        return today.count
    }

    var body: some View {
        VStack(spacing: 16) {
            // Today's count - prominent display
            todaySection
        }
        .padding()
    }

    // MARK: - Today Section
    private var todaySection: some View {
        VStack(spacing: 16) {
            Text("Today")
                .font(.headline)
                .foregroundColor(.secondary)

            PickupCardDisplay(count: todayPickups)
                .padding(.vertical, 8)

            if todayPickups > 10 {
                Text("No tenclub today!")
                    .font(.subheadline)
                    .foregroundColor(.red)
            } else if todayPickups > 0 {
                Text("\(10 - todayPickups) remaining")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Pickup Card Display
struct PickupCardDisplay: View {
    let count: Int

    var body: some View {
        if count >= 100 {
            // 100+: Plain numbers
            VStack(spacing: 4) {
                Text("\(count)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                Text("pickups")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } else if count >= 10 {
            // 10-99: Two cards side by side
            HStack(spacing: 8) {
                MiniCardView(value: count / 10)  // Tens digit
                MiniCardView(value: count % 10 == 0 ? 10 : count % 10)  // Ones digit
            }
        } else {
            // 0-9: Single card
            MiniCardView(value: max(count, 0))
        }
    }
}

// MARK: - Mini Card View (for extension)
// Renders playing cards in Atlas deck style
struct MiniCardView: View {
    let value: Int  // 0-10

    private var label: String {
        if value == 0 { return "0" }
        if value == 1 { return "A" }
        if value == 10 { return "10" }
        return "\(value)"
    }

    var body: some View {
        ZStack {
            // Card background - white with rounded corners
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)

            // Card border
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)

            // Card content - Atlas style layout
            VStack(spacing: 0) {
                // Top left corner
                HStack {
                    VStack(spacing: -4) {
                        Text(label)
                            .font(.system(size: 28, weight: .bold))
                        Text("♣")
                            .font(.system(size: 24))
                    }
                    Spacer()
                }
                .padding(.leading, 12)
                .padding(.top, 8)

                Spacer()

                // Center club symbol
                Text("♣")
                    .font(.system(size: 72, weight: .bold))

                Spacer()

                // Bottom right corner (inverted)
                HStack {
                    Spacer()
                    VStack(spacing: -4) {
                        Text("♣")
                            .font(.system(size: 24))
                        Text(label)
                            .font(.system(size: 28, weight: .bold))
                    }
                    .rotationEffect(.degrees(180))
                }
                .padding(.trailing, 12)
                .padding(.bottom, 8)
            }
            .foregroundColor(.black)
        }
        .frame(width: 140, height: 196)  // Standard card ratio 2.5:3.5, enlarged
    }
}

// MARK: - DailyPickups (shared with report)
struct DailyPickups: Codable {
    let date: Date
    let count: Int
}

// MARK: - History Chart View
struct HistoryChartView: View {
    let dailyPickupsJSON: String

    private var dailyData: [DailyPickups] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = dailyPickupsJSON.data(using: .utf8),
              let decoded = try? decoder.decode([DailyPickups].self, from: data) else {
            return []
        }
        // Sort by date ascending (oldest first, most recent on right)
        return decoded.sorted { $0.date < $1.date }
    }

    private var maxYValue: Int {
        let maxCount = dailyData.map { $0.count }.max() ?? 0
        // Round up to nearest multiple of 5
        return ((maxCount / 5) + 1) * 5
    }

    private func dateLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    private func madeTenclub(_ count: Int) -> Bool {
        count <= 10 && count > 0
    }

    private func barColor(for day: DailyPickups) -> Color {
        if isToday(day.date) {
            return .indigo
        } else if madeTenclub(day.count) {
            return Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
        } else {
            return .gray
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            if dailyData.isEmpty {
                Text("No data available")
                    .foregroundColor(.secondary)
            } else {
                Chart {
                    ForEach(dailyData, id: \.date) { day in
                        BarMark(
                            x: .value("Date", dateLabel(for: day.date)),
                            y: .value("Pickups", day.count)
                        )
                        .foregroundStyle(barColor(for: day))
                        .annotation(position: .top) {
                            if madeTenclub(day.count) {
                                Text("♣")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                .chartYScale(domain: 0...maxYValue)
                .chartYAxis {
                    AxisMarks(position: .leading, values: .stride(by: 5))
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.indigo)
                    }
                }
                .frame(height: 250)
                .padding()
            }
        }
        .padding()
    }
}

#Preview("Today") {
    let sampleData: [DailyPickups] = [
        DailyPickups(date: Date(), count: 7),
    ]
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let json = String(data: try! encoder.encode(sampleData), encoding: .utf8)!

    return TotalActivityView(totalActivity: json)
}

#Preview("History Chart") {
    let sampleData: [DailyPickups] = [
        DailyPickups(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, count: 8),
        DailyPickups(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, count: 15),
        DailyPickups(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, count: 6),
        DailyPickups(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, count: 22),
        DailyPickups(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, count: 10),
        DailyPickups(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, count: 12),
        DailyPickups(date: Date(), count: 5),
    ]
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let json = String(data: try! encoder.encode(sampleData), encoding: .utf8)!

    return HistoryChartView(dailyPickupsJSON: json)
}
