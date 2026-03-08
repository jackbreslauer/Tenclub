//
//  TotalActivityReport.swift
//  TenclubReport
//
//  Created by Jack Breslauer on 2/27/26.
//

import DeviceActivity
import ExtensionKit
import SwiftUI

extension DeviceActivityReport.Context {
    static let totalActivity = Self("Total Activity")
    static let historyChart = Self("History Chart")
}

struct TotalActivityReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .totalActivity

    let content: (String) -> TotalActivityView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> String {
        await Self.extractDailyPickups(from: data)
    }

    // Shared helper to extract daily pickups from data
    static func extractDailyPickups(from data: DeviceActivityResults<DeviceActivityData>) async -> String {
        var dailyPickups: [DailyPickups] = []

        // Navigate the nested structure:
        // data -> activitySegments (one per day with .daily filter)
        for await deviceData in data {
            for await segment in deviceData.activitySegments {
                var segmentPickups = 0

                // Sum pickups across all categories and apps for this segment
                for await category in segment.categories {
                    for await app in category.applications {
                        segmentPickups += app.numberOfPickups
                    }
                }

                // Add this day's data
                dailyPickups.append(DailyPickups(
                    date: segment.dateInterval.start,
                    count: segmentPickups
                ))
            }
        }

        // Sort by date descending (most recent first)
        dailyPickups.sort { $0.date > $1.date }

        // Encode as JSON string to pass to view
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let jsonData = try? encoder.encode(dailyPickups),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }

        return "[]"
    }
}

struct HistoryChartReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .historyChart

    let content: (String) -> HistoryChartView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> String {
        await TotalActivityReport.extractDailyPickups(from: data)
    }
}
