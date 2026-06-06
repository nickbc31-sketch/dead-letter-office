import Foundation

/// Canonical design constraints for future field-investigation content.
enum FieldInvestigationDesignRules {
    static let focusOn: [String] = [
        "terminals", "NPCs", "hidden information", "environmental storytelling",
        "drones", "cameras", "robots", "checkpoints", "access codes",
        "hacking", "puzzles", "clues",
    ]

    static let avoid: [String] = [
        "jumping challenges", "moving platforms", "precision platforming",
        "ladder puzzles", "gantry traversal requirements",
    ]

    static let playerFeeling = "I discovered something."
    static let deprecatedFeeling = "I made a difficult jump."
}
