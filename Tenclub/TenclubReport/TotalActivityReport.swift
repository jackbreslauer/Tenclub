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
        var totalPickups = 0

        // Navigate the nested structure:
        // data -> activitySegments -> categories -> applications -> numberOfPickups
        for await deviceData in data {
            for await segment in deviceData.activitySegments {
                for await category in segment.categories {
                    for await app in category.applications {
                        totalPickups += app.numberOfPickups
                    }
                }
            }
        }

        return String(totalPickups)
    }
}
