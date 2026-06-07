import Foundation

// MARK: - Encounter module kinds (A–F)

enum EncounterModuleKind: String, Codable {
    case dronePatrol = "drone_patrol"                       // A
    case gantryBypass = "gantry_bypass"                     // B
    case buildingInvestigation = "building_investigation"   // C
    case terminalInvestigation = "terminal_investigation"   // D
    case npcEncounter = "npc_encounter"                     // E
    case environmentalStory = "environmental_story"         // F
}

// MARK: - Building visual configuration

struct BuildingVisualSpec: Codable {
    var preset: String              // relay_depot, checkpoint, generic
    var width: CGFloat?
    var height: CGFloat?
    var widthScreenFraction: CGFloat?

    func resolvedSize(screenWidth: CGFloat) -> CGSize {
        let w: CGFloat
        if let width {
            w = width
        } else if let fraction = widthScreenFraction {
            w = screenWidth * fraction
        } else {
            w = BuildingVisualSpec.defaultWidth(for: preset)
        }
        let h = height ?? BuildingVisualSpec.defaultHeight(for: preset)
        return CGSize(width: w, height: h)
    }

    static func defaultWidth(for preset: String) -> CGFloat {
        switch preset {
        case "relay_depot": return 380
        case "checkpoint":  return 200
        default:            return 112
        }
    }

    static func defaultHeight(for preset: String) -> CGFloat {
        switch preset {
        case "relay_depot": return 84
        case "checkpoint":  return 132
        default:            return 98
        }
    }
}

// MARK: - Per-module payloads

struct BuildingEncounterConfig: Codable {
    var entranceID: String
    var position: [CGFloat]
    var linkedLevelID: String
    var requiredFlag: String?
    var visual: BuildingVisualSpec
    var signageText: String?
}

struct TerminalEncounterConfig: Codable {
    var id: String
    var position: [CGFloat]
    var requiredFlag: String?
    var setsFlag: String?
    var linkedDialogueID: String?
    var displayText: String?
    var maraObservation: String?
}

struct EnvironmentalEncounterConfig: Codable {
    var x: CGFloat
    var y: CGFloat
    var text: String
    var kind: String?       // "label" (default) | "sign"
    var signID: String?
    var requiredFlag: String?   // Only show when player has this flag (consequence links)
}

struct EncounterModule: Codable, Identifiable {
    var module: String
    var id: String
    var anchorX: CGFloat?

    var patrol: PatrolRoute?
    var platform: PlatformNode?
    var building: BuildingEncounterConfig?
    var terminal: TerminalEncounterConfig?
    var npc: NPCData?
    var environmental: EnvironmentalEncounterConfig?

    var kind: EncounterModuleKind? { EncounterModuleKind(rawValue: module) }
}
