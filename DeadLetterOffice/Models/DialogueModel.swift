import Foundation

struct DialogueLine: Codable {
    var speaker: String
    var portraitAsset: String?
    var text: String
    var voiceFilter: String?     // "normal", "distorted", "terminal", "radio"
}

struct DialogueChoice: Codable {
    var text: String
    var flagsRequired: [String]?
    var flagsSet: [String]?
    var nextDialogueID: String?
    var consequenceNote: String?
}

struct DialogueNode: Codable, Identifiable {
    var id: String
    var lines: [DialogueLine]
    var choices: [DialogueChoice]?
    var autoAdvance: Bool
    var flagsRequired: [String]?
    var flagsSet: [String]?
    var nextID: String?              // nil = end of dialogue
}

struct DialogueFile: Codable, Identifiable {
    var id: String
    var chapter: String
    var returnSceneHint: String?
    var nodes: [DialogueNode]

    static func load(id: String) -> DialogueFile? {
        guard
            let url = Bundle.main.url(forResource: id, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let file = try? JSONDecoder().decode(DialogueFile.self, from: data)
        else {
            print("[DialogueFile] Could not load \(id).json")
            return nil
        }
        return file
    }
}
