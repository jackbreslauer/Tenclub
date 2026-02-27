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
            Text(totalActivity)
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(pickupCount > 10 ? .red : .primary)

            Text("pickups today")
                .font(.title3)
                .foregroundColor(.secondary)

            if pickupCount > 10 {
                Text("No tenclub today!")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

#Preview {
    TotalActivityView(totalActivity: "7")
}
