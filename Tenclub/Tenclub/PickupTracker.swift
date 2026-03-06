//
//  PickupTracker.swift
//  Tenclub
//
//  Created by Claude on 3/6/26.
//

import Foundation
import UIKit

@MainActor
class PickupTracker: ObservableObject {
    static let shared = PickupTracker()

    @Published var todayPickupCount: Int = 0

    private let defaults = UserDefaults.standard
    private let pickupKeyPrefix = "pickup_"

    private init() {
        // Load today's count
        todayPickupCount = getPickupCount(for: Date())

        // Listen for device unlock
        NotificationCenter.default.addObserver(
            forName: UIApplication.protectedDataDidBecomeAvailableNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.recordPickup()
            }
        }
    }

    // MARK: - Public Methods

    /// Records a pickup for the current moment
    func recordPickup() {
        let today = Calendar.current.startOfDay(for: Date())
        let key = pickupKey(for: today)

        let currentCount = defaults.integer(forKey: key)
        let newCount = currentCount + 1

        defaults.set(newCount, forKey: key)
        todayPickupCount = newCount
    }

    /// Gets the pickup count for a specific date
    func getPickupCount(for date: Date) -> Int {
        let key = pickupKey(for: Calendar.current.startOfDay(for: date))
        return defaults.integer(forKey: key)
    }

    /// Gets historical pickup data for the last N days
    func getHistory(days: Int) -> [(date: Date, count: Int)] {
        var history: [(date: Date, count: Int)] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for dayOffset in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let count = getPickupCount(for: date)
                history.append((date: date, count: count))
            }
        }

        return history
    }

    /// Checks if user "made the Tenclub" on a given date (10 or fewer pickups)
    func madeTenclub(on date: Date) -> Bool {
        return getPickupCount(for: date) <= 10
    }

    /// Refreshes today's count (useful when app comes to foreground)
    func refreshTodayCount() {
        todayPickupCount = getPickupCount(for: Date())
    }

    // MARK: - Private Methods

    private func pickupKey(for date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let dateString = formatter.string(from: date)
        return pickupKeyPrefix + dateString
    }
}
