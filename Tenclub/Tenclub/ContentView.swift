//
//  ContentView.swift
//  Tenclub
//
//  Created by Jack Breslauer on 2/11/26.
//

import SwiftUI

struct ContentView: View {
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
    }
}

// MARK: - Home View
struct HomeView: View {
    // Mock data for now - will be replaced with real Screen Time data
    @State private var unlockCount: Int = 7

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Main unlock count display
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
        }
        .padding()
    }
}

// MARK: - Settings View
struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
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
