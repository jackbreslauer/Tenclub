//
//  ScreenTimeManager.swift
//  Tenclub
//
//  Handles Screen Time authorization and data access
//

import SwiftUI
import Combine
import FamilyControls
import DeviceActivity

@MainActor
class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()

    @Published var isAuthorized: Bool = false
    @Published var authorizationError: String?

    private let authorizationCenter = AuthorizationCenter.shared

    private init() {
        // Check current authorization status
        checkAuthorizationStatus()
    }

    func checkAuthorizationStatus() {
        switch authorizationCenter.authorizationStatus {
        case .approved:
            isAuthorized = true
        case .denied, .notDetermined:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
    }

    func requestAuthorization() async {
        do {
            try await authorizationCenter.requestAuthorization(for: .individual)
            isAuthorized = true
            authorizationError = nil
        } catch {
            isAuthorized = false
            authorizationError = error.localizedDescription
            print("Authorization failed: \(error)")
        }
    }
}
