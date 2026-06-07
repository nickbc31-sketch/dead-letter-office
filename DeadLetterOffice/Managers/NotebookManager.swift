import Foundation
import SpriteKit

/// Legacy notebook entry type — retained for save migration compatibility.
struct NotebookEntry: Codable, Identifiable {
    let id: String
    let title: String
    let body: String
    let chapter: String?
}

/// Forwards to PDAJournalManager. Retained so existing call sites compile unchanged.
enum NotebookManager {

    static func unlock(_ id: String) {
        GameState.shared.unlockNotebookEntry(id)
    }

    static func unlockedEntries(forChapter chapter: String? = nil) -> [NotebookEntry] {
        let shift = chapter.flatMap { PDAJournalManager.shiftNumber(from: $0) }
        var result: [NotebookEntry] = []
        if let shift {
            for section in JournalSection.allCases {
                for entry in PDAJournalManager.entries(forShift: shift, section: section) {
                    result.append(NotebookEntry(
                        id: entry.id,
                        title: entry.title ?? section.rawValue,
                        body: entry.bullets.joined(separator: "\n"),
                        chapter: chapter))
                }
            }
        }
        return result.sorted { $0.title < $1.title }
    }

    static func onDeskDocumentOpened(documentID: String, caseID: String) {
        PDAJournalManager.onDeskDocumentOpened(documentID: documentID, caseID: caseID)
    }

    static func onTerminalRead(terminalID: String) {
        PDAJournalManager.onTerminalRead(terminalID: terminalID)
    }

    static func onCredentialCollected() {
        PDAJournalManager.onCredentialCollected()
    }

    static func onHaasTalked() {
        PDAJournalManager.onHaasTalked()
    }

    static func onNPCTalked(npcID: String) {
        PDAJournalManager.onNPCTalked(npcID: npcID)
    }

    static func onCartridgeCollected(cartridgeID: String) {
        PDAJournalManager.onCartridgeCollected(cartridgeID: cartridgeID)
    }

    static func onInformationNodeRead(nodeID: String) {
        PDAJournalManager.onInformationNodeRead(nodeID: nodeID)
    }

    static func checkCh3FieldCompletion() {
        PDAJournalManager.checkCh3FieldCompletion()
    }

    static func onCh2CredentialIssued() {
        PDAJournalManager.onCh2CredentialIssued()
    }
}
