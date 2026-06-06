import Foundation

struct NPCData: Codable {
    var id: String
    var position: [CGFloat]      // [x, y]
    var displayName: String
    var dialogue: [String]       // Lines shown sequentially when player talks
    var setsFlag: String?
    var repeatable: Bool?        // If false (default), dialogue only once per level
}

struct PatrolRoute: Codable {
    var enemyType: String
    var points: [[CGFloat]]    // Array of [x, y] pairs
    var speed: CGFloat
    var pauseDuration: TimeInterval
}

struct Interactable: Codable, Identifiable {
    var id: String
    var type: String            // terminal, door, cartridge, cabinet, security_override, building_entrance, building_exit, information_node, text_sign, ladder
    var position: [CGFloat]     // [x, y]
    var requiredFlag: String?
    var requiredFlagsAny: [String]?   // OR gate — any listed flag satisfies access
    var setsFlag: String?
    var linkedInteractableID: String? // security_override → door to open
    var requiredCode: String?   // For locked terminals
    var displayText: String?    // Environmental text
    var cartridgeData: String?  // JSON content inside a data cartridge
    var linkedDialogueID: String?
    var linkedLevelID: String?  // building_entrance → interior level id
    var buildingVisual: BuildingVisualSpec?  // configurable exterior shell (module C)
    var ladderExtent: [CGFloat]?  // [bottomY, topY] for ladder interactables
    var hackPuzzleID: String?     // PDA hack puzzle registry id
    var nodeLabel: String?          // information node / prompt label
}

struct BackgroundLayer: Codable {
    var imageName: String
    var zPosition: CGFloat
    var scrollFactor: CGFloat   // 0 = static, 1 = full scroll
    var yOffset: CGFloat
}

struct PlatformNode: Codable {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var assetName: String?      // e.g. platform_gantry_v1; nil = procedural placeholder
    var visualScale: CGFloat?   // optional art scale multiplier; collision width unchanged
}

struct LevelData: Codable, Identifiable {
    var id: String
    var chapter: String
    var displayName: String
    var tileMapName: String?
    var backgroundLayers: [BackgroundLayer]
    var spawnPoint: [CGFloat]   // [x, y]
    var exits: [[String: String]]   // [{type: "level_end", nextLevelID: "..."}, ...]
    var interactables: [Interactable]
    var patrols: [PatrolRoute]
    var pickups: [[String: String]]
    var environmentalTextNodes: [[String: String]]
    var npcs: [NPCData]?
    var objectiveText: String?
    var ambientMusicTrack: String?
    var platformNodes: [PlatformNode]?
    var encounterSequence: [EncounterModule]?  // modular A–F layout; composed at load
    var parentLevelID: String?      // interior → exterior parent
    var returnSpawnPoint: [CGFloat]? // interior exit spawn on parent level
    var isInterior: Bool?            // compact interior room layout
    var levelWidth: CGFloat
    var levelHeight: CGFloat
    var fieldBoundaryX: CGFloat?    // hard east boundary — security enforcer
    var securityCameras: [SecurityCameraSpec]?

    static func load(id: String) -> LevelData? {
        guard
            let url = Bundle.main.url(forResource: id, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let level = try? JSONDecoder().decode(LevelData.self, from: data)
        else {
            print("[LevelData] Could not load \(id).json")
            return nil
        }
        return level
    }
}
