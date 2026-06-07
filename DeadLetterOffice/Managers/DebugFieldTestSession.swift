#if DEBUG
import Foundation
import SpriteKit

/// Isolated debug field QA — snapshots player save, seeds temporary flags, restores on exit.
enum DebugFieldTestSession {

    private static var snapshot: SaveData?
    private static var snapshotTaken = false

    static var isActive: Bool {
        GameState.shared.isDebugFieldTestSession
    }

    static func beginIfNeeded() {
        guard !snapshotTaken else { return }
        snapshot = SaveManager.shared.snapshot(from: GameState.shared)
        snapshotTaken = true
        GameState.shared.isDebugFieldTestSession = true
    }

    static func prepareShift(_ shift: Int) {
        guard (1...8).contains(shift) else { return }
        beginIfNeeded()
        seedForShift(shift)
    }

    static func restoreSnapshotOnly() {
        restoreSnapshot()
    }

    static func launchShift(_ shift: Int, from scene: SKScene) {
        guard (1...8).contains(shift) else { return }
        prepareShift(shift)
        let levelID = "level_ch\(shift)"
        guard LevelData.load(id: levelID) != nil else {
            NSLog("[DLO DebugField] missing level: %@", levelID)
            return
        }
        NSLog("[DLO DebugField] launching %@ (shift %d)", levelID, shift)
        SceneManager.shared.transition(to: .platform(levelID: levelID), from: scene)
    }

    static func returnToPicker(from scene: SKScene) {
        restoreSnapshot()
        SceneManager.shared.transition(to: .debugFieldTest, from: scene)
    }

    static func endAndReturnToMainMenu(from scene: SKScene) {
        restoreSnapshot()
        SceneManager.shared.transition(to: .mainMenu, from: scene)
    }

    private static func restoreSnapshot() {
        if let snap = snapshot {
            SaveManager.shared.apply(snap, to: GameState.shared)
        }
        snapshot = nil
        snapshotTaken = false
        GameState.shared.isDebugFieldTestSession = false
    }

    private static func seedForShift(_ shift: Int) {
        let gs = GameState.shared
        let ch = "ch\(shift)"
        gs.currentChapterID = ch

        for n in 1...shift {
            let prefix = "ch\(n)"
            gs.setFlag("\(prefix)_unlocked")
            gs.setFlag("\(prefix)_intro_complete")
            gs.setFlag("\(prefix)_desk_complete")
            gs.setFlag("\(prefix)_outro_complete")
        }

        PDAJournalManager.onShiftStart(chapterID: ch)

        let flags = fieldFlags(for: shift)
        flags.forEach { gs.setFlag($0) }

        // Prior-shift carry flags commonly referenced across chapters.
        if shift >= 2 {
            gs.setFlag("ch1_platform_complete")
            gs.setFlag("ch1_relay_credential")
            gs.setFlag("relay_console_read")
            gs.setFlag("ch1_checkpoint_unlocked")
        }
        if shift >= 3 {
            gs.setFlag("c01_approved")
            gs.setFlag("c01_rejected")
            gs.setFlag("lina_warned")
            gs.setFlag("c09_processed")
            gs.setFlag("c09_approved")
            gs.setFlag("marr_apt_accessed")
        }
        if shift >= 4 {
            gs.setFlag("c13_processed")
            gs.setFlag("c14_processed")
            gs.setFlag("c02_rejected")
        }

        NSLog("[DLO DebugField] seeded shift %d — %d flags", shift, gs.activeFlags.count)
    }

    private static func fieldFlags(for shift: Int) -> [String] {
        switch shift {
        case 1:
            return [
                "ch1_relay_credential",
                "ch1_checkpoint_unlocked",
                "relay_console_read",
                "ch1_tutorial_shown",
            ]
        case 2:
            return [
                "ch2_maintenance_credential",
                "c08_cartridge_collected",
                "c08_processed",
                "jun_vale_hint",
                "ch2_elias_flag_reminder",
            ]
        case 3:
            return [
                "c09_processed",
                "c09_approved",
                "c09_rejected",
                "c09_flagged",
                "ch3_override_used",
                "ch3_apt_main_read",
                "orrra_mural_ch3",
            ]
        case 4:
            return [
                "ch4_archive_override_used",
                "ch4_field_complete",
            ]
        case 5:
            return [
                "c15_processed",
                "c16_processed",
                "c17_processed",
                "ch5_camera_bypass_used",
                "ch5_deletion_read",
            ]
        case 6:
            return [
                "c18_processed",
                "c19_processed",
                "ch6_frequency_bypass_used",
                "ch6_manifest_read",
            ]
        case 7:
            return [
                "c21_processed",
                "c22_processed",
                "c23_processed",
                "ch7_pattern_bypass_used",
                "ch7_census_read",
            ]
        case 8:
            return [
                "ch8_signal_bypass_used",
                "ch8_credential_bypass_used",
                "ch8_access_read",
                "c24_processed",
            ]
        default:
            return []
        }
    }
}
#endif
