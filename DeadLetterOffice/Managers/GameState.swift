import Foundation

// Singleton holding all mutable runtime game state.
final class GameState {

    static let shared = GameState()
    private init() { loadFromSave() }

    // Narrative scores
    var complianceScore: Int = 0
    var empathyScore: Int = 0
    var suspicionScore: Int = 0
    var resistanceTrust: Int = 0
    var corporateTrust: Int = 0
    var citizenHarmCount: Int = 0

    // Progress
    var currentChapterID: String = "ch1"
    var completedCaseIDs: Set<String> = []
    var completedLevelIDs: Set<String> = []
    var activeFlags: Set<String> = []
    var caseDecisions: [String: String] = [:]   // caseID -> actionID

    // Transient platform transition (not persisted)
    var platformSpawnOverride: CGPoint?
    var platformSpawnOverrideLevelID: String?

    // Settings
    var subtitlesEnabled: Bool = true
    var reducedFlashingEnabled: Bool = false
    var textSizeMultiplier: CGFloat = 1.0
    var musicVolume: Float = 0.6
    var sfxVolume: Float = 0.8

    // Convenience
    var isMaraScheduledForDeath: Bool { activeFlags.contains("mara_death_scheduled") }

    func setFlag(_ flag: String) { activeFlags.insert(flag) }
    func clearFlag(_ flag: String) { activeFlags.remove(flag) }
    func hasFlag(_ flag: String) -> Bool { activeFlags.contains(flag) }

    func applyConsequences(_ consequences: ConsequenceMap) {
        complianceScore  += consequences.complianceDelta ?? 0
        empathyScore     += consequences.empathyDelta ?? 0
        suspicionScore   += consequences.suspicionDelta ?? 0
        resistanceTrust  += consequences.resistanceTrustDelta ?? 0
        corporateTrust   += consequences.corporateTrustDelta ?? 0
        citizenHarmCount += consequences.citizenHarmDelta ?? 0
        if let flags = consequences.flagsSet { flags.forEach { setFlag($0) } }
        if let flags = consequences.flagsCleared { flags.forEach { clearFlag($0) } }
    }

    func recordDecision(caseID: String, actionID: String) {
        caseDecisions[caseID] = actionID
        completedCaseIDs.insert(caseID)
    }

    func recordLevelComplete(_ levelID: String) {
        completedLevelIDs.insert(levelID)
    }

    func consumePlatformSpawnOverride(for levelID: String) -> CGPoint? {
        guard platformSpawnOverrideLevelID == levelID, let pt = platformSpawnOverride else { return nil }
        platformSpawnOverride = nil
        platformSpawnOverrideLevelID = nil
        return pt
    }

    func setPlatformSpawnOverride(levelID: String, point: CGPoint) {
        platformSpawnOverrideLevelID = levelID
        platformSpawnOverride = point
    }

    private func loadFromSave() {
        SaveManager.shared.load(into: self)
    }

    func save() {
        SaveManager.shared.save(from: self)
    }

    func resetForNewGame() {
        complianceScore  = 0
        empathyScore     = 0
        suspicionScore   = 0
        resistanceTrust  = 0
        corporateTrust   = 0
        citizenHarmCount = 0
        currentChapterID = "ch1"
        completedCaseIDs = []
        completedLevelIDs = []
        activeFlags      = []
        caseDecisions    = [:]
        // Settings (subtitlesEnabled, reducedFlashingEnabled, textSizeMultiplier,
        // musicVolume, sfxVolume) are preserved across new game starts.
    }
}
