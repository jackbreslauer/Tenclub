//
//  TenclubReport.swift
//  TenclubReport
//
//  Created by Jack Breslauer on 2/27/26.
//

import DeviceActivity
import SwiftUI

@main
struct TenclubReport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        TotalActivityReport { pickupCount in
            TotalActivityView(totalActivity: pickupCount)
        }
    }
}
