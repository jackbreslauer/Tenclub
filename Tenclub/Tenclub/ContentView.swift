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
    }
}

// MARK: - Home View
struct HomeView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager

    // Filter for today's activity
    private var todayFilter: DeviceActivityFilter {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)

        return DeviceActivityFilter(
            segment: .daily(during: DateInterval(start: startOfDay, end: now))
        )
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            if screenTimeManager.isAuthorized {
                // Authorized - show real pickup count from DeviceActivityReport
                DeviceActivityReport(.totalActivity, filter: todayFilter)
                    .frame(height: 150)

                Spacer()

            } else {
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
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ContentView()
}
