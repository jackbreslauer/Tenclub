//
//  ContentView.swift
//  Tenclub
//
//  Created by Jack Breslauer on 2/11/26.
//

import SwiftUI
import UIKit
import FamilyControls
import DeviceActivity

// Define the report contexts (must match what's in the extension)
extension DeviceActivityReport.Context {
    static let totalActivity = Self("Total Activity")
    static let historyChart = Self("History Chart")
}

struct ContentView: View {
    @StateObject private var screenTimeManager = ScreenTimeManager.shared

    init() {
        // Apply New York (serif) font to navigation bar titles
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()

        // Large title (when scrolled to top)
        appearance.largeTitleTextAttributes = [
            .font: UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle).withDesign(.serif)!, size: 34)
        ]

        // Inline title (when scrolled)
        appearance.titleTextAttributes = [
            .font: UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline).withDesign(.serif)!, size: 17)
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Today")
                }

            HistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
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

    // Filter for today only
    @State private var activityFilter: DeviceActivityFilter = HomeView.createTodayFilter()

    // Controls whether report is visible (toggling forces re-instantiation)
    @State private var isReportVisible: Bool = true

    // Helper to create a filter for today only
    private static func createTodayFilter() -> DeviceActivityFilter {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        return DeviceActivityFilter(
            segment: .daily(during: DateInterval(start: startOfToday, end: now))
        )
    }

    // Refresh by hiding report, updating filter, then showing again
    private func refreshReport() {
        isReportVisible = false

        // Brief delay, then show report with fresh filter
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            activityFilter = HomeView.createTodayFilter()
            isReportVisible = true
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if screenTimeManager.isAuthorized {
                    // Authorized - show today's pickup count from DeviceActivityReport
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
                        .foregroundColor(Theme.red)
                        .padding(.bottom, 20)

                    Text("Screen Time Access Required")
                        .font(Theme.title())

                    Text("Tenclub needs access to Screen Time data to count your daily unlocks.")
                        .font(Theme.body())
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)

                    Button {
                        Task {
                            await screenTimeManager.requestAuthorization()
                        }
                    } label: {
                        Text("Allow Access")
                            .font(Theme.headline())
                            .foregroundColor(Theme.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Theme.red)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)

                    if let error = screenTimeManager.authorizationError {
                        Text(error)
                            .font(Theme.caption())
                            .foregroundColor(Theme.red)
                            .padding(.top, 10)
                    }

                    Spacer()
                }
            }
            .padding()
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Auto-refresh when app returns to foreground
            if newPhase == .active {
                refreshReport()
            }
        }
    }
}

// MARK: - History View
struct HistoryView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @Environment(\.scenePhase) private var scenePhase

    // Filter for last 7 days
    @State private var activityFilter: DeviceActivityFilter = HistoryView.createWeekFilter()

    // Controls whether report is visible (toggling forces re-instantiation)
    @State private var isReportVisible: Bool = true

    // Helper to create a filter for the last 7 days with daily segments
    private static func createWeekFilter() -> DeviceActivityFilter {
        let calendar = Calendar.current
        let now = Date()
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now))!
        return DeviceActivityFilter(
            segment: .daily(during: DateInterval(start: sevenDaysAgo, end: now))
        )
    }

    // Refresh by hiding report, updating filter, then showing again
    private func refreshReport() {
        isReportVisible = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            activityFilter = HistoryView.createWeekFilter()
            isReportVisible = true
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Blue card back background
                Image("card_back_blue")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .opacity(0.15)

                VStack {
                    if screenTimeManager.isAuthorized {
                        if isReportVisible {
                            DeviceActivityReport(.historyChart, filter: activityFilter)
                        } else {
                            ProgressView()
                        }
                    } else {
                        Text("Screen Time access required")
                            .font(Theme.body())
                            .foregroundColor(Theme.textSecondary)
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
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
                            .font(Theme.body())
                        Spacer()
                        Text(screenTimeManager.isAuthorized ? "Granted" : "Not Granted")
                            .font(Theme.body())
                            .foregroundColor(screenTimeManager.isAuthorized ? Theme.gold : Theme.red)
                    }
                }

                Section {
                    Text("Accountability buddy feature coming in V3")
                        .font(Theme.body())
                        .foregroundColor(Theme.textSecondary)
                }

                Section("About") {
                    Text("Tenclub tracks your daily phone pickups. Stay at 10 or fewer to \"make the Tenclub.\"")
                        .font(Theme.caption())
                        .foregroundColor(Theme.textSecondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ContentView()
}
