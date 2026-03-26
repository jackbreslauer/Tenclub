//
//  Theme.swift
//  TenclubReport
//
//  Created by Jack Breslauer on 3/26/26.
//

import SwiftUI

struct Theme {
    // MARK: - Colors

    /// Rich deep red - slightly lighter than crimson
    static let red = Color(red: 0.78, green: 0.12, blue: 0.18)  // #C71F2E

    /// Classic black
    static let black = Color.black

    /// Rich gold
    static let gold = Color(red: 0.85, green: 0.65, blue: 0.13)  // #D9A621

    /// For backgrounds and cards
    static let white = Color.white

    // MARK: - Semantic Colors

    static let primary = red
    static let accent = gold
    static let success = gold  // Tenclub achieved
    static let textPrimary = black
    static let textSecondary = Color.gray

    // MARK: - Typography (New York - Light)

    static func largeTitle(_ size: CGFloat = 34) -> Font {
        .system(size: size, weight: .light, design: .serif)
    }

    static func title(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .light, design: .serif)
    }

    static func headline(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }

    static func body(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .light, design: .serif)
    }

    static func caption(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .light, design: .serif)
    }

    // MARK: - Specific App Styles

    /// Bold numbers (for pickup counts)
    static func number(_ size: CGFloat = 48) -> Font {
        .system(size: size, weight: .medium, design: .serif)
    }
}
