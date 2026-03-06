//
//  LocationManager.swift
//  Tenclub
//
//  Created by Claude on 3/6/26.
//

import Foundation
import CoreLocation

@MainActor
class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()

    private let locationManager = CLLocationManager()

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isAuthorizedAlways: Bool = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers // Low accuracy = less battery
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false

        // Check current status
        updateAuthorizationStatus()
    }

    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    func startMonitoring() {
        guard isAuthorizedAlways else { return }
        locationManager.startMonitoringSignificantLocationChanges()
    }

    func stopMonitoring() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }

    private func updateAuthorizationStatus() {
        authorizationStatus = locationManager.authorizationStatus
        isAuthorizedAlways = authorizationStatus == .authorizedAlways

        // Auto-start monitoring if authorized
        if isAuthorizedAlways {
            startMonitoring()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            updateAuthorizationStatus()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // We don't actually need the location data
        // This callback just keeps the app alive in the background
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Location errors are expected and can be ignored
        // The app will still stay alive in the background
    }
}
