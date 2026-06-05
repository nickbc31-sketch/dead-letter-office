import Foundation

enum ChapterMode: String, Codable {
    case desk
    case platform
    case dialogue
    case ending
}

struct ChapterSegment: Codable, Identifiable {
    var id: String
    var mode: ChapterMode
    var resourceID: String      // Case file ID, level ID, dialogue ID
    var requiredFlags: [String]?
    var setsFlags: [String]?
}

struct ChapterData: Codable, Identifiable {
    var id: String
    var title: String
    var subtitle: String
    var splashImageName: String
    var ambientMusicTrack: String
    var segments: [ChapterSegment]
    var unlockRequires: [String]?   // Flags required to unlock
    var summary: String

    static func loadAll() -> [ChapterData] {
        guard
            let url = Bundle.main.url(forResource: "chapters", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let chapters = try? JSONDecoder().decode([ChapterData].self, from: data)
        else {
            print("[ChapterData] Could not load chapters.json")
            return []
        }
        return chapters
    }

    static func load(id: String) -> ChapterData? {
        return loadAll().first { $0.id == id }
    }
}
