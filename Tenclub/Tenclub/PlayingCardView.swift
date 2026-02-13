//
//  PlayingCardView.swift
//  Tenclub
//
//  A SwiftUI view that displays a playing card based on unlock count
//

import SwiftUI

struct PlayingCardView: View {
    let unlockCount: Int

    // Card dimensions (standard playing card ratio is roughly 2.5:3.5)
    private let cardWidth: CGFloat = 200
    private var cardHeight: CGFloat { cardWidth * 1.4 }

    private var isJoker: Bool { unlockCount > 10 }

    private var cardLabel: String {
        if isJoker {
            return "JOKER"
        } else if unlockCount == 1 {
            return "A"
        } else {
            return "\(unlockCount)"
        }
    }

    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)

            // Card border
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)

            if isJoker {
                // Joker card design
                JokerCardContent()
            } else {
                // Number/Ace card design
                ClubCardContent(label: cardLabel, count: unlockCount)
            }
        }
        .frame(width: cardWidth, height: cardHeight)
    }
}

// MARK: - Club Card Content
struct ClubCardContent: View {
    let label: String
    let count: Int

    var body: some View {
        ZStack {
            // Top-left corner
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("♣")
                    .font(.system(size: 18))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(12)

            // Bottom-right corner (upside down)
            VStack(spacing: 2) {
                Text("♣")
                    .font(.system(size: 18))
                Text(label)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
            }
            .rotationEffect(.degrees(180))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(12)

            // Center club symbols
            CenterClubPattern(count: count)
        }
        .foregroundColor(.black)
    }
}

// MARK: - Center Club Pattern
struct CenterClubPattern: View {
    let count: Int

    var body: some View {
        if count == 1 {
            // Ace - one large club
            Text("♣")
                .font(.system(size: 80))
        } else if count <= 3 {
            // 2-3: vertical column
            VStack(spacing: 20) {
                ForEach(0..<count, id: \.self) { _ in
                    Text("♣")
                        .font(.system(size: 36))
                }
            }
        } else if count <= 6 {
            // 4-6: two columns
            HStack(spacing: 40) {
                VStack(spacing: 15) {
                    ForEach(0..<(count + 1) / 2, id: \.self) { _ in
                        Text("♣")
                            .font(.system(size: 28))
                    }
                }
                VStack(spacing: 15) {
                    ForEach(0..<count / 2, id: \.self) { _ in
                        Text("♣")
                            .font(.system(size: 28))
                    }
                }
            }
        } else {
            // 7-10: simplified pattern with number
            VStack(spacing: 8) {
                HStack(spacing: 30) {
                    Text("♣").font(.system(size: 24))
                    Text("♣").font(.system(size: 24))
                }
                Text("♣")
                    .font(.system(size: 50))
                HStack(spacing: 30) {
                    Text("♣").font(.system(size: 24))
                    Text("♣").font(.system(size: 24))
                }
            }
        }
    }
}

// MARK: - Joker Card Content
struct JokerCardContent: View {
    var body: some View {
        ZStack {
            // Top-left corner
            VStack(spacing: 2) {
                Text("J")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("O")
                    .font(.system(size: 14, weight: .bold))
                Text("K")
                    .font(.system(size: 14, weight: .bold))
                Text("E")
                    .font(.system(size: 14, weight: .bold))
                Text("R")
                    .font(.system(size: 14, weight: .bold))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(12)
            .foregroundColor(.red)

            // Bottom-right corner (upside down)
            VStack(spacing: 2) {
                Text("R")
                    .font(.system(size: 14, weight: .bold))
                Text("E")
                    .font(.system(size: 14, weight: .bold))
                Text("K")
                    .font(.system(size: 14, weight: .bold))
                Text("O")
                    .font(.system(size: 14, weight: .bold))
                Text("J")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
            }
            .rotationEffect(.degrees(180))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(12)
            .foregroundColor(.red)

            // Center jester symbol
            VStack(spacing: 4) {
                Text("🃏")
                    .font(.system(size: 60))
                Text("BUSTED!")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
            }
        }
    }
}

// MARK: - Preview
#Preview("Ace") {
    PlayingCardView(unlockCount: 1)
        .padding()
        .background(Color.gray.opacity(0.2))
}

#Preview("Five") {
    PlayingCardView(unlockCount: 5)
        .padding()
        .background(Color.gray.opacity(0.2))
}

#Preview("Ten") {
    PlayingCardView(unlockCount: 10)
        .padding()
        .background(Color.gray.opacity(0.2))
}

#Preview("Joker (11+)") {
    PlayingCardView(unlockCount: 15)
        .padding()
        .background(Color.gray.opacity(0.2))
}
