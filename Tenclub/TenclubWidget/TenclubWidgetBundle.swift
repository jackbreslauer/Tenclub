//
//  TenclubWidgetBundle.swift
//  TenclubWidget
//
//  Created by Jack Breslauer on 2/27/26.
//

import WidgetKit
import SwiftUI

@main
struct TenclubWidgetBundle: WidgetBundle {
    var body: some Widget {
        TenclubWidget()           // Home screen (small)
        TenclubLockScreenWidget() // Lock screen (circular)
    }
}
