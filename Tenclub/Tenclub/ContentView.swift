//
//  ContentView.swift
//  Tenclub
//
//  Created by Jack Breslauer on 2/11/26.
//

import SwiftUI
import FamilyControls

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

    // Mock data for now - will be replaced with real Screen Time data
    @State private var unlockCount: Int = 7

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            if screenTimeManager.isAuthorized {
                // Authorized - show unlock count
                Text("\(unlockCount)")
                    .font(.system(size: 120, weight: .bold, design: .rounded))
                    .foregroundColor(unlockCount > 10 ? .red : .primary)

                Text("unlocks today")
                    .font(.title2)
                    .foregroundColor(.secondary)

                // Warning message if over 10
                if unlockCount > 10 {
                    Text("No tenclub today! Better luck tomorrow")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                }

                Spacer()

                // Temporary buttons to test the UI (remove later)
                HStack(spacing: 20) {
                    Button("−") {
                        if unlockCount > 0 { unlockCount -= 1 }
                    }
                    .font(.title)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)

                    Button("+") {
                        unlockCount += 1
                    }
                    .font(.title)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
                .padding(.bottom, 40)

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
