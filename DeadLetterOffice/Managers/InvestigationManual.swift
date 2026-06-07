import Foundation

/// PMCA Investigation Manual — in-universe training reference, unlocked gradually.
enum InvestigationManual {

    struct Section: Identifiable {
        let id: String
        let title: String
        let body: String
        let sortOrder: Int
    }

    private static let sections: [Section] = [
        Section(
            id: "desk_basics",
            title: "DESK WORKFLOW",
            body: """
            Every case arrives as a packet: message, supporting records, and a required action.

            1. Open each document tab. Read issuer, date, and reference numbers.
            2. Compare fields across records — timestamps, citizen IDs, and status lines.
            3. Review the anomaly log when discrepancies are flagged.
            4. Use the PDA for observations — not as proof, but as memory.
            5. Stamp one action. The audit voice logs your decision.

            A clean record is not always a true record.
            """,
            sortOrder: 0),
        Section(
            id: "death_record",
            title: "DEATH RECORD ANOMALIES",
            body: """
            Death certificates are auto-sealed by the Registry. Watch for:

            • Death logged before the incident that caused it was filed.
            • Cause of death that does not match transit or medical reports.
            • Missing citizen ID or incomplete registry cross-reference.
            • Certificate issue date earlier than supporting incident reports.

            Compare Date of Death against every related timestamp.
            """,
            sortOrder: 1),
        Section(
            id: "transit",
            title: "TRANSIT ANOMALIES",
            body: """
            Ministry of Transit records move faster than desk packets. Watch for:

            • Incident filed after a death already attributed to that incident.
            • Manifest entries that disagree with casualty lists.
            • Route codes or line numbers absent from the death certificate.
            • Delayed filings that still claim real-time confirmation.

            Transit timestamps are often the first lie in a packet.
            """,
            sortOrder: 2),
        Section(
            id: "housing",
            title: "HOUSING ANOMALIES",
            body: """
            Relocation and occupancy records follow their own schedule. Watch for:

            • Eviction or relocation orders issued while a citizen is listed deceased.
            • Unit seals applied before appeals are resolved.
            • Occupancy status that contradicts the death registry.
            • Housing deadlines that predate the death certificate.

            Housing clerks assume the Registry is current. It often is not.
            """,
            sortOrder: 3),
        Section(
            id: "communication",
            title: "COMMUNICATION ANOMALIES",
            body: """
            Post-mortem messages pass through phrase filters and routing checks. Watch for:

            • Trigger phrases flagged but message still cleared for delivery.
            • Routing metadata that does not match sender or recipient IDs.
            • Message timestamps inconsistent with death or transit records.
            • Corporate or ministry seals on personal correspondence.

            The message may be honest even when the records are not.
            """,
            sortOrder: 4),
        Section(
            id: "employment",
            title: "EMPLOYMENT ANOMALIES",
            body: """
            Employment termination and service-class records lag behind the Registry. Watch for:

            • Termination filed after death but dated before the certificate.
            • Active duty status on records marked deceased.
            • Employer seals that post-date the death notice.
            • Service class changes that affect routing priority.

            Employers receive death notices late. Some exploit the gap.
            """,
            sortOrder: 5),
    ]

    // MARK: - State

    static var unlockedIDs: Set<String> {
        get { PDAJournalManager.state.unlockedManualSectionIDs }
        set {
            var s = PDAJournalManager.state
            s.unlockedManualSectionIDs = newValue
            PDAJournalManager.state = s
        }
    }

    @discardableResult
    static func unlock(_ id: String, notify: Bool = false) -> Bool {
        guard sections.contains(where: { $0.id == id }) else { return false }
        var s = PDAJournalManager.state
        guard !s.unlockedManualSectionIDs.contains(id) else { return false }
        s.unlockedManualSectionIDs.insert(id)
        if notify { s.pendingUpdateNotice = true }
        PDAJournalManager.state = s
        GameState.shared.save()
        return true
    }

    static func unlockTrainingBasics() {
        unlock("desk_basics", notify: false)
    }

    static func onTrainingCaseStart(caseID: String) {
        unlockTrainingBasics()
        switch caseID {
        case "case_training_a":
            break
        case "case_training_b":
            unlock("death_record", notify: false)
            unlock("transit", notify: false)
        case "case_training_c":
            unlock("housing", notify: false)
            unlock("communication", notify: false)
            unlock("employment", notify: false)
        default:
            break
        }
    }

    static func onDocumentOpened(type: DocumentType, caseID: String) {
        switch type {
        case .deathCertificate:
            unlock("death_record", notify: false)
        case .incidentReport:
            unlock("transit", notify: false)
        case .housingRelocation:
            unlock("housing", notify: false)
        case .restrictedPhraseList, .finalMessage:
            unlock("communication", notify: false)
        case .corporateNotice, .citizenRecord:
            if caseID.hasPrefix("case_training") {
                unlock("employment", notify: false)
            }
        default:
            break
        }
    }

    static func onShiftStart(chapterID: String) {
        guard chapterID != "training" else { return }
        unlock("desk_basics", notify: false)
    }

    // MARK: - Body

    static func bodyText() -> String {
        var lines = ["INVESTIGATION MANUAL", "PMCA Clerk Training Reference", ""]
        let unlocked = unlockedIDs
        let ordered = sections.sorted { $0.sortOrder < $1.sortOrder }

        if unlocked.isEmpty {
            lines.append("No sections unlocked yet.")
            lines.append("Complete desk training or review cases to unlock guidance.")
            return lines.joined(separator: "\n")
        }

        for section in ordered {
            if unlocked.contains(section.id) {
                lines.append(section.title)
                lines.append("")
                lines.append(section.body)
                lines.append("")
            } else {
                lines.append("[ LOCKED — \(section.title) ]")
                lines.append("")
            }
        }
        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
