import Foundation

struct SaveData: Codable {
    var complianceScore: Int
    var empathyScore: Int
    var suspicionScore: Int
    var deductionCount: Int?
    var resistanceTrust: Int
    var corporateTrust: Int
    var citizenHarmCount: Int
    var currentChapterID: String
    var completedCaseIDs: [String]
    var completedLevelIDs: [String]
    var activeFlags: [String]
    var caseDecisions: [String: String]
    var subtitlesEnabled: Bool
    var reducedFlashingEnabled: Bool
    var textSizeMultiplier: CGFloat
    var musicVolume: Float
    var sfxVolume: Float
    var notebookUnlockedIDs: [String]?
    var pdaJournal: PDAJournalState?
}

final class SaveManager {

    static let shared = SaveManager()
    private init() {}

    private let saveKey = "DLO_SaveData"

    func save(from state: GameState) {
        let data = SaveData(
            complianceScore: state.complianceScore,
            empathyScore: state.empathyScore,
            suspicionScore: state.suspicionScore,
            deductionCount: state.deductionCount,
            resistanceTrust: state.resistanceTrust,
            corporateTrust: state.corporateTrust,
            citizenHarmCount: state.citizenHarmCount,
            currentChapterID: state.currentChapterID,
            completedCaseIDs: Array(state.completedCaseIDs),
            completedLevelIDs: Array(state.completedLevelIDs),
            activeFlags: Array(state.activeFlags),
            caseDecisions: state.caseDecisions,
            subtitlesEnabled: state.subtitlesEnabled,
            reducedFlashingEnabled: state.reducedFlashingEnabled,
            textSizeMultiplier: state.textSizeMultiplier,
            musicVolume: state.musicVolume,
            sfxVolume: state.sfxVolume,
            notebookUnlockedIDs: Array(state.notebookUnlockedIDs),
            pdaJournal: state.pdaJournal
        )
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    func load(into state: GameState) {
        guard
            let raw = UserDefaults.standard.data(forKey: saveKey),
            let data = try? JSONDecoder().decode(SaveData.self, from: raw)
        else { return }

        state.complianceScore        = data.complianceScore
        state.empathyScore           = data.empathyScore
        state.suspicionScore         = data.suspicionScore
        state.deductionCount         = data.deductionCount ?? 0
        state.resistanceTrust        = data.resistanceTrust
        state.corporateTrust         = data.corporateTrust
        state.citizenHarmCount       = data.citizenHarmCount
        state.currentChapterID       = data.currentChapterID
        state.completedCaseIDs       = Set(data.completedCaseIDs)
        state.completedLevelIDs      = Set(data.completedLevelIDs)
        state.activeFlags            = Set(data.activeFlags)
        state.caseDecisions          = data.caseDecisions
        state.subtitlesEnabled       = data.subtitlesEnabled
        state.reducedFlashingEnabled = data.reducedFlashingEnabled
        state.textSizeMultiplier     = data.textSizeMultiplier
        state.musicVolume            = data.musicVolume
        state.sfxVolume              = data.sfxVolume
        state.notebookUnlockedIDs    = Set(data.notebookUnlockedIDs ?? [])
        state.pdaJournal = data.pdaJournal ?? PDAJournalState()
        NotebookJournalMigration.applyIfNeeded(
            journal: &state.pdaJournal,
            legacyNotebookIDs: state.notebookUnlockedIDs
        )
    }

    func deleteSave() {
        UserDefaults.standard.removeObject(forKey: saveKey)
    }

    var hasSave: Bool {
        UserDefaults.standard.data(forKey: saveKey) != nil
    }
}
