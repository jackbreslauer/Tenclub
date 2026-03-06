//
//  ContentView.swift
//  Tenclub
//
//  Created by Jack Breslauer on 2/11/26.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var pickupTracker = PickupTracker.shared

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            HistoryView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("History")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .environmentObject(locationManager)
        .environmentObject(pickupTracker)
    }
}

// MARK: - Home View
struct HomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var pickupTracker: PickupTracker
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            if locationManager.isAuthorizedAlways {
                // Authorized - show pickup count
                pickupDisplay

            } else if locationManager.authorizationStatus == .notDetermined {
                // First launch - show explanation screen
                permissionExplanationView

            } else {
                // Permission denied or only "When In Use" - show guidance
                permissionNeededView
            }

            Spacer()
        }
        .padding()
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                pickupTracker.refreshTodayCount()
            }
        }
    }

    // MARK: - Pickup Display

    private var pickupDisplay: some View {
        VStack(spacing: 16) {
            PlayingCardView(count: pickupTracker.todayPickupCount)

            Text("\(pickupTracker.todayPickupCount)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("pickups today")
                .font(.title3)
                .foregroundColor(.secondary)

            if pickupTracker.todayPickupCount > 10 {
                Text("No Tenclub today! Better luck tomorrow")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .padding(.top, 8)
            } else {
                Text("\(10 - pickupTracker.todayPickupCount) pickups remaining for Tenclub")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding(.top, 8)
            }
        }
    }

    // MARK: - Permission Explanation View

    private var permissionExplanationView: some View {
        VStack(spacing: 24) {
            Image(systemName: "location.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Why Location Access?")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Tenclub uses background location to detect when you pick up your phone, even when the app is closed.\n\nYour location data is never stored or transmitted - it's only used to keep the app running.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Button {
                locationManager.requestAlwaysAuthorization()
            } label: {
                Text("Enable Tracking")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)

            Text("You'll need to select \"Always Allow\" on the next screen")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Permission Needed View

    private var permissionNeededView: some View {
        VStack(spacing: 24) {
            Image(systemName: "location.slash")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Location Access Required")
                .font(.title2)
                .fontWeight(.semibold)

            Text("To track your pickups in the background, Tenclub needs \"Always Allow\" location access.\n\nPlease update your settings:")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Open Settings")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)

            VStack(alignment: .leading, spacing: 8) {
                Text("Steps:")
                    .font(.caption)
                    .fontWeight(.semibold)
                Text("1. Tap Location")
                Text("2. Select \"Always\"")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
}

// MARK: - History View
struct HistoryView: View {
    @EnvironmentObject var pickupTracker: PickupTracker
    @Environment(\.scenePhase) private var scenePhase

    @State private var history: [(date: Date, count: Int)] = []

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    var body: some View {
        NavigationView {
            List {
                ForEach(history, id: \.date) { entry in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(isToday(entry.date) ? "Today" : dayFormatter.string(from: entry.date))
                                .font(.headline)
                            Text(dateFormatter.string(from: entry.date))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        HStack(spacing: 8) {
                            Text("\(entry.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(entry.count <= 10 ? .green : .primary)

                            if entry.count <= 10 && entry.count > 0 {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("History")
            .onAppear {
                loadHistory()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    loadHistory()
                }
            }
            .refreshable {
                loadHistory()
            }
        }
    }

    private func loadHistory() {
        history = pickupTracker.getHistory(days: 14)
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Location Access")
                        Spacer()
                        Text(locationStatusText)
                            .foregroundColor(locationStatusColor)
                    }

                    if !locationManager.isAuthorizedAlways {
                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                }

                Section {
                    Text("Accountability buddy feature coming in V3")
                        .foregroundColor(.secondary)
                }

                Section("About") {
                    Text("Tenclub tracks how many times you pick up your phone each day. The goal is to stay at 10 or fewer pickups to \"make the Tenclub.\"")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var locationStatusText: String {
        switch locationManager.authorizationStatus {
        case .authorizedAlways:
            return "Always (Active)"
        case .authorizedWhenInUse:
            return "When In Use (Needs Always)"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .notDetermined:
            return "Not Set"
        @unknown default:
            return "Unknown"
        }
    }

    private var locationStatusColor: Color {
        locationManager.isAuthorizedAlways ? .green : .orange
    }
}

#Preview {
    ContentView()
}
