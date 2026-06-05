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
    var type: String            // "terminal", "door", "cartridge", "text_sign", "ladder"
    var position: [CGFloat]     // [x, y]
    var requiredFlag: String?
    var setsFlag: String?
    var requiredCode: String?   // For locked terminals
    var displayText: String?    // Environmental text
    var cartridgeData: String?  // JSON content inside a data cartridge
    var linkedDialogueID: String?
}

struct BackgroundLayer: Codable {
    var imageName: String
    var zPosition: CGFloat
    var scrollFactor: CGFloat   // 0 = static, 1 = full scroll
    var yOffset: CGFloat
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
    var levelWidth: CGFloat
    var levelHeight: CGFloat

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
