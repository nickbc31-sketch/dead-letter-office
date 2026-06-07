import Foundation

// MARK: - ConsequenceMap
struct ConsequenceMap: Codable {
    var complianceDelta: Int?
    var empathyDelta: Int?
    var suspicionDelta: Int?
    var resistanceTrustDelta: Int?
    var corporateTrustDelta: Int?
    var citizenHarmDelta: Int?
    var flagsSet: [String]?
    var flagsCleared: [String]?
    var narrativeNote: String?
}

// MARK: - CaseAction
struct CaseAction: Codable, Identifiable {
    var id: String
    var label: String
    var shortLabel: String
    var color: String
    var auditResponse: String?  // Audit Voice log line shown after action
    var consequences: ConsequenceMap
    var resultText: String
    var isIllegal: Bool
}

// MARK: - Contradiction
struct Contradiction: Codable {
    var fieldA: String
    var fieldB: String
    var description: String
    var isCritical: Bool
}

// MARK: - Investigation category (one fact per record type)
struct InvestigationCategory: Codable {
    var category: String   // IDENTITY, TRANSIT, HOUSING, DEATH RECORD, etc.
    var fact: String       // Single deducible fact, e.g. "Declared: 14:22"
}

// MARK: - CaseFile
struct CaseFile: Codable, Identifiable {
    var id: String
    var chapter: String
    var senderName: String
    var senderStatus: String           // "Deceased", "Missing", etc.
    var senderCitizenID: String
    var recipientName: String
    var recipientCitizenID: String
    var messageText: String
    var documents: [DocumentModel]
    var contradictions: [Contradiction]
    var availableActions: [CaseAction]
    var correctLegalActionID: String
    var followUpFlags: [String]?
    var requiredFlags: [String]?       // nil means always available
    var investigationCategories: [InvestigationCategory]?
    var anomalyHook: String?           // Subtle desk prompt — not the answer

    // Load all cases for a chapter from bundled JSON
    static func loadCases(forChapter chapterID: String) -> [CaseFile] {
        let filename = "cases_\(chapterID)"
        guard
            let url = Bundle.main.url(forResource: filename, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let cases = try? JSONDecoder().decode([CaseFile].self, from: data)
        else {
            print("[CaseFile] Could not load \(filename).json")
            return []
        }
        return cases
    }

    static func load(id: String) -> CaseFile? {
        // Search all chapter case files
        for ch in ["ch1","ch2","ch3","ch4","ch5","ch6","ch7","ch8"] {
            let cases = loadCases(forChapter: ch)
            if let found = cases.first(where: { $0.id == id }) { return found }
        }
        return nil
    }
}
