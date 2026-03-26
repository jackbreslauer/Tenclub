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
        VStack(spacing: 12) {
            Text("Today")
                .font(.headline)
                .foregroundColor(.secondary)

            PickupCardDisplay(count: todayPickups)
                .frame(maxHeight: .infinity)

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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
// Displays Atlas deck playing card images with random suit
struct MiniCardView: View {
    let value: Int  // 0-10

    private static let suits = ["clubs", "diamonds", "hearts", "spades"]

    // Use value as seed for consistent suit per card value
    private var suit: String {
        let index = abs(value.hashValue) % Self.suits.count
        return Self.suits[index]
    }

    private var imageName: String? {
        switch value {
        case 1: return "ace_of_\(suit)"
        case 2...10: return "\(value)_of_\(suit)"
        default: return nil
        }
    }

    var body: some View {
        if let imageName = imageName {
            Image(imageName)
                .resizable()
                .aspectRatio(2.0/3.0, contentMode: .fit)
                .frame(maxHeight: .infinity)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        } else {
            // Fallback for 0
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                Text("0")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(.black)
            }
            .aspectRatio(2.0/3.0, contentMode: .fit)
            .frame(maxHeight: .infinity)
        }
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
