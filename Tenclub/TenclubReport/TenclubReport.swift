//
//  TenclubReport.swift
//  TenclubReport
//
//  Created by Jack Breslauer on 2/27/26.
//

import DeviceActivity
import ExtensionKit
import SwiftUI

@main
struct TenclubReport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        TotalActivityReport { pickupCountString in
            TotalActivityView(totalActivity: pickupCountString)
        }
    }
}
