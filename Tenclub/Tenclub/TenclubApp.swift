//
//  TenclubApp.swift
//  Tenclub
//
//  Created by Jack Breslauer on 2/11/26.
//

import SwiftUI

@main
struct TenclubApp: App {
    // Initialize managers early to ensure they're ready
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var pickupTracker = PickupTracker.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
