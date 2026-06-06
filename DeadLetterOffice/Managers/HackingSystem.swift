import Foundation
import SpriteKit

enum HackingPuzzleKind: String, Codable, CaseIterable {
    case signalRoute       // Tap nodes in sequence
    case circuitRouting
    case signalMatching
    case patternDecode
    case credentialInjection
    case networkBypass
}

struct SignalRoutePuzzlePayload: Codable {
    var nodeLabels: [String]
    var correctSequence: [Int]
}

struct HackingPuzzleSpec: Codable {
    var id: String
    var kind: HackingPuzzleKind
    var title: String
    var targetInteractableID: String?
    var requiredFlag: String?
    var difficulty: Int
    var timeLimitSeconds: Int?
    var setsFlagOnSuccess: String?
    var signalRoute: SignalRoutePuzzlePayload?
}

enum HackingPuzzleResult {
    case success
    case cancelled
    case failed(reason: String)
}

final class HackingSystem {
    static let shared = HackingSystem()
    private init() { registerDefaults() }

    private var catalog: [String: HackingPuzzleSpec] = [:]

    func register(_ spec: HackingPuzzleSpec) { catalog[spec.id] = spec }

    func spec(for id: String) -> HackingPuzzleSpec? { catalog[id] }

    func specForInteractable(_ id: String) -> HackingPuzzleSpec? {
        catalog.values.first { $0.targetInteractableID == id }
    }

    private func registerDefaults() {
        register(HackingPuzzleSpec(
            id: "ch1_checkpoint_bypass",
            kind: .signalRoute,
            title: "CHECKPOINT ARCHIVE BYPASS",
            targetInteractableID: "checkpoint_security_override",
            requiredFlag: "ch1_relay_credential",
            difficulty: 1,
            timeLimitSeconds: nil,
            setsFlagOnSuccess: "ch1_checkpoint_override_used",
            signalRoute: SignalRoutePuzzlePayload(
                nodeLabels: ["RELAY", "GATE", "BUFFER", "ARCHIVE"],
                correctSequence: [0, 1, 3]
            )
        ))
    }
}
