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
}

struct TotalActivityReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .totalActivity

    let content: (String) -> TotalActivityView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> String {
        // Count the number of activity segments (each segment = one pickup)
        var pickupCount = 0

        for await deviceData in data {
            for await segment in deviceData.activitySegments {
                pickupCount += 1
                print("Segment - Duration: \(segment.totalActivityDuration)")
            }
        }

        return String(pickupCount)
    }
}
