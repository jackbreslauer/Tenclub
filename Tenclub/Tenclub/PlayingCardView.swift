//
//  PlayingCardView.swift
//  Tenclub
//
//  A SwiftUI view that displays playing cards based on pickup count
//

import SwiftUI

// MARK: - Main Pickup Display
struct PlayingCardView: View {
    let unlockCount: Int

    var body: some View {
        if unlockCount >= 100 {
            // 100+: Plain numbers
            PlainNumberView(count: unlockCount)
        } else if unlockCount >= 10 {
            // 10-99: Two cards side by side
            DoubleCardView(count: unlockCount)
        } else {
            // 1-9: Single card
            SingleCardView(value: unlockCount, size: .large)
        }
    }
}

// MARK: - Plain Number View (100+)
struct PlainNumberView: View {
    let count: Int

    var body: some View {
        VStack(spacing: 8) {
            Text("\(count)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
            Text("pickups")
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Double Card View (10-99)
struct DoubleCardView: View {
    let count: Int

    private var tensDigit: Int { count / 10 }
    private var onesDigit: Int { count % 10 }

    var body: some View {
        HStack(spacing: 12) {
            // Tens column
            SingleCardView(value: tensDigit, size: .small)

            // Ones column (0 becomes 10)
            SingleCardView(value: onesDigit == 0 ? 10 : onesDigit, size: .small)
        }
    }
}

// MARK: - Single Card View
enum CardSize {
    case large
    case small

    var width: CGFloat {
        switch self {
        case .large: return 200
        case .small: return 120
        }
    }

    var height: CGFloat { width * 1.4 }

    var labelFont: CGFloat {
        switch self {
        case .large: return 24
        case .small: return 18
        }
    }

    var suitFont: CGFloat {
        switch self {
        case .large: return 18
        case .small: return 14
        }
    }
}

struct SingleCardView: View {
    let value: Int  // 1-10 (1 = Ace, 10 = 10)
    let size: CardSize

    private var label: String {
        value == 1 ? "A" : "\(value)"
    }

    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: size == .large ? 12 : 8)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: size == .large ? 8 : 4, x: 0, y: 2)

            // Card border
            RoundedRectangle(cornerRadius: size == .large ? 12 : 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)

            // Card content
            ClubCardContent(label: label, count: value, size: size)
        }
        .frame(width: size.width, height: size.height)
    }
}

// MARK: - Club Card Content
struct ClubCardContent: View {
    let label: String
    let count: Int
    let size: CardSize

    var body: some View {
        ZStack {
            // Top-left corner
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: size.labelFont, weight: .bold, design: .rounded))
                Text("♣")
                    .font(.system(size: size.suitFont))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(size == .large ? 12 : 8)

            // Bottom-right corner (upside down)
            VStack(spacing: 2) {
                Text("♣")
                    .font(.system(size: size.suitFont))
                Text(label)
                    .font(.system(size: size.labelFont, weight: .bold, design: .rounded))
            }
            .rotationEffect(.degrees(180))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(size == .large ? 12 : 8)

            // Center club symbols
            CenterClubPattern(count: count, size: size)
        }
        .foregroundColor(.black)
    }
}

// MARK: - Center Club Pattern
struct CenterClubPattern: View {
    let count: Int
    let size: CardSize

    // Scale factor for small cards
    private var scale: CGFloat { size == .large ? 1.0 : 0.6 }

    var body: some View {
        if count == 1 {
            // Ace - one large club
            Text("♣")
                .font(.system(size: 80 * scale))
        } else if count <= 3 {
            // 2-3: vertical column
            VStack(spacing: 20 * scale) {
                ForEach(0..<count, id: \.self) { _ in
                    Text("♣")
                        .font(.system(size: 36 * scale))
                }
            }
        } else if count <= 6 {
            // 4-6: two columns
            HStack(spacing: 40 * scale) {
                VStack(spacing: 15 * scale) {
                    ForEach(0..<(count + 1) / 2, id: \.self) { _ in
                        Text("♣")
                            .font(.system(size: 28 * scale))
                    }
                }
                VStack(spacing: 15 * scale) {
                    ForEach(0..<count / 2, id: \.self) { _ in
                        Text("♣")
                            .font(.system(size: 28 * scale))
                    }
                }
            }
        } else {
            // 7-10: simplified pattern
            VStack(spacing: 8 * scale) {
                HStack(spacing: 30 * scale) {
                    Text("♣").font(.system(size: 24 * scale))
                    Text("♣").font(.system(size: 24 * scale))
                }
                Text("♣")
                    .font(.system(size: 50 * scale))
                HStack(spacing: 30 * scale) {
                    Text("♣").font(.system(size: 24 * scale))
                    Text("♣").font(.system(size: 24 * scale))
                }
            }
        }
    }
}

// MARK: - Preview
#Preview("Ace (1)") {
    PlayingCardView(unlockCount: 1)
        .padding()
        .background(Color.gray.opacity(0.2))
}

#Preview("Five (5)") {
    PlayingCardView(unlockCount: 5)
        .padding()
        .background(Color.gray.opacity(0.2))
}

#Preview("Ten (10)") {
    PlayingCardView(unlockCount: 10)
        .padding()
        .background(Color.gray.opacity(0.2))
}

#Preview("Twenty-three (23)") {
    PlayingCardView(unlockCount: 23)
        .padding()
        .background(Color.gray.opacity(0.2))
}

#Preview("Fifty (50)") {
    PlayingCardView(unlockCount: 50)
        .padding()
        .background(Color.gray.opacity(0.2))
}

#Preview("Hundred+ (150)") {
    PlayingCardView(unlockCount: 150)
        .padding()
        .background(Color.gray.opacity(0.2))
}
