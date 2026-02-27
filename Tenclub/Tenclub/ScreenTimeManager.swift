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
    @Published var refreshID = UUID()  // Used to trigger report refresh

    private let authorizationCenter = AuthorizationCenter.shared

    private init() {
        // Check current authorization status
        checkAuthorizationStatus()

        // Observe authorization changes
        Task {
            for await status in authorizationCenter.authorizationStatusChanges {
                await MainActor.run {
                    self.isAuthorized = (status == .approved)
                }
            }
        }
    }

    func checkAuthorizationStatus() {
        let status = authorizationCenter.authorizationStatus
        isAuthorized = (status == .approved)
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

    func refreshReport() {
        // Change the ID to force SwiftUI to recreate the DeviceActivityReport
        refreshID = UUID()
    }
}
