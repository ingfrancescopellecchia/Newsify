//
//  Color+Brand.swift
//  Newsify
//

import SwiftUI
import UIKit

extension Color {
    /// Colore del brand con fallback sicuro: se "BrandColor" non è
    /// ancora stato creato nell'Asset Catalog, usa l'accentColor di sistema
    /// invece di far crashare l'app.
    ///
    static var brand: Color {
        if UIColor(named: "BrandColor") != nil {
            return Color("BrandColor")
        } else {
            return .accentColor
        }
    }
}
