import Foundation

struct PhysicsCategory {
    static let none:         UInt32 = 0
    static let player:       UInt32 = 0x1 << 0
    static let ground:       UInt32 = 0x1 << 1
    static let collectible:  UInt32 = 0x1 << 2
    static let enemy:        UInt32 = 0x1 << 3
    static let hazard:       UInt32 = 0x1 << 4
    static let wall:         UInt32 = 0x1 << 5
    static let pickup:       UInt32 = 0x1 << 6
    static let interactable: UInt32 = 0x1 << 7
}
