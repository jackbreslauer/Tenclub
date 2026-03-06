//
//  TotalActivityView.swift
//  TenclubReport
//
//  Created by Jack Breslauer on 2/27/26.
//

import SwiftUI

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

    private var historyData: [DailyPickups] {
        // Skip today, show past days
        dailyData.dropFirst().filter { !Calendar.current.isDateInToday($0.date) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Today's count - prominent display
                todaySection

                // History section
                if !historyData.isEmpty {
                    historySection
                }
            }
            .padding()
        }
    }

    // MARK: - Today Section
    private var todaySection: some View {
        VStack(spacing: 8) {
            Text("Today")
                .font(.headline)
                .foregroundColor(.secondary)

            PickupCardDisplay(count: todayPickups)

            if todayPickups > 10 {
                Text("No tenclub today!")
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            } else if todayPickups > 0 {
                Text("\(10 - todayPickups) remaining")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    // MARK: - History Section
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("History")
                .font(.headline)
                .foregroundColor(.secondary)

            ForEach(historyData, id: \.date) { day in
                HistoryRow(dailyPickups: day)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - History Row
struct HistoryRow: View {
    let dailyPickups: DailyPickups

    private var dayLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInYesterday(dailyPickups.date) {
            return "Yesterday"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"  // Day name
        return formatter.string(from: dailyPickups.date)
    }

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dailyPickups.date)
    }

    private var madeTenclub: Bool {
        dailyPickups.count <= 10 && dailyPickups.count > 0
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(dayLabel)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(dateLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 6) {
                Text("\(dailyPickups.count)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(madeTenclub ? .green : .primary)

                if madeTenclub {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.subheadline)
                }
            }
        }
        .padding(.vertical, 4)
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
struct MiniCardView: View {
    let value: Int  // 0-10

    private var label: String {
        if value == 0 { return "0" }
        if value == 1 { return "A" }
        return "\(value)"
    }

    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)

            // Card border
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)

            // Card content
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("♣")
                    .font(.system(size: 16))
            }
            .foregroundColor(.black)
        }
        .frame(width: 50, height: 70)
    }
}

// MARK: - DailyPickups (shared with report)
struct DailyPickups: Codable {
    let date: Date
    let count: Int
}

#Preview("With history") {
    let sampleData: [DailyPickups] = [
        DailyPickups(date: Date(), count: 7),
        DailyPickups(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, count: 12),
        DailyPickups(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, count: 8),
        DailyPickups(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, count: 15),
    ]
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let json = String(data: try! encoder.encode(sampleData), encoding: .utf8)!

    return TotalActivityView(totalActivity: json)
}
