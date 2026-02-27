//
//  TotalActivityReport.swift
//  TenclubReport
//
//  Created by Jack Breslauer on 2/27/26.
//

import DeviceActivity
import SwiftUI

extension DeviceActivityReport.Context {
    // Context for our pickup count report
    static let totalActivity = Self("Total Activity")
}

struct TotalActivityReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .totalActivity

    // Configuration now returns pickup count as Int
    let content: (Int) -> TotalActivityView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> Int {
        // Count the number of activity segments (each segment = one pickup)
        var pickupCount = 0

        for await deviceData in data {
            for await segment in deviceData.activitySegments {
                // Each activity segment represents a pickup
                // For now, count all pickups
                // Later we can filter: only count if totalActivityDuration > 0
                pickupCount += 1

                // Debug: print segment info to understand the data
                print("Segment - Duration: \(segment.totalActivityDuration)")
            }
        }

        return pickupCount
    }
}
