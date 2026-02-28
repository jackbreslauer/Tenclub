//
//  TotalActivityView.swift
//  TenclubReport
//
//  Created by Jack Breslauer on 2/27/26.
//

import SwiftUI

struct TotalActivityView: View {
    let totalActivity: String  // Pickup count as string

    private var pickupCount: Int {
        Int(totalActivity) ?? 0
    }

    var body: some View {
        VStack(spacing: 8) {
            PickupCardDisplay(count: pickupCount)

            if pickupCount > 10 {
                Text("No tenclub today!")
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }
        }
        .padding()
    }
}

// MARK: - Pickup Card Display
struct PickupCardDisplay: View {
    let count: Int

    var body: some View {
        if count >= 100 {
            // 100+: Plain numbers
            VStack(spacing: 4) {
                Text("\(count)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                Text("pickups")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } else if count >= 10 {
            // 10-99: Two cards side by side
            HStack(spacing: 8) {
                MiniCardView(value: count / 10)  // Tens digit
                MiniCardView(value: count % 10 == 0 ? 10 : count % 10)  // Ones digit
            }
        } else {
            // 1-9: Single card
            MiniCardView(value: count)
        }
    }
}

// MARK: - Mini Card View (for extension)
struct MiniCardView: View {
    let value: Int  // 1-10

    private var label: String {
        value == 1 ? "A" : "\(value)"
    }

    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)

            // Card border
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)

            // Card content
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("♣")
                    .font(.system(size: 16))
            }
            .foregroundColor(.black)
        }
        .frame(width: 50, height: 70)
    }
}

#Preview("Single digit") {
    TotalActivityView(totalActivity: "7")
}

#Preview("Double digit") {
    TotalActivityView(totalActivity: "23")
}

#Preview("Triple digit") {
    TotalActivityView(totalActivity: "150")
}
