import Foundation

/// Investigative guidance for PDA tabs — hints only, never answers.
enum PDAGuidanceResolver {

    private static let maxBulletsPerSection = 5

    // MARK: - Objectives (investigation leads)

    private static let investigationTasks: [String: String] = [
        "ch1_inv_start": "Review desk cases linked to Transit Line 9.",
        "ch1_inv_relay": "Investigate Relay Building routing.",
        "ch2_inv_start": "Cross-check desk death records with field infrastructure.",
        "ch2_inv_field": "Find who uses J.V. maintenance credentials.",
        "ch3_inv_start": "Trace Block P03 and Marr Unit 312 records.",
        "ch3_inv_field": "Locate the Orvin file and resident testimony.",
        "ch4_inv_start": "Follow living-dead registry conflicts to the annex.",
        "ch4_inv_field": "Access Records Annex revision queue.",
        "ch5_inv_start": "Investigate Helix Meridian legacy and trial records.",
        "ch5_inv_field": "Recover TRIAL-0442 evidence in Meridian Heights.",
        "ch6_inv_start": "Map Route 7-B beneath the sealed district.",
        "ch6_inv_field": "Recover black train manifest and Orra fragment.",
        "ch7_inv_start": "Verify Quiet Choir petition signatures.",
        "ch7_inv_field": "Decrypt subnet routing beneath Junction 9.",
        "ch8_inv_start": "Reach Central Archive before cessation deadline.",
    ]

    private static let investigationLookFor: [String: String] = [
        "ch1_inv_start": "Compare death records with transit filings.",
        "ch1_inv_relay": "Check how checkpoint codes relate to case IDs.",
        "ch2_inv_start": "Notice deaths filed before incidents are logged.",
        "ch2_inv_field": "Compare personnel files with active credentials.",
        "ch3_inv_start": "Check housing seals against appeal timestamps.",
        "ch3_inv_field": "Compare resident accounts with PMCA registers.",
        "ch4_inv_start": "Compare voiceprint status with death registry.",
        "ch4_inv_field": "Look for post-burial record amendments.",
        "ch5_inv_start": "Compare trial outcomes with archive stubs.",
        "ch5_inv_field": "Check deletion logs against service-class trials.",
        "ch6_inv_start": "Compare transit manifests with death locations.",
        "ch6_inv_field": "Check biometric readings against termination dates.",
        "ch7_inv_start": "Compare petition signatures with monitoring lists.",
        "ch7_inv_field": "Check relay addresses against living-dead census.",
        "ch8_inv_start": "Compare deletion census with incineration records.",
    ]

    static func currentTask(for entry: JournalEntryDef) -> String {
        if let task = investigationTasks[entry.id] { return task }
        return firstBullet(in: entry.bullets, after: "KEY FACTS")
            ?? entry.bullets.first(where: { !isSectionHeader($0) })
            ?? "Continue the active investigation."
    }

    static func lookFor(for entry: JournalEntryDef) -> String {
        if let hint = investigationLookFor[entry.id] { return hint }
        return firstBullet(in: entry.bullets, after: "OPEN QUESTIONS")
            ?? "Compare flagged records across documents."
    }

    // MARK: - Discoveries (Mara's thoughts)

    private static let discoveryThoughts: [String: String] = [
        "ch1_disc_victim_id": "Death logged before the incident was filed. That can't be right.",
        "ch1_disc_code_format": "Checkpoint codes follow case IDs. Someone built the locks around the victims.",
        "ch1_disc_relay_buffer": "Forty-seven queued messages. Someone's routing off the official channel.",
        "ch1_disc_credential": "Maintenance credentials exist where desk terminals stay blind.",
        "ch1_disc_checkpoint": "The field uses case IDs as keys. The desk never mentioned that.",
        "ch1_disc_haas": "Haas confirmed it — desk terminals don't show all routing data.",
        "ch2_disc_jun_override": "Credentials exist. No personnel file. Ghost identity.",
        "ch2_disc_maintenance": "Someone's badge failed — but the roster says they don't exist.",
        "ch2_disc_evn_buffer": "They're scheduling deletions before clerks see the buffer.",
        "ch2_disc_choir_list": "Lina Marr listed active on a list the desk never showed.",
        "ch2_disc_restricted": "Restricted east sector — credentials without personnel records.",
        "ch3_disc_evn_orphans": "Orphan routing tags. Same class as Elias — audit closed years ago.",
        "ch3_disc_orra_mural": "Saint Orra symbolism flagged. Someone still remembers.",
        "ch3_disc_relocation": "Relocation orders moving faster than appeals.",
        "ch3_disc_marr_unit": "Unit sealed before clearance. Inventory logged — appeal unresolved.",
        "ch3_disc_orvin_note": "Orvin's confession doesn't read like it was voluntary.",
        "ch3_disc_resident_305": "A resident remembers what the register erased.",
        "ch3_disc_hack": "Seal bypass logged. Official channels wouldn't have opened that door.",
        "ch4_disc_ghost_audit": "Living citizens in the audit queue. Registry says otherwise.",
        "ch4_disc_revision": "Records revised after burial. Someone edits truth posthumously.",
        "ch4_disc_deleted": "Predictive deletion — names removed before incidents occur.",
        "ch4_disc_credential": "Annex access needs credentials the desk never issued.",
        "ch5_disc_elias_stub": "Elias erased from the system — not killed. Different kind of death.",
        "ch5_disc_legacy": "The wealthy buy edited afterlives. Service class gets trials.",
        "ch5_disc_camera": "Surveillance sweep matched. Someone's watching the watchers.",
        "ch6_disc_manifest": "Messages held in limbo — not delivered, not destroyed.",
        "ch6_disc_trial": "Still active on the subnet. Death record says otherwise.",
        "ch6_disc_orra": "They're still deleting people. The count rises every day.",
        "ch7_disc_jun": "Declared dead. Still logged in on the infrastructure.",
        "ch7_disc_petition": "Eight hundred forty-seven names beneath the sealed district.",
        "ch7_disc_elias_packet": "Elias still composing on the relay. Erased — not gone.",
        "ch7_disc_pattern": "Pattern unlocks what credentials alone won't.",
        "ch8_disc_census": "Over a million incinerations. The count climbs every day.",
        "ch8_disc_vault": "Orra fragment intact. Some truths survive the fire.",
        "ch1_opt_hidden_choir": "Quiet Choir mark on the wall. Case 1 warned us.",
        "ch2_opt_hidden_jv": "J.V. tag without a roster entry. Second time I've seen that.",
        "ch3_opt_c01_consequence": "My desk stamp left a trace on Block 14.",
        "ch4_opt_abandoned_unit": "Empty unit. Someone paid for a stamp I placed.",
        "ch5_opt_hidden_trial": "TRIAL-0442 — Elias's name on a note they tried to hide.",
        "ch6_opt_jun_tag": "Jun Vale on the carriage. Officially dead.",
        "ch7_opt_elias_tag": "Elias on the relay. That's the second time his name surfaced.",
        "ch8_opt_orra_lamp": "The lamp's still lit. They haven't erased everything.",
    ]

    static func maraThought(for entry: JournalEntryDef) -> String? {
        if let thought = discoveryThoughts[entry.id] { return clampMara(thought) }
        if entry.tags.contains("transit_line_9") {
            return "That's the second transit timing anomaly I've seen."
        }
        if entry.tags.contains("helix_routing") {
            return "Helix infrastructure keeps appearing where desk records stop."
        }
        if entry.tags.contains("elias_venn") {
            return "Elias Venn again. Erased from the registry — not from the network."
        }
        if entry.tags.contains("marr_unit_312") || entry.tags.contains("case_4471") {
            return "The Marr family keeps surfacing. This isn't isolated."
        }
        if entry.tags.contains("quiet_choir") {
            return "Quiet Choir traces everywhere I look."
        }
        return nil
    }

    // MARK: - Desk case assist

    static func currentInvestigationLines(caseFile: CaseFile) -> [String] {
        var lines = ["CURRENT INVESTIGATION", ""]
        let subject = !caseFile.recipientName.isEmpty ? caseFile.recipientName : caseFile.senderName
        lines.append("Citizen: \(subject)")
        lines.append("Review:")
        let categories = caseFile.investigationCategories ?? []
        if categories.isEmpty {
            lines.append("□ Case documents")
            lines.append("□ Anomaly log")
        } else {
            for cat in categories.prefix(maxBulletsPerSection) {
                lines.append("□ \(cat.category)")
            }
        }
        return lines
    }

    /// Escalating hint when player reopens PDA on the same desk case — never the answer.
    static func escalatingDeskHint(caseFile: CaseFile, openCount: Int) -> String? {
        guard openCount >= 2 else { return nil }
        let level = min(openCount - 2, 2)
        if let hints = deskEscalation[caseFile.id], level < hints.count {
            return hints[level]
        }
        return genericEscalation(caseFile: caseFile, level: level)
    }

    private static let deskEscalation: [String: [String]] = [
        "case_ch1_001": [
            "Something about these records doesn't feel right.",
            "The timing looks unusual.",
            "Maybe compare the transit report with the death record.",
        ],
        "case_ch1_002": [
            "Something about these records doesn't feel right.",
            "Death registry and housing don't agree.",
            "Maybe compare occupancy with the PMCA status.",
        ],
        "case_ch1_003": [
            "That corporate seal looks wrong for the date.",
            "Check which seal was valid when the injunction was filed.",
            "Compare the seal reference with the incident record.",
        ],
        "case_ch1_004": [
            "Routing tag doesn't match the family registry.",
            "EVN class keeps appearing in field buffers.",
            "Compare routing metadata with the registry entry.",
        ],
        "case_ch1_005": [
            "Death file is nearly empty. Message isn't.",
            "No citizen ID on the certificate.",
            "Compare the death record with the message origin.",
        ],
    ]

    private static func genericEscalation(caseFile: CaseFile, level: Int) -> String {
        let generic = [
            "Something about these records doesn't feel right.",
            caseFile.anomalyHook ?? "The flagged fields may not align.",
            "Compare documents in the anomaly log categories.",
        ]
        return generic[min(level, generic.count - 1)]
    }

    // MARK: - Terminal observations

    static func clampMara(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }
        var sentences: [String] = []
        var current = ""
        for ch in trimmed {
            current.append(ch)
            if ".!?".contains(ch) {
                let s = current.trimmingCharacters(in: .whitespaces)
                if !s.isEmpty { sentences.append(s) }
                current = ""
                if sentences.count >= 2 { break }
            }
        }
        if sentences.count < 2, !current.trimmingCharacters(in: .whitespaces).isEmpty {
            sentences.append(current.trimmingCharacters(in: .whitespaces))
        }
        return sentences.prefix(2).joined(separator: " ")
    }

    // MARK: - Section caps

    static func cappedEvidenceBullets(_ bullets: [String]) -> [String] {
        var result: [String] = []
        var sectionCount = 0
        for bullet in bullets {
            if isSectionHeader(bullet) {
                sectionCount = 0
                result.append(bullet)
            } else {
                guard sectionCount < maxBulletsPerSection else { continue }
                result.append("• \(bullet)")
                sectionCount += 1
            }
        }
        return result
    }

    static func cappedList(_ items: [String]) -> [String] {
        items.prefix(maxBulletsPerSection).map { "• \($0)" }
    }

    // MARK: - Helpers

    private static let sectionHeaders: Set<String> = [
        "KEY FACTS", "OPEN QUESTIONS",
        "LINKED PEOPLE", "LINKED LOCATIONS", "LINKED CASES",
        "CURRENT TASK", "WHAT TO LOOK FOR", "MARA'S THOUGHTS", "DISCOVERY",
    ]

    private static func isSectionHeader(_ text: String) -> Bool {
        sectionHeaders.contains(text)
    }

    private static func firstBullet(in bullets: [String], after header: String) -> String? {
        guard let idx = bullets.firstIndex(of: header) else { return nil }
        for bullet in bullets[(idx + 1)...] {
            if isSectionHeader(bullet) { break }
            return bullet
        }
        return nil
    }
}
