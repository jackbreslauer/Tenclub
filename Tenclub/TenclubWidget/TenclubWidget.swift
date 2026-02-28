//
//  TenclubWidget.swift
//  TenclubWidget
//
//  Created by Jack Breslauer on 2/27/26.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> PickupEntry {
        PickupEntry(date: Date(), pickupCount: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (PickupEntry) -> ()) {
        let entry = PickupEntry(date: Date(), pickupCount: 7)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // TODO: Get actual pickup count from shared storage
        // For now, using mock data
        let entry = PickupEntry(date: Date(), pickupCount: 7)

        // Refresh every 15 minutes (minimum allowed by iOS)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Timeline Entry
struct PickupEntry: TimelineEntry {
    let date: Date
    let pickupCount: Int
}

// MARK: - Small Home Screen Widget View
struct SmallWidgetView: View {
    var entry: PickupEntry

    var body: some View {
        VStack(spacing: 4) {
            if entry.pickupCount >= 100 {
                // 100+: Plain number
                Text("\(entry.pickupCount)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
            } else if entry.pickupCount >= 10 {
                // 10-99: Two mini cards
                HStack(spacing: 4) {
                    WidgetMiniCard(value: entry.pickupCount / 10)
                    WidgetMiniCard(value: entry.pickupCount % 10 == 0 ? 10 : entry.pickupCount % 10)
                }
            } else {
                // 1-9: Single card
                WidgetMiniCard(value: entry.pickupCount)
            }

            Text("pickups")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Mini Card for Widget
struct WidgetMiniCard: View {
    let value: Int

    private var label: String {
        value == 1 ? "A" : "\(value)"
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)

            VStack(spacing: 1) {
                Text(label)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Text("♣")
                    .font(.system(size: 10))
            }
            .foregroundColor(.black)
        }
        .frame(width: 32, height: 44)
    }
}

// MARK: - Home Screen Widget
struct TenclubWidget: Widget {
    let kind: String = "TenclubWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                SmallWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                SmallWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Tenclub")
        .description("See your daily pickup count")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Lock Screen Widget
struct TenclubLockScreenWidget: Widget {
    let kind: String = "TenclubLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LockScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("Pickups")
        .description("Daily pickup count")
        .supportedFamilies([.accessoryCircular])
    }
}

struct LockScreenWidgetView: View {
    var entry: PickupEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Text("\(entry.pickupCount)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
        }
    }
}

// MARK: - Previews
#Preview("Small Widget", as: .systemSmall) {
    TenclubWidget()
} timeline: {
    PickupEntry(date: .now, pickupCount: 7)
    PickupEntry(date: .now, pickupCount: 23)
}

#Preview("Lock Screen", as: .accessoryCircular) {
    TenclubLockScreenWidget()
} timeline: {
    PickupEntry(date: .now, pickupCount: 7)
}
