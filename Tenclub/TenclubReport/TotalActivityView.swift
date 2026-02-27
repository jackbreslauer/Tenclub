//
//  TotalActivityView.swift
//  TenclubReport
//
//  Created by Jack Breslauer on 2/27/26.
//

import SwiftUI

struct TotalActivityView: View {
    let totalActivity: Int  // Now an Int (pickup count)

    var body: some View {
        VStack(spacing: 8) {
            Text("\(totalActivity)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(totalActivity > 10 ? .red : .primary)

            Text("pickups today")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    TotalActivityView(totalActivity: 7)
}
