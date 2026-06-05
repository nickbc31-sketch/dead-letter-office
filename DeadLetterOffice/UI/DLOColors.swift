import SpriteKit

// Central colour palette for the entire game.
// Replace values here to retheme the whole UI.
enum DLOColor {
    // Backgrounds
    static let background       = SKColor(red: 0.03, green: 0.05, blue: 0.08, alpha: 1)
    static let terminalBG       = SKColor(red: 0.05, green: 0.08, blue: 0.12, alpha: 1)
    static let documentBG       = SKColor(red: 0.87, green: 0.84, blue: 0.74, alpha: 1)   // aged paper

    // Text
    static let terminalAmber    = SKColor(red: 1.00, green: 0.71, blue: 0.20, alpha: 1)
    static let terminalGreen    = SKColor(red: 0.39, green: 1.00, blue: 0.39, alpha: 1)
    static let bodyText         = SKColor(red: 0.15, green: 0.12, blue: 0.10, alpha: 1)   // dark ink on paper
    static let dimText          = SKColor(red: 0.45, green: 0.42, blue: 0.35, alpha: 1)

    // Stamps
    static let approveRed       = SKColor(red: 0.80, green: 0.12, blue: 0.12, alpha: 1)
    static let rejectBlue       = SKColor(red: 0.10, green: 0.25, blue: 0.65, alpha: 1)
    static let censorBlack      = SKColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1)
    static let archiveGray      = SKColor(red: 0.40, green: 0.40, blue: 0.40, alpha: 1)
    static let illegalForwardOrange = SKColor(red: 0.90, green: 0.45, blue: 0.05, alpha: 1)
    static let flagAnomaly      = SKColor(red: 0.80, green: 0.65, blue: 0.05, alpha: 1)

    // Platform / world
    static let teal             = SKColor(red: 0.00, green: 0.71, blue: 0.79, alpha: 1)
    static let platformSilhouette = SKColor(red: 0.11, green: 0.15, blue: 0.22, alpha: 1)
    static let scanLight        = SKColor(red: 1.00, green: 0.90, blue: 0.60, alpha: 0.18)

    // UI chrome
    static let uiBorder         = SKColor(red: 0.25, green: 0.35, blue: 0.45, alpha: 1)
    static let highlight        = SKColor(red: 0.00, green: 0.71, blue: 0.79, alpha: 0.4)
    static let danger           = SKColor(red: 0.85, green: 0.15, blue: 0.10, alpha: 1)
}

// Convenience hex parsing (for JSON-driven colors)
extension SKColor {
    static func fromHex(_ hex: String) -> SKColor {
        var h = hex.trimmingCharacters(in: .init(charactersIn: "#"))
        if h.count == 6 { h += "FF" }
        guard h.count == 8, let val = UInt64(h, radix: 16) else { return .white }
        let r = CGFloat((val >> 24) & 0xFF) / 255
        let g = CGFloat((val >> 16) & 0xFF) / 255
        let b = CGFloat((val >> 8)  & 0xFF) / 255
        let a = CGFloat( val        & 0xFF) / 255
        return SKColor(red: r, green: g, blue: b, alpha: a)
    }
}
