import Foundation
import SpriteKit

// MARK: - Models

enum JournalSection: String, Codable, CaseIterable {
    case cases = "CASES"
    case investigation = "INVESTIGATION"
    case discoveries = "DISCOVERIES"
    case summary = "SUMMARY"
}

struct JournalEntryDef: Codable {
    let id: String
    let shift: Int
    let section: JournalSection
    let title: String?
    let bullets: [String]
    let tags: [String]
    let sortOrder: Int
}

struct CaseJournalRecord: Codable {
    let caseID: String
    let shift: Int
    let title: String
    let decision: String
    let keyPoints: [String]
    let tags: [String]
}

struct PDAJournalState: Codable {
    var unlockedEntryIDs: Set<String> = []
    var caseRecords: [String: CaseJournalRecord] = [:]
    var unlockedShifts: Set<Int> = [1]
    var bootScreenSeen: Bool = false
    var pendingUpdateNotice: Bool = false
    var deskCasePDAOpenCounts: [String: Int] = [:]
}

// MARK: - Legacy migration (no GameState / PDAJournalManager dependency)

enum NotebookJournalMigration {

    static let notebookToJournal: [String: String] = [
        "ch1_victim_id": "ch1_disc_victim_id",
        "ch1_code_format": "ch1_disc_code_format",
        "ch1_relay_buffer": "ch1_disc_relay_buffer",
        "ch1_credential_note": "ch1_disc_credential",
        "ch1_checkpoint_hint": "ch1_disc_checkpoint",
        "ch2_jun_override": "ch2_disc_jun_override",
        "ch2_maintenance_hint": "ch2_disc_maintenance",
        "ch2_evn_buffer": "ch2_disc_evn_buffer",
        "ch2_choir_list": "ch2_disc_choir_list",
        "ch2_restricted_access": "ch2_disc_restricted",
        "ch3_evn_orphans": "ch3_disc_evn_orphans",
        "ch3_orra_mural": "ch3_disc_orra_mural",
        "ch3_relocation": "ch3_disc_relocation",
        "ch3_marr_unit": "ch3_disc_marr_unit",
        "ch3_orvin_note": "ch3_disc_orvin_note",
    ]

    static func applyIfNeeded(journal: inout PDAJournalState, legacyNotebookIDs: Set<String>) {
        guard journal.unlockedEntryIDs.isEmpty else { return }
        guard !legacyNotebookIDs.isEmpty else { return }
        for oldID in legacyNotebookIDs {
            journal.unlockedEntryIDs.insert(notebookToJournal[oldID] ?? oldID)
        }
    }
}

// MARK: - Manager

/// Mara's persistent investigation journal — survives desk, field, saves, and chapter transitions.
enum PDAJournalManager {

    // MARK: Catalog — Chapters 1–3

    private static let catalog: [String: JournalEntryDef] = {
        var entries: [JournalEntryDef] = []

        // ── Shift 1 — Investigation seeds ───────────────────────────────────
        entries.append(.init(
            id: "ch1_inv_start", shift: 1, section: .investigation, title: nil,
            bullets: [
                "KEY FACTS",
                "Relay Building sits on the desk route for tonight's field check.",
                "Case records mention Transit Line 9 and routing irregularities.",
                "OPEN QUESTIONS",
                "Inner checkpoints use citizen-linked access codes.",
                "If credentials fail, PDA intrusion may bypass sealed doors.",
            ],
            tags: ["transit_line_9", "relay_building"], sortOrder: 0))

        entries.append(.init(
            id: "ch1_inv_relay", shift: 1, section: .investigation, title: nil,
            bullets: [
                "KEY FACTS",
                "Terminal 01 should confirm how checkpoint codes are derived.",
                "OPEN QUESTIONS",
                "Relay Node 7 may hold maintenance credentials.",
                "Sign out of relay consoles before leaving the building.",
            ],
            tags: ["relay_building"], sortOrder: 10))

        // ── Shift 1 — Discoveries ───────────────────────────────────────────
        entries.append(.init(
            id: "ch1_disc_victim_id", shift: 1, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Desk Case 1 — Olen Marr, citizen VC-4471-M.",
                "Death certificate tied to Transit Line 9 derailment.",
                "OPEN QUESTIONS",
                "Who recorded death before the incident was filed?",
            ],
            tags: ["case_4471", "transit_line_9"], sortOrder: 0))

        entries.append(.init(
            id: "ch1_disc_code_format", shift: 1, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Checkpoint codes rotate with active case reference numbers.",
                "Format VC-[XXXX]-M — four middle digits used at keypad.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["case_4471"], sortOrder: 10))

        entries.append(.init(
            id: "ch1_disc_relay_buffer", shift: 1, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Relay Node 7 buffer holds 47 messages in transit.",
                "Routing tag EVN-ROUTING-0442 — Quiet Choir relay buffer.",
                "Scheduled deletion logged — routing anomaly at Node 7.",
                "OPEN QUESTIONS",
                "Who scheduled the buffer deletion?",
            ],
            tags: ["quiet_choir", "elias_venn"], sortOrder: 20))

        entries.append(.init(
            id: "ch1_disc_credential", shift: 1, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Inner checkpoint needs maintenance credential from Relay Node 7.",
                "Locker MNT-RELAY-07 on east wall.",
                "Console login required before credential access.",
                "OPEN QUESTIONS",
                "Who authorised relay locker access?",
            ],
            tags: ["relay_building"], sortOrder: 30))

        entries.append(.init(
            id: "ch1_disc_checkpoint", shift: 1, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Checkpoint code derived from Case 1 victim citizen ID.",
                "PDA override port available at inner checkpoint door.",
                "OPEN QUESTIONS",
                "Why do codes follow case victim IDs?",
            ],
            tags: ["case_4471"], sortOrder: 40))

        entries.append(.init(
            id: "ch1_disc_haas", shift: 1, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Field officer Haas confirms checkpoint codes follow case IDs.",
                "Desk terminals do not surface all routing data.",
                "OPEN QUESTIONS",
                "What routing data is the desk hiding?",
            ],
            tags: ["case_4471"], sortOrder: 50))

        // ── Shift 1 — Summary ───────────────────────────────────────────────
        entries.append(.init(
            id: "ch1_summary", shift: 1, section: .summary, title: nil,
            bullets: [
                "Desk records contain contradictions Mara cannot ignore.",
                "Relay infrastructure routes messages outside official channels.",
                "Case 4471-M connects desk work to physical checkpoint access.",
                "Someone is deleting buffered messages before clerks see them.",
            ],
            tags: ["case_4471", "pmca_record_alteration"], sortOrder: 0))

        // ── Shift 2 — Investigation ─────────────────────────────────────────
        entries.append(.init(
            id: "ch2_inv_start", shift: 2, section: .investigation, title: nil,
            bullets: [
                "KEY FACTS",
                "Desk cases reference real East Transit infrastructure.",
                "Death registrations may precede incident reports.",
                "OPEN QUESTIONS",
                "Maintenance layer credentials exist without personnel records.",
                "Data uplinks may show buffers desk terminals cannot access.",
            ],
            tags: ["helix_routing"], sortOrder: 0))

        entries.append(.init(
            id: "ch2_inv_field", shift: 2, section: .investigation, title: nil,
            bullets: [
                "KEY FACTS",
                "Sector 12 maintenance contact may know who uses J.V. credentials.",
                "OPEN QUESTIONS",
                "Restricted east sector requires physical credential.",
                "Street-level monitoring lists may contradict desk records.",
            ],
            tags: ["quiet_choir"], sortOrder: 10))

        // ── Shift 2 — Discoveries ───────────────────────────────────────────
        entries.append(.init(
            id: "ch2_disc_jun_override", shift: 2, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Sector 12 maintenance log — authorisation J.V., 2147.04.08.",
                "Personnel file: NOT FOUND. Registry cross-check: FAILED.",
                "OPEN QUESTIONS",
                "Who is authorising as J.V.?",
            ],
            tags: ["quiet_choir"], sortOrder: 0))

        entries.append(.init(
            id: "ch2_disc_maintenance", shift: 2, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Worker badge failed east checkpoint — roster absent.",
                "Locker MNT-SEC12-E4 holds maintenance credential.",
                "Restricted sector cartridge hidden behind panel C-9.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["helix_routing"], sortOrder: 10))

        entries.append(.init(
            id: "ch2_disc_evn_buffer", shift: 2, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "East Transit relay buffer — 47 unregistered senders.",
                "Routing class EVN — orphan tags logged.",
                "Desk terminals cannot see this buffer.",
                "OPEN QUESTIONS",
                "Where do orphan tags route?",
            ],
            tags: ["elias_venn", "helix_routing"], sortOrder: 20))

        entries.append(.init(
            id: "ch2_disc_choir_list", shift: 2, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Quiet Choir monitoring list recovered from street cartridge.",
                "MARR, L. listed ACTIVE — desk cases reference same name.",
                "Names exist on civil monitoring PMCA desk does not show.",
                "OPEN QUESTIONS",
                "Why is Marr listed active on street monitors?",
            ],
            tags: ["quiet_choir", "marr_unit_312"], sortOrder: 30))

        entries.append(.init(
            id: "ch2_disc_restricted", shift: 2, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Credential CH2-MAINT-SEC12 opens restricted east transit.",
                "PDA override available at checkpoint if camera sweep active.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["helix_routing"], sortOrder: 40))

        entries.append(.init(
            id: "ch2_summary", shift: 2, section: .summary, title: nil,
            bullets: [
                "Living citizens are being registered dead before incidents are filed.",
                "Helix-linked routing appears in transit infrastructure.",
                "Someone using J.V. credentials moves through maintenance systems.",
                "Desk records and field buffers tell different stories.",
            ],
            tags: ["helix_routing", "citizen_erasure", "pmca_record_alteration"], sortOrder: 0))

        // ── Shift 3 — Investigation ─────────────────────────────────────────
        entries.append(.init(
            id: "ch3_inv_start", shift: 3, section: .investigation, title: nil,
            bullets: [
                "KEY FACTS",
                "Block P03 appears in multiple case records.",
                "Marr Unit 312 was sealed before official clearance.",
                "OPEN QUESTIONS",
                "Resident testimony may contradict PMCA records.",
                "Need to locate the Orvin file.",
                "If direct access is blocked, PDA intrusion may bypass the seal.",
            ],
            tags: ["block_p03", "marr_unit_312"], sortOrder: 0))

        entries.append(.init(
            id: "ch3_inv_field", shift: 3, section: .investigation, title: nil,
            bullets: [
                "KEY FACTS",
                "Check resident directory and mailbox row for Marr references.",
                "Apartment terminal may hold sealing inventory.",
                "OPEN QUESTIONS",
                "Second drone at checkpoint logs all passers-by.",
                "Orvin file may link Block P03 to earlier transit cases.",
            ],
            tags: ["block_p03", "marr_unit_312"], sortOrder: 10))

        // ── Shift 3 — Discoveries ───────────────────────────────────────────
        entries.append(.init(
            id: "ch3_disc_evn_orphans", shift: 3, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Block P03 register shows EVN orphan routing tags.",
                "Same routing class as Elias desk tag — audit closed 2142.",
                "Clerk terminals do not surface these entries.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["elias_venn", "block_p03", "helix_routing"], sortOrder: 0))

        entries.append(.init(
            id: "ch3_disc_orra_mural", shift: 3, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Community mural references Saint Orra — restored 2138.",
                "PMCA notice flags unauthorised symbolism.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["saint_orra", "quiet_choir"], sortOrder: 10))

        entries.append(.init(
            id: "ch3_disc_relocation", shift: 3, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Batch relocation order Q1 2147 — Units 301-318 cleared in one morning.",
                "Families told relatives already processed before notification sent.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["block_p03", "citizen_erasure"], sortOrder: 20))

        entries.append(.init(
            id: "ch3_disc_marr_unit", shift: 3, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Unit 312 sealing inventory — Marr, L., death 2147.03.18.",
                "Appeal in processing at desk when unit was sealed.",
                "Housing register knew before appeal reached clerks.",
                "OPEN QUESTIONS",
                "Who sealed the unit before clearance?",
            ],
            tags: ["marr_unit_312", "pmca_record_alteration"], sortOrder: 30))

        entries.append(.init(
            id: "ch3_disc_orvin_note", shift: 3, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Orvin, K. — handwritten note recovered pre-incineration.",
                "Confession signed under guardian threat.",
                "Harrel signed death and destruction minutes apart.",
                "OPEN QUESTIONS",
                "What does the Orvin file prove?",
            ],
            tags: ["block_p03"], sortOrder: 40))

        entries.append(.init(
            id: "ch3_disc_resident_305", shift: 3, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Resident in Unit 305 says L. Marr filed an appeal.",
                "Remembers people PMCA records now omit.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["marr_unit_312", "citizen_erasure"], sortOrder: 50))

        entries.append(.init(
            id: "ch3_disc_hack", shift: 3, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "PDA route trace bypassed Unit 312 seal gate.",
                "Seal predates official clearance order on record.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["marr_unit_312", "helix_routing"], sortOrder: 60))

        entries.append(.init(
            id: "ch3_summary", shift: 3, section: .summary, title: nil,
            bullets: [
                "Marr's apartment was sealed before the official clearance order.",
                "Residents remember people PMCA records now omit.",
                "Helix-linked routing appears in residential security systems.",
                "Mara suspects desk records are being altered before reaching clerks.",
            ],
            tags: ["marr_unit_312", "pmca_record_alteration", "helix_routing"], sortOrder: 0))

        // ── Shift 4 — Investigation ─────────────────────────────────────────
        entries.append(.init(
            id: "ch4_inv_start", shift: 4, section: .investigation, title: nil,
            bullets: [
                "KEY FACTS",
                "Lina Marr reached me through Dead Letter — living, registered dead.",
                "My own cessation notice arrived at the desk.",
                "OPEN QUESTIONS",
                "Calyx memo predicts actions before they occur.",
                "Records Annex P04 — post-burial revision queue 7-B.",
            ],
            tags: ["marr_unit_312", "pmca_record_alteration"], sortOrder: 0))
        entries.append(.init(
            id: "ch4_inv_field", shift: 4, section: .investigation, title: nil,
            bullets: [
                "KEY FACTS",
                "Ghost Audit terminal confirms scheduled mortality.",
                "OPEN QUESTIONS",
                "Archive vault needs credential injection — case link + clerk ID.",
                "Deleted record cartridge may survive revision queue purge.",
            ],
            tags: ["elias_venn", "case_4471"], sortOrder: 10))

        // ── Shift 4 — Discoveries ───────────────────────────────────────────
        entries.append(.init(
            id: "ch4_disc_ghost_audit", shift: 4, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Ghost Audit score elevated — cessation Order 66-C.",
                "Predictive assessment predates case filing.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["pmca_record_alteration"], sortOrder: 0))
        entries.append(.init(
            id: "ch4_disc_revision", shift: 4, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Revision queue 7-B — 847 post-burial death amendments.",
                "Case 4471-M cause of death revised after burial.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["case_4471", "pmca_record_alteration"], sortOrder: 10))
        entries.append(.init(
            id: "ch4_disc_deleted", shift: 4, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Leaked predictive assessment — predates C12, C13, C14 filing.",
                "Calyx scheduled mortality before cases reached queue.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["citizen_erasure", "pmca_record_alteration"], sortOrder: 20))
        entries.append(.init(
            id: "ch4_disc_credential", shift: 4, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "PDA credential injection bypassed archive vault seal.",
                "Fragments: clerk ID, Ghost Audit, P04 vault authority.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["elias_venn"], sortOrder: 30))
        entries.append(.init(
            id: "ch4_summary", shift: 4, section: .summary, title: nil,
            bullets: [
                "Death records are being rewritten after burial.",
                "Calyx anticipated my annex visit.",
                "Lina Marr is alive — Dead Letter route still works.",
                "My cessation is scheduled — three days.",
            ],
            tags: ["pmca_record_alteration", "marr_unit_312", "elias_venn"], sortOrder: 0))

        // ── Shift 5 — Investigation ─────────────────────────────────────────
        entries.append(.init(
            id: "ch5_inv_start", shift: 5, section: .investigation, title: nil,
            bullets: [
                "KEY FACTS",
                "Elias archive stub — closure without closure.",
                "Afterlife Premium — paid legacy edits for wealthy citizens.",
                "OPEN QUESTIONS",
                "Helix Meridian controls grief infrastructure.",
                "Corporate deletion engines vs Tier 3 premium vaults.",
            ],
            tags: ["elias_venn", "helix_routing"], sortOrder: 0))
        entries.append(.init(
            id: "ch5_inv_field", shift: 5, section: .investigation, title: nil,
            bullets: [
                "KEY FACTS",
                "Legacy terminal shows routing anomalies to Helix nodes.",
                "OPEN QUESTIONS",
                "Security camera bypass needed for executive corridor.",
                "TRIAL-0442 referenced in corporate deletion logs.",
            ],
            tags: ["helix_routing"], sortOrder: 10))
        entries.append(.init(
            id: "ch5_disc_elias_stub", shift: 5, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Elias Venn archive stub — officially dead 2142.",
                "Network engineer routing tags still active.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["elias_venn"], sortOrder: 0))
        entries.append(.init(
            id: "ch5_disc_legacy", shift: 5, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Sera Quill legacy edit — paid erasure of Kell Orvin.",
                "Poor citizens routed to deletion engines.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["helix_routing", "citizen_erasure"], sortOrder: 10))
        entries.append(.init(
            id: "ch5_disc_camera", shift: 5, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Helix camera sweep bypassed via frequency match.",
                "Executive corridor leads to transit routing core.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["helix_routing"], sortOrder: 20))
        entries.append(.init(
            id: "ch5_summary", shift: 5, section: .summary, title: nil,
            bullets: [
                "Helix Meridian controls infrastructure behind PMCA.",
                "Wealth buys edited deaths — poverty buys deletion.",
                "Elias trial data still generating signals.",
            ],
            tags: ["helix_routing", "elias_venn", "citizen_erasure"], sortOrder: 0))

        // ── Shift 6 — Investigation ─────────────────────────────────────────
        entries.append(.init(
            id: "ch6_inv_start", shift: 6, section: .investigation, title: nil,
            bullets: [
                "KEY FACTS",
                "TRIAL-0442 biometric data post-dates Elias death.",
                "OPEN QUESTIONS",
                "Saint Orra fragment — deletion count still rising.",
                "Black Mail Train manifest — Route 7-B under sealed district.",
            ],
            tags: ["elias_venn", "saint_orra", "quiet_choir"], sortOrder: 0))
        entries.append(.init(
            id: "ch6_inv_field", shift: 6, section: .investigation, title: nil,
            bullets: [
                "KEY FACTS",
                "Transit manifest lists citizens declared dead.",
                "OPEN QUESTIONS",
                "Checkpoint security — frequency match for Route 7-B.",
                "Orra fragment cartridge on train car 2.",
            ],
            tags: ["citizen_erasure", "transit_line_9"], sortOrder: 10))
        entries.append(.init(
            id: "ch6_disc_manifest", shift: 6, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Transit manifest — declared-dead citizens in motion.",
                "Destination: sealed district processing.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["citizen_erasure"], sortOrder: 0))
        entries.append(.init(
            id: "ch6_disc_trial", shift: 6, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "TRIAL-0442 termination filed 2142 — biometrics ACTIVE 2147.",
                "Lena Harrow signed termination order.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["elias_venn"], sortOrder: 10))
        entries.append(.init(
            id: "ch6_disc_orra", shift: 6, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Orra fragment — census methodology from 2130.",
                "Deletion count: 1,247,883 and rising.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["saint_orra", "quiet_choir"], sortOrder: 20))
        entries.append(.init(
            id: "ch6_summary", shift: 6, section: .summary, title: nil,
            bullets: [
                "Citizens declared dead are being moved — not buried.",
                "Elias trial never fully terminated.",
                "Train Route 7-B connects Helix to sealed district.",
            ],
            tags: ["elias_venn", "citizen_erasure", "saint_orra"], sortOrder: 0))

        // ── Shift 7 — Investigation ─────────────────────────────────────────
        entries.append(.init(
            id: "ch7_inv_start", shift: 7, section: .investigation, title: nil,
            bullets: [
                "KEY FACTS",
                "Jun Vale — officially dead, active in maintenance systems.",
                "OPEN QUESTIONS",
                "Quiet Choir petition — forged signatures on resistance list.",
                "Elias final packet fragments across three systems.",
            ],
            tags: ["quiet_choir", "elias_venn"], sortOrder: 0))
        entries.append(.init(
            id: "ch7_inv_field", shift: 7, section: .investigation, title: nil,
            bullets: [
                "KEY FACTS",
                "Undercity relay — encrypted messages need pattern decode.",
                "OPEN QUESTIONS",
                "Resistance archives behind choir seal gate.",
                "Census wall — 847 names, 14 forgeries marked.",
            ],
            tags: ["quiet_choir", "saint_orra"], sortOrder: 10))
        entries.append(.init(
            id: "ch7_disc_jun", shift: 7, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Jun Vale maintains relay nodes under dead identity.",
                "J.V. credentials match Ch2 maintenance logs.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["quiet_choir", "helix_routing"], sortOrder: 0))
        entries.append(.init(
            id: "ch7_disc_petition", shift: 7, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Quiet Choir petition — 14 forged signatures inserted by PMCA.",
                "Resistance list used to justify erasure.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["quiet_choir", "citizen_erasure"], sortOrder: 10))
        entries.append(.init(
            id: "ch7_disc_elias_packet", shift: 7, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Elias final packet — fragments in transit, archive, choir relay.",
                "Complete truth requires Central Archive.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["elias_venn"], sortOrder: 20))
        entries.append(.init(
            id: "ch7_disc_pattern", shift: 7, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Pattern decode opened choir resistance archive.",
                "Saint Orra's movement survived underground.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["saint_orra", "quiet_choir"], sortOrder: 30))
        entries.append(.init(
            id: "ch7_summary", shift: 7, section: .summary, title: nil,
            bullets: [
                "Quiet Choir preserved communications PMCA hid for years.",
                "Jun and Elias threads converge at Central Archive.",
                "Final shift authorised — one case, three endings.",
            ],
            tags: ["quiet_choir", "elias_venn", "saint_orra"], sortOrder: 0))

        // ── Shift 8 — Investigation ─────────────────────────────────────────
        entries.append(.init(
            id: "ch8_inv_start", shift: 8, section: .investigation, title: nil,
            bullets: [
                "KEY FACTS",
                "Central Archive infiltration — dual hack required.",
                "Retrieve complete Orra letter + deletion census.",
                "OPEN QUESTIONS",
                "TRIAL-0442 termination record in Vault 1.",
                "Final desk case: broadcast, control, or erasure.",
            ],
            tags: ["saint_orra", "elias_venn"], sortOrder: 0))
        entries.append(.init(
            id: "ch8_disc_census", shift: 8, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Deletion census — 1,247,883 erased citizens catalogued.",
                "412,000 at Orra's execution — methodology still valid.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["saint_orra", "citizen_erasure"], sortOrder: 0))
        entries.append(.init(
            id: "ch8_disc_vault", shift: 8, section: .discoveries, title: nil,
            bullets: [
                "KEY FACTS",
                "Vault 1 credential accepted — ORRA-SEAL + CENSUS + 2130.",
                "Complete letter retrieved before Calyx arrival.",
                "OPEN QUESTIONS",
                "What connects these records?",
            ],
            tags: ["saint_orra"], sortOrder: 10))
        entries.append(.init(
            id: "ch8_summary", shift: 8, section: .summary, title: nil,
            bullets: [
                "Elias Venn — TRIAL-0442 was memory-cleaning experiment.",
                "PMCA system purpose: process what cannot be destroyed.",
                "Final choice determines city's truth — or its burial.",
            ],
            tags: ["elias_venn", "saint_orra", "pmca_record_alteration"], sortOrder: 0))

        // ── Optional discoveries (exploration rewards, not required) ─────────
        let optionalDiscoveries: [(shift: Int, id: String, facts: [String], question: String, tags: [String])] = [
            (1, "ch1_opt_hidden_choir", ["Quiet Choir graffiti near restricted zone.", "Phrase matches Case 1 message."], "What connects these records?", ["quiet_choir", "case_4471"]),
            (2, "ch2_opt_hidden_jv", ["Jun Vale tag on maintenance wall.", "No personnel file on record."], "Who is authorising as J.V.?", ["helix_routing", "quiet_choir"]),
            (3, "ch3_opt_c01_consequence", ["Shift 1 decision visible on Block 14.", "Relocation or denial left a trace."], "What did my desk action cause?", ["case_4471", "marr_unit_312"]),
            (4, "ch4_opt_abandoned_unit", ["Unit 7C vacant — Arden Sol relocation.", "Desk rejection may have accelerated vacancy."], "Who paid the cost of my stamp?", ["citizen_erasure"]),
            (5, "ch5_opt_hidden_trial", ["Staff note references TRIAL-0442.", "Elias Venn name on classified stub."], "Memory deletion — not death.", ["elias_venn", "helix_routing"]),
            (6, "ch6_opt_jun_tag", ["Jun Vale carriage maintenance tag.", "Officially dead — still on Route 7-B."], "Who runs the black train?", ["helix_routing", "quiet_choir"]),
            (7, "ch7_opt_elias_tag", ["Elias Venn relay address recovered.", "Still composing after termination."], "Erased — not killed.", ["elias_venn"]),
            (8, "ch8_opt_orra_lamp", ["Saint Orra lamp still lit in archive.", "Deletion count climbs daily."], "What truth survives incineration?", ["saint_orra", "pmca_record_alteration"]),
        ]
        for opt in optionalDiscoveries {
            entries.append(.init(
                id: opt.id, shift: opt.shift, section: .discoveries, title: "OPTIONAL",
                bullets: ["KEY FACTS", opt.facts[0], opt.facts[1], "OPEN QUESTIONS", opt.question],
                tags: opt.tags, sortOrder: 900 + opt.shift))
        }

        return Dictionary(uniqueKeysWithValues: entries.map { ($0.id, $0) })
    }()

    private static let caseCatalog: [String: (shift: Int, title: String, keyPoints: [String], tags: [String])] = [
        "case_ch1_001": (1, "CASE 4471-M — TRANSIT DEATH", [
            "Citizen ID contains 4471.",
            "Death record references Transit Line 9.",
            "Record includes routing irregularity.",
            "Possible connection to Relay Building access.",
        ], ["case_4471", "transit_line_9"]),
        "case_ch1_002": (1, "CASE — MIRA SOL", [
            "Recipient listed as living on delivery manifest.",
            "Death certificate already filed.",
            "Living/dead status conflict in same shift.",
        ], ["citizen_erasure"]),
        "case_ch1_003": (1, "CASE — TOVIN KADE", [
            "Helix Meridian seal appears forged.",
            "Corporate routing tag on civilian message.",
        ], ["helix_routing"]),
        "case_ch1_004": (1, "CASE — NELLA VOSS", [
            "Routing tag EVN-ROUTING-0442 on message.",
            "Same class as Elias Venn desk records.",
            "Personal stake — family connection.",
        ], ["elias_venn", "helix_routing"]),
        "case_ch1_005": (1, "CASE — UNKNOWN SENDER", [
            "Message states: I AM NOT DEAD.",
            "Glitch animation on final case.",
            "System integrity warning triggered.",
        ], ["citizen_erasure", "pmca_record_alteration"]),
        "case_ch2_001": (2, "CASE C06 — GARR SEN", [
            "Death registered before incident report filed.",
            "Voiceprint verified ACTIVE after recorded death.",
            "Gate camera shows subject after official death time.",
        ], ["citizen_erasure", "helix_routing"]),
        "case_ch2_002": (2, "CASE — INFRASTRUCTURE ROUTING", [
            "Desk queue references Helix administrative interest.",
            "Housing unit tied to transit fatality closure.",
        ], ["helix_routing"]),
        "case_ch2_003": (2, "CASE — BUFFER ANOMALY", [
            "EVN-class messages in transit buffer.",
            "Scheduled deletion before clerk review.",
        ], ["elias_venn", "pmca_record_alteration"]),
        "case_ch3_001a": (3, "CASE C09A — LINA MARR APPEAL", [
            "Posthumous appeal filed under Statute 11-G.",
            "Monitoring flag applied before any wrongdoing.",
            "Standard routing — no independent reviewer.",
        ], ["marr_unit_312", "block_p03"]),
        "case_ch3_001b": (3, "CASE — MARR FAMILY RECORD", [
            "Father's message referenced in daughter's appeal.",
            "Relocation enforced posthumously.",
        ], ["marr_unit_312", "case_4471"]),
        "case_ch3_001c": (3, "CASE — SEALING ORDER", [
            "Unit 312 sealed with inventory logged.",
            "Appeal status unresolved at time of seal.",
        ], ["marr_unit_312", "pmca_record_alteration"]),
        "case_ch3_001d": (3, "CASE — HOUSING REGISTER", [
            "Register updated before appeal notification sent.",
            "Desk and housing systems out of sync.",
        ], ["marr_unit_312", "citizen_erasure"]),
        "case_ch3_002": (3, "CASE — ORVIN CONFESSION", [
            "Signed confession recovered from Unit 204.",
            "Coerced signature under guardian threat.",
        ], ["block_p03"]),
        "case_ch3_003": (3, "CASE — BATCH RELOCATION", [
            "Nine units cleared in single morning.",
            "Block P03 batch reference PMCA-REL-0441.",
        ], ["block_p03", "citizen_erasure"]),
        "case_ch4_001": (4, "CASE C12 — LINA MARR LIVING", [
            "Living sender via Dead Letter channel.",
            "Voiceprint ACTIVE — registry says deceased.",
            "Points to Records Annex revision queue.",
        ], ["marr_unit_312", "pmca_record_alteration"]),
        "case_ch4_002": (4, "CASE C13 — MARA CESSATION", [
            "Clerk receives own scheduled death notice.",
            "Cessation Order 66-C — 72 hours.",
            "Calyx memo references annex access.",
        ], ["pmca_record_alteration"]),
        "case_ch4_003": (4, "CASE C14 — CALYX MEMO", [
            "Director predicts clerk actions before they occur.",
            "Revision queue 7-B — post-burial amendments.",
            "Dead Letter Office — clerks witness truth.",
        ], ["elias_venn", "pmca_record_alteration"]),
        "case_ch5_001": (5, "CASE C15 — ELIAS ARCHIVE STUB", [
            "Elias Venn — declared dead 2142.",
            "Archive stub with no closure element.",
            "TRIAL-0442 routing still active.",
        ], ["elias_venn", "helix_routing"]),
        "case_ch5_002": (5, "CASE C16 — SERA QUILL LEGACY", [
            "Paid legacy edit — wealthy citizen.",
            "Erasure of Kell Orvin connection.",
        ], ["helix_routing", "citizen_erasure"]),
        "case_ch5_003": (5, "CASE C17 — EXECUTIVE PELL", [
            "Three valid final messages — corporate choice.",
            "Afterlife Premium tier access.",
        ], ["helix_routing"]),
        "case_ch6_001": (6, "CASE C18 — LENA HARROW", [
            "TRIAL-0442 termination filed post-Elias death.",
            "Biometric data still generating.",
        ], ["elias_venn"]),
        "case_ch6_002": (6, "CASE C19 — ORRA FRAGMENT", [
            "Saint Orra fragment — deletion count rising.",
            "Census methodology from 2130.",
        ], ["saint_orra", "quiet_choir"]),
        "case_ch6_003": (6, "CASE C20 — BLACK TRAIN MANIFEST", [
            "Route 7-B under sealed district.",
            "Declared-dead citizens in transit.",
        ], ["citizen_erasure", "transit_line_9"]),
        "case_ch7_001": (7, "CASE C21 — JUN VALE", [
            "Officially dead — active in systems.",
            "Quiet Choir maintenance contact.",
        ], ["quiet_choir", "helix_routing"]),
        "case_ch7_002": (7, "CASE C22 — CHOIR PETITION", [
            "Forged signatures on resistance list.",
            "PMCA inserted names to justify erasure.",
        ], ["quiet_choir", "citizen_erasure"]),
        "case_ch7_003": (7, "CASE C23 — ELIAS FINAL PACKET", [
            "Fragments across three systems.",
            "Points to Central Archive complete record.",
        ], ["elias_venn"]),
        "case_ch8_001": (8, "CASE C24 — ORRA COMPLETE LETTER", [
            "Broadcast, control, or erasure pathway.",
            "1.2M erased citizens in census.",
            "Final shift — determines ending.",
        ], ["saint_orra", "elias_venn", "pmca_record_alteration"]),
    ]

    private static let shiftSummaries: [Int: String] = [
        1: "ch1_summary",
        2: "ch2_summary",
        3: "ch3_summary",
        4: "ch4_summary",
        5: "ch5_summary",
        6: "ch6_summary",
        7: "ch7_summary",
        8: "ch8_summary",
    ]

    private static let shiftInvestigationSeeds: [Int: [String]] = [
        1: ["ch1_inv_start"],
        2: ["ch2_inv_start"],
        3: ["ch3_inv_start"],
        4: ["ch4_inv_start"],
        5: ["ch5_inv_start"],
        6: ["ch6_inv_start"],
        7: ["ch7_inv_start"],
        8: ["ch8_inv_start"],
    ]

    // MARK: - State access

    static var state: PDAJournalState {
        get { GameState.shared.pdaJournal }
        set { GameState.shared.pdaJournal = newValue }
    }

    static func migrateFromLegacyNotebookIfNeeded(
        journal: inout PDAJournalState,
        legacyNotebookIDs: Set<String>
    ) {
        NotebookJournalMigration.applyIfNeeded(
            journal: &journal,
            legacyNotebookIDs: legacyNotebookIDs
        )
    }

    static func migrateFromLegacyNotebookIfNeeded() {
        var journal = GameState.shared.pdaJournal
        NotebookJournalMigration.applyIfNeeded(
            journal: &journal,
            legacyNotebookIDs: GameState.shared.notebookUnlockedIDs
        )
        GameState.shared.pdaJournal = journal
    }

    // MARK: - Unlock API

    @discardableResult
    static func unlock(_ id: String, notify: Bool = true) -> Bool {
        guard catalog[id] != nil else { return false }
        var s = state
        guard !s.unlockedEntryIDs.contains(id) else { return false }
        s.unlockedEntryIDs.insert(id)
        if let entry = catalog[id] {
            s.unlockedShifts.insert(entry.shift)
        }
        if notify { s.pendingUpdateNotice = true }
        state = s
        GameState.shared.save()
        return true
    }

    static func consumeUpdateNotice() -> Bool {
        var s = state
        guard s.pendingUpdateNotice else { return false }
        s.pendingUpdateNotice = false
        state = s
        return true
    }

    static func markBootSeen() {
        var s = state
        s.bootScreenSeen = true
        state = s
        GameState.shared.save()
    }

    static func unlockShift(_ shift: Int) {
        var s = state
        s.unlockedShifts.insert(shift)
        state = s
    }

    static func onShiftStart(chapterID: String) {
        migrateFromLegacyNotebookIfNeeded()
        let shift = shiftNumber(from: chapterID)
        unlockShift(shift)
        shiftInvestigationSeeds[shift]?.forEach { unlock($0, notify: false) }
        GameState.shared.save()
    }

    static func onShiftComplete(chapterID: String) {
        let shift = shiftNumber(from: chapterID)
        if let summaryID = shiftSummaries[shift] {
            unlock(summaryID, notify: false)
        }
        unlockShift(shift + 1)
        GameState.shared.save()
    }

    static func onCaseDecision(caseID: String, actionID: String) {
        guard let meta = caseCatalog[caseID] else { return }
        let decision = decisionLabel(for: actionID)
        let record = CaseJournalRecord(
            caseID: caseID,
            shift: meta.shift,
            title: meta.title,
            decision: decision,
            keyPoints: meta.keyPoints,
            tags: meta.tags)
        var s = state
        s.caseRecords[caseID] = record
        s.unlockedShifts.insert(meta.shift)
        s.pendingUpdateNotice = true
        state = s
        GameState.shared.save()
    }

    // MARK: - Content hooks (field + desk)

    static func onDeskDocumentOpened(documentID: String, caseID: String) {
        if caseID == "case_ch1_001", documentID == "doc_c01_a" {
            unlock("ch1_disc_victim_id")
            unlock("ch1_disc_code_format")
        }
    }

    static func onTerminalRead(terminalID: String) {
        switch terminalID {
        case "terminal_01":
            unlock("ch1_disc_code_format")
            unlock("ch1_disc_relay_buffer")
            unlock("ch1_inv_relay")
        case "terminal_02":
            unlock("ch1_disc_checkpoint")
            unlock("ch1_disc_relay_buffer")
        case "relay_console_01":
            unlock("ch1_disc_credential")
            unlock("ch1_disc_relay_buffer")
        case "terminal_maintenance":
            unlock("ch2_disc_jun_override")
        case "terminal_buffer":
            unlock("ch2_disc_evn_buffer")
        case "terminal_checkin":
            unlock("ch3_disc_evn_orphans")
        case "terminal_monitoring":
            unlock("ch3_disc_relocation")
        case "terminal_apt_main":
            unlock("ch3_disc_marr_unit")
        case "terminal_ghost_audit":
            unlock("ch4_disc_ghost_audit")
            unlock("ch4_inv_field")
        case "terminal_restricted_vault", "terminal_calyx_memo":
            unlock("ch4_disc_revision")
        case "terminal_legacy", "terminal_trial":
            unlock("ch5_disc_elias_stub")
            unlock("ch5_inv_field")
        case "terminal_deletion":
            unlock("ch5_disc_legacy")
        case "terminal_manifest", "terminal_trial_biometric":
            unlock("ch6_disc_manifest")
            unlock("ch6_disc_trial")
            unlock("ch6_inv_field")
        case "terminal_orra_fragment":
            unlock("ch6_disc_orra")
        case "terminal_census", "terminal_jun_relay":
            unlock("ch7_disc_jun")
            unlock("ch7_inv_field")
        case "terminal_petition":
            unlock("ch7_disc_petition")
        case "terminal_elias_packet":
            unlock("ch7_disc_elias_packet")
        case "terminal_archive_access", "terminal_deletion_census":
            unlock("ch8_disc_census")
        case "terminal_orra_complete":
            unlock("ch8_disc_vault")
        default:
            break
        }
    }

    static func onCredentialCollected() {
        unlock("ch1_disc_credential")
    }

    static func onHaasTalked() {
        unlock("ch1_disc_code_format")
        unlock("ch1_disc_haas")
    }

    static func onNPCTalked(npcID: String) {
        switch npcID {
        case "maint_worker_12":
            unlock("ch2_disc_maintenance")
            unlock("ch2_inv_field")
        case "resident_305":
            unlock("ch3_disc_relocation")
            unlock("ch3_disc_marr_unit")
            unlock("ch3_disc_resident_305")
        case "transit_worker_p06":
            unlock("ch6_disc_orra")
            unlock("ch6_inv_field")
        case "jun_vale_undercity":
            unlock("ch7_disc_jun")
            unlock("ch7_disc_elias_packet")
        default:
            break
        }
    }

    static func onCartridgeCollected(cartridgeID: String) {
        switch cartridgeID {
        case "cartridge_choir_list":
            unlock("ch2_disc_choir_list")
        case "cartridge_kell_orvin":
            unlock("ch3_disc_orvin_note")
        case "cartridge_calyx_predictive":
            unlock("ch4_disc_deleted")
        default:
            break
        }
    }

    static func onInformationNodeRead(nodeID: String) {
        switch nodeID {
        case "sign_orrra_mural":
            unlock("ch3_disc_orra_mural")
            GameState.shared.setFlag("orrra_mural_ch3")
        case "sign_eviction":
            unlock("ch3_disc_relocation")
        case "sign_ch1_hidden_choir":
            unlock("ch1_opt_hidden_choir")
        case "sign_ch2_hidden_jv":
            unlock("ch2_opt_hidden_jv")
        case "sign_ch5_hidden_trial":
            unlock("ch5_opt_hidden_trial")
        case "sign_ch6_hidden_jun":
            unlock("ch6_opt_jun_tag")
        case "sign_ch7_hidden_elias":
            unlock("ch7_opt_elias_tag")
        case "sign_ch8_hidden_orra":
            unlock("ch8_opt_orra_lamp")
        case "sign_ch3_c01_reloc", "sign_ch3_lina_warned", "sign_ch3_c01_denied":
            unlock("ch3_opt_c01_consequence")
        case "sign_ch4_abandoned":
            unlock("ch4_opt_abandoned_unit")
        default:
            break
        }
    }

    static func onCh2CredentialIssued() {
        unlock("ch2_disc_restricted")
    }

    static func onHackSuccess(puzzleID: String?) {
        guard let puzzleID else { return }
        switch puzzleID {
        case let id where id.hasPrefix("ch3"):
            unlock("ch3_disc_hack")
        case "ch4_archive_credential":
            unlock("ch4_disc_credential")
        case "ch5_camera_bypass":
            unlock("ch5_disc_camera")
        case "ch7_choir_pattern":
            unlock("ch7_disc_pattern")
        default:
            break
        }
    }

    static func checkCh3FieldCompletion() {
        let gs = GameState.shared
        if gs.hasFlag("ch3_apt_main_read") || gs.hasFlag("ch3_orvin_cartridge_collected") {
            gs.setFlag("ch3_field_complete")
            unlock("ch3_inv_field", notify: false)
            gs.save()
        }
    }

    // MARK: - Query API

    static func visibleShifts() -> [Int] {
        let s = state
        var shifts = Set(s.unlockedShifts)
        for id in s.unlockedEntryIDs {
            if let entry = catalog[id] { shifts.insert(entry.shift) }
        }
        for record in s.caseRecords.values { shifts.insert(record.shift) }
        return shifts.sorted()
    }

    static func entries(forShift shift: Int, section: JournalSection) -> [JournalEntryDef] {
        state.unlockedEntryIDs
            .compactMap { catalog[$0] }
            .filter { $0.shift == shift && $0.section == section }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    static func caseRecords(forShift shift: Int) -> [CaseJournalRecord] {
        state.caseRecords.values
            .filter { $0.shift == shift }
            .sorted { $0.title < $1.title }
    }

    static func hasContent(forShift shift: Int) -> Bool {
        !caseRecords(forShift: shift).isEmpty
            || JournalSection.allCases.contains { !entries(forShift: shift, section: $0).isEmpty }
    }

    /// Tags from unlocked journal entries and case records — used by credential injection puzzles.
    static func unlockedPDATags() -> Set<String> {
        var tags = Set<String>()
        for id in state.unlockedEntryIDs {
            if let entry = catalog[id] { tags.formUnion(entry.tags) }
        }
        for record in state.caseRecords.values { tags.formUnion(record.tags) }
        return tags
    }

    static func relatedEntries(matchingTag tag: String, excludingShift: Int? = nil) -> [(shift: Int, title: String)] {
        var results: [(Int, String)] = []
        for id in state.unlockedEntryIDs {
            guard let entry = catalog[id], entry.tags.contains(tag) else { continue }
            if let ex = excludingShift, entry.shift == ex { continue }
            let label = entry.title ?? entry.bullets.first ?? entry.id
            results.append((entry.shift, label))
        }
        for record in state.caseRecords.values where record.tags.contains(tag) {
            if let ex = excludingShift, record.shift == ex { continue }
            results.append((record.shift, record.title))
        }
        return results.sorted { $0.0 < $1.0 }
    }

    static func recordDeskPDAOpen(caseID: String) {
        var s = state
        s.deskCasePDAOpenCounts[caseID, default: 0] += 1
        state = s
        GameState.shared.save()
    }

    static func deskPDAOpenCount(caseID: String) -> Int {
        state.deskCasePDAOpenCounts[caseID] ?? 0
    }

    static func shiftNumber(from chapterID: String) -> Int {
        Int(chapterID.replacingOccurrences(of: "ch", with: "")) ?? 1
    }

    static func chapterID(forShift shift: Int) -> String {
        "ch\(shift)"
    }

    // MARK: - PDA section bodies (hub → Journal / Objectives / Discoveries)

    static func journalBody(forShift shift: Int, activeCaseID: String? = nil) -> String {
        var lines: [String] = ["SHIFT \(shift) — JOURNAL", ""]

        if let caseID = activeCaseID, let caseFile = CaseFile.load(id: caseID) {
            lines += currentInvestigationSection(caseFile: caseFile)
            lines.append("")
        }

        let records = caseRecords(forShift: shift)
        if records.isEmpty {
            lines.append("No case decisions recorded this shift yet.")
        } else {
            lines.append("CASE DECISIONS")
            lines.append("")
            for record in records {
                lines.append(record.title)
                lines.append("Decision: \(record.decision)")
                lines += PDAGuidanceResolver.cappedList(record.keyPoints)
                lines.append("")
            }
        }
        let summary = entries(forShift: shift, section: .summary)
        if !summary.isEmpty {
            lines.append("SHIFT NOTES")
            lines.append("")
            for entry in summary {
                if let title = entry.title { lines.append(title) }
                lines += PDAGuidanceResolver.cappedEvidenceBullets(entry.bullets)
                lines.append("")
            }
        }
        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func objectivesBody(
        forShift shift: Int,
        chapterID: String?,
        fieldObjective: String?,
        activeCaseID: String? = nil
    ) -> String {
        var lines: [String] = ["SHIFT \(shift) — OBJECTIVES", ""]

        if let caseID = activeCaseID, let caseFile = CaseFile.load(id: caseID) {
            lines += currentInvestigationSection(caseFile: caseFile)
            lines.append("")
        }

        if let chapterID,
           let chapter = ChapterData.load(id: chapterID) {
            lines.append(chapter.title.uppercased())
            if !chapter.subtitle.isEmpty {
                lines.append(chapter.subtitle)
            }
            lines.append("")
        }
        if let fieldObjective, !fieldObjective.isEmpty {
            lines.append("CURRENT TASK")
            lines.append(fieldObjective)
            lines.append("")
        }
        let leads = entries(forShift: shift, section: .investigation)
        if leads.isEmpty && fieldObjective == nil {
            lines.append("No active objectives logged yet.")
        } else if !leads.isEmpty {
            lines.append("INVESTIGATION LEADS")
            lines.append("")
            for entry in leads {
                if let title = entry.title { lines.append(title) }
                lines.append("CURRENT TASK")
                lines.append(PDAGuidanceResolver.currentTask(for: entry))
                lines.append("WHAT TO LOOK FOR")
                lines.append(PDAGuidanceResolver.lookFor(for: entry))
                lines.append("")
            }
        }
        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func currentInvestigationSection(caseFile: CaseFile) -> [String] {
        var lines = PDAGuidanceResolver.currentInvestigationLines(caseFile: caseFile)
        let openCount = deskPDAOpenCount(caseID: caseFile.id)
        if let hint = PDAGuidanceResolver.escalatingDeskHint(caseFile: caseFile, openCount: openCount) {
            lines.append("")
            lines.append("MARA'S THOUGHTS")
            lines.append(hint)
        }
        return lines
    }

    private static let evidenceSectionHeaders: Set<String> = [
        "KEY FACTS", "OPEN QUESTIONS",
        "LINKED PEOPLE", "LINKED LOCATIONS", "LINKED CASES",
    ]

    private static func appendLinkedSections(for entry: JournalEntryDef, to lines: inout [String]) {
        let people = InvestigationLinkResolver.people(for: entry.tags)
        let locations = InvestigationLinkResolver.locations(for: entry.tags)
        let cases = InvestigationLinkResolver.linkedCases(for: entry.tags)
        if !people.isEmpty {
            lines.append("LINKED PEOPLE")
            lines += PDAGuidanceResolver.cappedList(people)
        }
        if !locations.isEmpty {
            lines.append("LINKED LOCATIONS")
            lines += PDAGuidanceResolver.cappedList(locations)
        }
        if !cases.isEmpty {
            lines.append("LINKED CASES")
            lines += PDAGuidanceResolver.cappedList(cases)
        }
    }

    static func discoveriesBody(forShift shift: Int) -> String {
        let entries = entries(forShift: shift, section: .discoveries)
        if entries.isEmpty {
            return "SHIFT \(shift) — DISCOVERIES\n\nNo discoveries logged yet.\nInvestigate terminals, signs, and NPCs."
        }
        var lines = ["SHIFT \(shift) — EVIDENCE BOARD", ""]
        for entry in entries {
            if let title = entry.title { lines.append(title) }
            lines += formatDiscoveryEntry(entry.bullets)
            appendLinkedSections(for: entry, to: &lines)
            if let thought = PDAGuidanceResolver.maraThought(for: entry) {
                lines.append("MARA'S THOUGHTS")
                lines.append(thought)
            }
            lines.append("")
        }
        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func formatDiscoveryEntry(_ bullets: [String]) -> [String] {
        var lines: [String] = []
        var section = ""
        var sectionCount = 0
        var discoveryShown = false

        for bullet in bullets {
            if evidenceSectionHeaders.contains(bullet) || bullet == "KEY FACTS" || bullet == "OPEN QUESTIONS" {
                section = bullet
                sectionCount = 0
                if bullet != "KEY FACTS" { lines.append(bullet) }
                continue
            }
            if section == "KEY FACTS" || section.isEmpty {
                if !discoveryShown {
                    lines.append("DISCOVERY")
                    lines.append(bullet)
                    discoveryShown = true
                    sectionCount = 1
                    continue
                }
                if sectionCount == 1 { lines.append("KEY FACTS") }
                guard sectionCount < 5 else { continue }
                lines.append("• \(bullet)")
                sectionCount += 1
                continue
            }
            guard sectionCount < 5 else { continue }
            lines.append("• \(bullet)")
            sectionCount += 1
        }
        return lines
    }

    private static func decisionLabel(for actionID: String) -> String {
        switch actionID {
        case "approve": return "Approved"
        case "reject": return "Rejected"
        case "censor": return "Censored"
        case "archive": return "Archived"
        case "flag_anomaly": return "Flagged Anomaly"
        case "illegal_forward": return "Forwarded"
        case "broadcast": return "Broadcast"
        case "control": return "Control"
        case "erasure": return "Erasure"
        default:
            return actionID.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}
