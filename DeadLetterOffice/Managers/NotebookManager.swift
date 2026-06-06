import Foundation
import SpriteKit

struct NotebookEntry: Codable, Identifiable {
    let id: String
    let title: String
    let body: String
    let chapter: String?
}

/// Lightweight case-notes notebook — auto-captured clues, not a full journal.
enum NotebookManager {

    private static let catalog: [String: NotebookEntry] = [
        // MARK: Chapter 1
        "ch1_victim_id": NotebookEntry(
            id: "ch1_victim_id",
            title: "CASE 1 — VICTIM ID",
            body: """
Citizen ID: VC-4471-M
Name: Marr, Olen (deceased)
Case 1 sender — desk death certificate.

The four middle digits are used for
inner checkpoint access codes.
""",
            chapter: "ch1"),
        "ch1_code_format": NotebookEntry(
            id: "ch1_code_format",
            title: "CHECKPOINT CODE FORMAT",
            body: """
Inner checkpoint codes rotate with
active case reference numbers.

Format: VC-[XXXX]-M
Enter the four digits (XXXX) only.

Consult desk Case 1 files if unsure.
""",
            chapter: "ch1"),
        "ch1_relay_buffer": NotebookEntry(
            id: "ch1_relay_buffer",
            title: "RELAY NODE 7 — BUFFER",
            body: """
Secondary routing tag: EVN-ROUTING-0442
Destination: Quiet Choir relay buffer

47 messages in transit buffer.
Scheduled deletion: 2147.03.19.

Routing anomaly flagged at Node 7.
""",
            chapter: "ch1"),
        "ch1_credential_note": NotebookEntry(
            id: "ch1_credential_note",
            title: "RELAY CREDENTIAL",
            body: """
Inner checkpoint requires maintenance
credential from Relay Node 7.

Locker: MNT-RELAY-07 (east wall)
Console login required before access.

Sign out before exterior transit.
""",
            chapter: "ch1"),
        "ch1_checkpoint_hint": NotebookEntry(
            id: "ch1_checkpoint_hint",
            title: "CHECKPOINT CODE HINT",
            body: """
Checkpoint code derived from Case 1
victim citizen ID (VC-4471-M).

Enter the four middle digits at the
inner checkpoint door keypad.

At checkpoint: use PDA override port
if credential is logged (CONNECT PDA).
""",
            chapter: "ch1"),

        // MARK: Chapter 2
        "ch2_jun_override": NotebookEntry(
            id: "ch2_jun_override",
            title: "MAINTENANCE OVERRIDE — J.V.",
            body: """
Sector 12 maintenance log — 2147.04.08
Authorisation: J.V.
Eastern corridor access granted.

Personnel file: NOT FOUND
Registry cross-check: FAILED

Someone in the maintenance layer
is using credentials without a record.
""",
            chapter: "ch2"),
        "ch2_maintenance_hint": NotebookEntry(
            id: "ch2_maintenance_hint",
            title: "SECTOR 12 — MAINTENANCE CONTACT",
            body: """
Worker badge failed east checkpoint.
Registry: ACTIVE. Roster: ABSENT.

Locker past tier-three signs holds
maintenance credential (MNT-SEC12-E4).

Restricted sector cartridge hidden
behind panel C-9 — do not read aloud.
""",
            chapter: "ch2"),
        "ch2_evn_buffer": NotebookEntry(
            id: "ch2_evn_buffer",
            title: "EAST TRANSIT — EVN BUFFER",
            body: """
PMCA relay buffer — East Transit Node
Unregistered senders in transit: 47
Scheduled deletion: 2147.04.15

Routing class: EVN
Orphan tags logged: 12
Origin infrastructure: UNLOGGED

Desk terminals cannot see this buffer.
""",
            chapter: "ch2"),
        "ch2_choir_list": NotebookEntry(
            id: "ch2_choir_list",
            title: "QUIET CHOIR MONITORING LIST",
            body: """
PMCA priority monitoring — civil status.
Compiled: unknown. Internal only.

MARR, L. — 29-VL-0034 — ACTIVE
SEN, G. — DECEASED (2147.04.11)
BRENT, A. — MINOR, GUARDIAN TRANSITION
DAIN, K. — ACTIVE MONITORING

Names from desk cases exist on a
street-level monitoring cartridge.
""",
            chapter: "ch2"),
        "ch2_restricted_access": NotebookEntry(
            id: "ch2_restricted_access",
            title: "RESTRICTED SECTOR CREDENTIAL",
            body: """
Maintenance credential: CH2-MAINT-SEC12
Locker: MNT-SEC12-E4

Opens restricted east transit sector.
PDA override port available at checkpoint
if camera sweep is active.

Sign out before exterior transit.
""",
            chapter: "ch2"),

        // MARK: Chapter 3
        "ch3_evn_orphans": NotebookEntry(
            id: "ch3_evn_orphans",
            title: "BLOCK P03 — EVN ORPHAN TAGS",
            body: """
Residential register — Block P03
EVN-ROUTING-0442 — no primary record
Status: ORPHANED — audit closed 2142

EVN-ROUTING-0447 — pending deletion
Same routing class as Elias desk tag.

Clerk terminals do not surface these.
""",
            chapter: "ch3"),
        "ch3_orra_mural": NotebookEntry(
            id: "ch3_orra_mural",
            title: "ORRA — COMMUNITY MURAL",
            body: """
Block A corridor mural:
'ORRA LIT THE LAMP
WHEN THE SQUARE WENT DARK'
— RESTORED 2138 —

PMCA notice: unauthorised symbolism.
Resistance predates current processing.
""",
            chapter: "ch3"),
        "ch3_relocation": NotebookEntry(
            id: "ch3_relocation",
            title: "BATCH RELOCATION — BLOCK A",
            body: """
Notice: Units 301-318 — Block A
Batch relocation order Q1 2147
Reference: PMCA-REL-0441
9 units cleared in single morning.

Families told relatives were already
processed before notifications sent.
""",
            chapter: "ch3"),
        "ch3_marr_unit": NotebookEntry(
            id: "ch3_marr_unit",
            title: "UNIT 312 — L. MARR",
            body: """
Unit 312 sealing inventory — Marr, L.
Death: 2147.03.18 — Case C09-0441-V
Appeal: in processing at desk

Undelivered letter to Review Bureau.
Relocation enforced posthumously.
Housing register knew before appeal.
""",
            chapter: "ch3"),
        "ch3_orvin_note": NotebookEntry(
            id: "ch3_orvin_note",
            title: "ORVIN — RECOVERED NOTE",
            body: """
Unit 204 — Orvin, K. — 38-SV-0091
Handwritten note recovered pre-incineration:

'I did not write the confession.
They gave me words — sign or the boy
loses his guardian. I signed.'

Harrel signed death and destruction
eighteen minutes apart.
""",
            chapter: "ch3"),
    ]

    static func entry(for id: String) -> NotebookEntry? { catalog[id] }

    static func unlock(_ id: String) {
        guard catalog[id] != nil else { return }
        GameState.shared.unlockNotebookEntry(id)
    }

    static func unlockedEntries(forChapter chapter: String? = nil) -> [NotebookEntry] {
        GameState.shared.notebookUnlockedIDs
            .compactMap { catalog[$0] }
            .filter { chapter == nil || $0.chapter == chapter }
            .sorted { $0.title < $1.title }
    }

    // MARK: - Auto-capture hooks

    static func onDeskDocumentOpened(documentID: String, caseID: String) {
        if caseID == "case_ch1_001", documentID == "doc_c01_a" {
            unlock("ch1_victim_id")
            unlock("ch1_code_format")
        }
    }

    static func onTerminalRead(terminalID: String) {
        switch terminalID {
        case "terminal_01":
            unlock("ch1_code_format")
            unlock("ch1_relay_buffer")
        case "terminal_02":
            unlock("ch1_checkpoint_hint")
            unlock("ch1_relay_buffer")
        case "relay_console_01":
            unlock("ch1_credential_note")
            unlock("ch1_relay_buffer")
        case "terminal_queue":
            break
        case "terminal_maintenance":
            unlock("ch2_jun_override")
        case "terminal_incineration":
            break
        case "terminal_buffer":
            unlock("ch2_evn_buffer")
        case "terminal_checkin":
            unlock("ch3_evn_orphans")
        case "terminal_monitoring":
            unlock("ch3_relocation")
        case "terminal_apt_main":
            unlock("ch3_marr_unit")
        default:
            break
        }
    }

    static func onCredentialCollected() {
        unlock("ch1_credential_note")
    }

    static func onHaasTalked() {
        unlock("ch1_code_format")
    }

    static func onNPCTalked(npcID: String) {
        switch npcID {
        case "maint_worker_12":
            unlock("ch2_maintenance_hint")
        case "resident_305":
            unlock("ch3_relocation")
            unlock("ch3_marr_unit")
        default:
            break
        }
    }

    static func onCartridgeCollected(cartridgeID: String) {
        switch cartridgeID {
        case "cartridge_choir_list":
            unlock("ch2_choir_list")
        case "cartridge_kell_orvin":
            unlock("ch3_orvin_note")
        default:
            break
        }
    }

    static func onInformationNodeRead(nodeID: String) {
        switch nodeID {
        case "sign_orrra_mural":
            unlock("ch3_orra_mural")
            GameState.shared.setFlag("orrra_mural_ch3")
        case "sign_eviction":
            unlock("ch3_relocation")
        default:
            break
        }
    }

    static func checkCh3FieldCompletion() {
        let gs = GameState.shared
        if gs.hasFlag("ch3_apt_main_read") || gs.hasFlag("ch3_orvin_cartridge_collected") {
            gs.setFlag("ch3_field_complete")
            gs.save()
        }
    }

    static func onCh2CredentialIssued() {
        unlock("ch2_restricted_access")
    }

    // MARK: - PDA overlay UI

    private static func notesBody(forChapter chapter: String?) -> String {
        let entries = unlockedEntries(forChapter: chapter)
        if entries.isEmpty {
            return """
No field notes recorded yet.

Read terminals, desk documents, and
reports to capture clues automatically.
"""
        }
        return entries.map { "— \($0.title) —\n\($0.body)" }.joined(separator: "\n\n")
    }

    static func makePDAPanel(cam: SceneLayout.CameraLayout,
                             chapter: String?,
                             onClose: @escaping () -> Void)
        -> (panel: SKNode, scrollState: ScrollableReadablePanel.ScrollState) {
        let entries = unlockedEntries(forChapter: chapter)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        let meta = ScrollableReadablePanel.PDAMetadata(
            deviceID: "MARA-UNIT-7",
            caseRef: chapter.map { $0.uppercased() } ?? "FIELD",
            noteCount: entries.count,
            syncStatus: "LOCAL ONLY",
            timestamp: formatter.string(from: Date())
        )
        let panelSize = CGSize(width: cam.w * 0.76, height: cam.h * 0.82)
        return ScrollableReadablePanel.build(
            style: .pda,
            header: "MARA PDA — CASE NOTES",
            body: notesBody(forChapter: chapter),
            panelSize: panelSize,
            textMultiplier: GameState.shared.textSizeMultiplier,
            primaryButton: .init(label: "[ CLOSE ]", action: onClose),
            pdaMetadata: meta
        )
    }

    static func makeDeskPDAPanel(layout: SceneLayout, chapter: String?,
                                 onClose: @escaping () -> Void)
        -> (panel: SKNode, scrollState: ScrollableReadablePanel.ScrollState) {
        let built = makePDAPanel(
            cam: SceneLayout.CameraLayout(
                left: -layout.w / 2, right: layout.w / 2,
                top: layout.h / 2, bottom: -layout.h / 2),
            chapter: chapter,
            onClose: onClose)
        built.panel.position = layout.center
        return built
    }
}
