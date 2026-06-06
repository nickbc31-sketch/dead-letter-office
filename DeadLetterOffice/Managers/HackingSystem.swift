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
        register(HackingPuzzleSpec(
            id: "ch2_restricted_bypass",
            kind: .signalRoute,
            title: "RESTRICTED SECTOR RELAY BYPASS",
            targetInteractableID: "ch2_restricted_override",
            requiredFlag: "ch2_maintenance_credential",
            difficulty: 1,
            timeLimitSeconds: nil,
            setsFlagOnSuccess: "ch2_restricted_override_used",
            signalRoute: SignalRoutePuzzlePayload(
                nodeLabels: ["TRANSIT", "BUFFER", "GATE", "SECTOR-4"],
                correctSequence: [0, 2, 3]
            )
        ))
        register(HackingPuzzleSpec(
            id: "ch3_marr_seal_bypass",
            kind: .signalRoute,
            title: "RESIDENTIAL SEAL OVERRIDE",
            targetInteractableID: "override_marr_apt",
            requiredFlag: "c09_processed",
            difficulty: 1,
            timeLimitSeconds: nil,
            setsFlagOnSuccess: "ch3_override_used",
            signalRoute: SignalRoutePuzzlePayload(
                nodeLabels: ["PROPERTY", "MAINT", "SEAL", "UNIT-312"],
                correctSequence: [1, 2, 3]
            )
        ))
    }
}
