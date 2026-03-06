//
//  ContentView.swift
//  Tenclub
//
//  Created by Jack Breslauer on 2/11/26.
//

import SwiftUI
import FamilyControls
import DeviceActivity

// Define the report context (must match what's in the extension)
extension DeviceActivityReport.Context {
    static let totalActivity = Self("Total Activity")
}

struct ContentView: View {
    @StateObject private var screenTimeManager = ScreenTimeManager.shared

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .environmentObject(screenTimeManager)
        .onAppear {
            // Re-check authorization when app appears
            screenTimeManager.checkAuthorizationStatus()
        }
    }
}

// MARK: - Home View
struct HomeView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @Environment(\.scenePhase) private var scenePhase

    // Filter as state so we can update it to trigger refresh
    @State private var activityFilter: DeviceActivityFilter = HomeView.createHistoryFilter()

    // Controls whether report is visible (toggling forces re-instantiation)
    @State private var isReportVisible: Bool = true

    // Helper to create a filter for the last 14 days with daily segments
    private static func createHistoryFilter() -> DeviceActivityFilter {
        let calendar = Calendar.current
        let now = Date()
        let fourteenDaysAgo = calendar.date(byAdding: .day, value: -13, to: calendar.startOfDay(for: now))!
        return DeviceActivityFilter(
            segment: .daily(during: DateInterval(start: fourteenDaysAgo, end: now))
        )
    }

    // Refresh by hiding report, updating filter, then showing again
    private func refreshReport() {
        isReportVisible = false

        // Brief delay, then show report with fresh filter
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            activityFilter = HomeView.createHistoryFilter()
            isReportVisible = true
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            if screenTimeManager.isAuthorized {
                // Authorized - show pickup count and history from DeviceActivityReport
                if isReportVisible {
                    DeviceActivityReport(.totalActivity, filter: activityFilter)
                } else {
                    // Loading placeholder while refreshing
                    ProgressView()
                }

            } else {
                Spacer()
                // Not authorized - show request button
                Image(systemName: "lock.shield")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding(.bottom, 20)

                Text("Screen Time Access Required")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Tenclub needs access to Screen Time data to count your daily unlocks.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)

                Button {
                    Task {
                        await screenTimeManager.requestAuthorization()
                    }
                } label: {
                    Text("Allow Access")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)

                if let error = screenTimeManager.authorizationError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }

                Spacer()
            }
        }
        .padding()
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Auto-refresh when app returns to foreground
            if newPhase == .active {
                refreshReport()
            }
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Screen Time Access")
                        Spacer()
                        Text(screenTimeManager.isAuthorized ? "Granted" : "Not Granted")
                            .foregroundColor(screenTimeManager.isAuthorized ? .green : .red)
                    }
                }

                Section {
                    Text("Accountability buddy feature coming in V3")
                        .foregroundColor(.secondary)
                }

                Section("About") {
                    Text("Tenclub tracks your daily phone pickups. Stay at 10 or fewer to \"make the Tenclub.\"")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ContentView()
}
