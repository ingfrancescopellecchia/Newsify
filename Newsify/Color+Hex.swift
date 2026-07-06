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
    /// // MARK: - Palette colori
    static let notesNavy       = Color(red: 0x00 / 255, green: 0x3D / 255, blue: 0x6C / 255) // #003D6C
    static let notesAccent     = Color(red: 0x00 / 255, green: 0x88 / 255, blue: 0xFF / 255) // #0088FF
    static let notesBackground = Color(red: 0xF4 / 255, green: 0xF4 / 255, blue: 0xF4 / 255) // #F4F4F4
    static let notesSelectedBG = Color(red: 0xED / 255, green: 0xED / 255, blue: 0xED / 255) // #EDEDED

    static var brand: Color {
        if UIColor(named: "BrandColor") != nil {
            return Color("BrandColor")
        } else {
            return .accentColor
        }
    }
}
