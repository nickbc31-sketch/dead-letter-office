import Foundation

enum CaseConfidenceLevel: String, Codable {
    case correct
    case partial
    case incorrect
}

/// Mara’s private read on desk decisions — never reveals the correct answer.
enum MaraConfidenceAssessor {

    private static let actionWeight: [String: Int] = [
        "approve": 0,
        "archive": 1,
        "reject": 2,
        "censor": 3,
        "flag_anomaly": 4,
        "illegal_forward": 4,
        "broadcast": 5,
        "control": 5,
        "erasure": 5,
    ]

    private static let correctReactions = [
        "That makes sense.",
        "I think that was the right call.",
        "Everything lines up.",
        "That record couldn't be trusted.",
        "Good. That explains the discrepancy.",
    ]

    private static let partialReactions = [
        "Maybe.",
        "I'm not completely convinced.",
        "I still have questions.",
        "That solves part of it.",
        "Something feels unresolved.",
    ]

    private static let incorrectReactions = [
        "No...",
        "Something doesn't add up.",
        "I think I missed something.",
        "That record still bothers me.",
        "Those dates don't make sense.",
    ]

    // MARK: - Assessment

    static func assess(
        caseFile: CaseFile,
        actionID: String,
        flags: Set<String>
    ) -> CaseConfidenceLevel {
        if actionID == caseFile.correctLegalActionID { return .correct }

        if actionID == "flag_anomaly" { return .partial }

        if flags.contains(where: { $0.hasPrefix("deduction_\(caseFile.id)") }) {
            return .partial
        }

        let chosen = actionWeight[actionID] ?? 1
        let preferred = actionWeight[caseFile.correctLegalActionID] ?? 2
        if abs(chosen - preferred) <= 1 { return .partial }

        if actionID == "approve",
           caseFile.contradictions.contains(where: { $0.isCritical }),
           preferred > 0 {
            return .incorrect
        }

        return .incorrect
    }

    // MARK: - Reactions

    static func reaction(for level: CaseConfidenceLevel, caseID: String) -> String {
        let pool: [String]
        switch level {
        case .correct: pool = correctReactions
        case .partial: pool = partialReactions
        case .incorrect: pool = incorrectReactions
        }
        guard !pool.isEmpty else { return "" }
        let idx = abs(caseID.hashValue) % pool.count
        return pool[idx]
    }

    // MARK: - Shift evaluation copy

    static func shortCaseLabel(for caseFile: CaseFile) -> String {
        let parts = caseFile.id.split(separator: "_")
        if parts.count >= 3 {
            let suffix = String(parts[2]).uppercased()
            return "C\(suffix)"
        }
        return caseFile.id.uppercased()
    }

    static func pmcaAssessment(for action: CaseAction) -> String {
        switch action.id {
        case "approve": return "Accepted."
        case "reject": return "Denied."
        case "archive": return "Archived."
        case "censor": return "Censored and cleared."
        case "flag_anomaly": return "Flagged for review."
        case "illegal_forward": return "Routing breach logged."
        case "broadcast": return "Broadcast authorised."
        case "control": return "Controlled distribution."
        case "erasure": return "Erasure processed."
        default:
            return action.auditResponse ?? "Recorded."
        }
    }

    static func maraShiftAssessment(for level: CaseConfidenceLevel) -> String {
        switch level {
        case .correct: return "Decision aligns with the evidence."
        case .partial: return "Potential anomaly overlooked."
        case .incorrect: return "Something doesn't add up in hindsight."
        }
    }

    static func citizenImpact(for action: CaseAction) -> String {
        let harm = action.consequences.citizenHarmDelta ?? 0
        let empathy = action.consequences.empathyDelta ?? 0
        if harm > 0 { return "Citizen harm likely." }
        if harm < 0 { return "Citizens protected." }
        if empathy > 1 { return "Citizen welfare considered." }
        if empathy < -1 { return "Citizens may be affected." }
        return "Unknown."
    }

    // MARK: - Long-term hooks (Ch8 summary, future systems)

    static func confidenceSummary(from records: [String: CaseConfidenceLevel]) -> (correct: Int, partial: Int, incorrect: Int) {
        var correct = 0, partial = 0, incorrect = 0
        for level in records.values {
            switch level {
            case .correct: correct += 1
            case .partial: partial += 1
            case .incorrect: incorrect += 1
            }
        }
        return (correct, partial, incorrect)
    }
}
