import Foundation

// MARK: - Puzzle taxonomy

enum HackPuzzleType: String, Codable, CaseIterable {
    case signalRouting
    case frequencyMatch
    case credentialInjection
    case patternDecode
}

enum HackDifficulty: String, Codable, CaseIterable {
    case easy
    case medium
    case hard
}

enum HackPuzzleResult {
    case success
    case cancelled
    case failed(reason: String)
}

// MARK: - Per-puzzle payloads

struct SignalRoutingConfig: Codable {
    var rows: Int
    var columns: Int
    var startIndex: Int
    var exitIndex: Int
    var blockedIndices: [Int]
    var unstableIndices: [Int]
    /// Optional canonical path for QA; player may use any valid continuous route to EXIT.
    var allowedPath: [Int]?
}

struct FrequencyMatchConfig: Codable {
    var bandCount: Int
    var targetValues: [CGFloat]
    var tolerances: [CGFloat]
    var jitterAmount: CGFloat?
    var autoSuccess: Bool
}

struct CredentialInjectionConfig: Codable {
    var systemRequest: String
    var requiredFragments: [String]
    var availableFragments: [String]
    var distractorFragments: [String]
    var requiredPDATags: [String]?
    var allowPartialHints: Bool
}

struct PatternDecodeConfig: Codable {
    var symbols: [String]
    var sequence: [Int]
    var replayLimit: Int
    var showDurationPerSymbol: TimeInterval
}

// MARK: - Unified puzzle config

struct HackPuzzleConfig: Codable, Identifiable {
    var id: String
    var puzzleType: HackPuzzleType
    var difficulty: HackDifficulty
    var title: String
    var subtitle: String?
    var successMessage: String?
    var failureMessage: String?
    var requiredPDATags: [String]?
    var targetInteractableID: String?
    var requiredFlag: String?
    var setsFlagOnSuccess: String?
    var maxAttempts: Int?
    var timeLimitSeconds: Int?

    var signalRouting: SignalRoutingConfig?
    var frequencyMatch: FrequencyMatchConfig?
    var credentialInjection: CredentialInjectionConfig?
    var patternDecode: PatternDecodeConfig?
}
