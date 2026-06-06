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

Override terminal available if you
hold a valid relay credential.
""",
            chapter: "ch1"),
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

    // MARK: - Chapter 1 auto-capture hooks

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

    // MARK: - Shared overlay UI

    static func makeOverlayNode(cam: SceneLayout.CameraLayout, chapter: String?) -> SKNode {
        let mult = GameState.shared.textSizeMultiplier
        let panel = SKNode()
        panel.zPosition = 2600

        let panelW = cam.w * 0.78
        let panelH = cam.h * 0.82

        let bg = SKSpriteNode(color: DLOColor.terminalBG,
                              size: CGSize(width: panelW, height: panelH))
        bg.alpha = 0.97
        panel.addChild(bg)

        let border = SKShapeNode(rectOf: CGSize(width: panelW - 2, height: panelH - 2),
                                 cornerRadius: 4)
        border.strokeColor = DLOColor.teal
        border.lineWidth = 1.5
        border.fillColor = .clear
        panel.addChild(border)

        let hdr = DLOFont.titleLabel(text: "MARA — CASE NOTES", size: 14 * mult)
        hdr.horizontalAlignmentMode = .center
        hdr.position = CGPoint(x: 0, y: panelH / 2 - 26)
        panel.addChild(hdr)

        let entries = unlockedEntries(forChapter: chapter)
        let bodyText: String
        if entries.isEmpty {
            bodyText = "No notes recorded yet.\n\nRead terminals, desk documents,\nand field reports to capture clues."
        } else {
            bodyText = entries.map { entry in
                "— \(entry.title) —\n\(entry.body)"
            }.joined(separator: "\n\n")
        }

        let bodyLbl = SKLabelNode(text: bodyText)
        bodyLbl.fontName = "Menlo"
        bodyLbl.fontSize = 10 * mult
        bodyLbl.fontColor = DLOColor.terminalAmber.withAlphaComponent(0.92)
        bodyLbl.horizontalAlignmentMode = .left
        bodyLbl.verticalAlignmentMode = .top
        bodyLbl.numberOfLines = 0
        bodyLbl.preferredMaxLayoutWidth = panelW - 36
        bodyLbl.position = CGPoint(x: -panelW / 2 + 18, y: panelH / 2 - 48)
        panel.addChild(bodyLbl)

        panel.userData = NSMutableDictionary()
        panel.userData?["panelH"] = Double(panelH)
        return panel
    }

    /// Desk scene variant — panel positioned at scene centre by caller.
    static func makeDeskOverlayNode(layout: SceneLayout, chapter: String?) -> SKNode {
        let panel = makeOverlayNode(
            cam: SceneLayout.CameraLayout(
                left: -layout.w / 2, right: layout.w / 2,
                top: layout.h / 2, bottom: -layout.h / 2),
            chapter: chapter)
        panel.position = layout.center
        return panel
    }
}
