import Foundation

/// Registry of data-driven PDA hack puzzles used across Chapters 1–8.
final class HackingSystem {
    static let shared = HackingSystem()
    private init() { registerDefaults() }

    private var catalog: [String: HackPuzzleConfig] = [:]

    func register(_ config: HackPuzzleConfig) { catalog[config.id] = config }

    func config(for id: String) -> HackPuzzleConfig? { catalog[id] }

    func configForInteractable(_ id: String) -> HackPuzzleConfig? {
        catalog.values.first { $0.targetInteractableID == id }
    }

    /// Sample configs for debug test harness (-DLOTestHackPuzzles).
    static func sampleConfig(type: HackPuzzleType, difficulty: HackDifficulty) -> HackPuzzleConfig {
        let id = "debug_\(type.rawValue)_\(difficulty.rawValue)"
        switch type {
        case .signalRouting:
            let grid: SignalRoutingConfig
            switch difficulty {
            case .easy:
                grid = SignalRoutingConfig(rows: 3, columns: 3, startIndex: 0, exitIndex: 8,
                                           blockedIndices: [2, 5], unstableIndices: [], allowedPath: [0, 3, 4, 7, 8])
            case .medium:
                grid = SignalRoutingConfig(rows: 4, columns: 4, startIndex: 0, exitIndex: 15,
                                           blockedIndices: [2, 5, 9, 10], unstableIndices: [6], allowedPath: nil)
            case .hard:
                grid = SignalRoutingConfig(rows: 5, columns: 4, startIndex: 0, exitIndex: 19,
                                           blockedIndices: [1, 3, 7, 11, 14], unstableIndices: [6, 12], allowedPath: nil)
            }
            return HackPuzzleConfig(id: id, puzzleType: .signalRouting, difficulty: difficulty,
                                    title: "DEBUG SIGNAL ROUTE", subtitle: "Route START → EXIT",
                                    signalRouting: grid)
        case .frequencyMatch:
            let freq: FrequencyMatchConfig
            switch difficulty {
            case .easy:
                freq = FrequencyMatchConfig(bandCount: 2, targetValues: [0.4, 0.65],
                                          tolerances: [0.18, 0.18], jitterAmount: 0, autoSuccess: true)
            case .medium:
                freq = FrequencyMatchConfig(bandCount: 3, targetValues: [0.35, 0.62, 0.48],
                                          tolerances: [0.12, 0.12, 0.12], jitterAmount: 0, autoSuccess: true)
            case .hard:
                freq = FrequencyMatchConfig(bandCount: 3, targetValues: [0.28, 0.55, 0.72],
                                          tolerances: [0.06, 0.06, 0.06], jitterAmount: 0.03, autoSuccess: true)
            }
            return HackPuzzleConfig(id: id, puzzleType: .frequencyMatch, difficulty: difficulty,
                                    title: "DEBUG FREQUENCY MATCH", subtitle: "Align all bands",
                                    frequencyMatch: freq)
        case .credentialInjection:
            let cred: CredentialInjectionConfig
            switch difficulty {
            case .easy:
                cred = CredentialInjectionConfig(
                    systemRequest: "ACCESS REQUEST:\nPMCA TEST NODE\nFIELD: ???",
                    requiredFragments: ["UNIT 312", "MARR"],
                    availableFragments: ["UNIT 312", "MARR", "4471", "ORVIN"],
                    distractorFragments: ["HELIX ROUTE"],
                    requiredPDATags: ["marr_unit_312"], allowPartialHints: true)
            case .medium:
                cred = CredentialInjectionConfig(
                    systemRequest: "ACCESS REQUEST:\nPMCA RESIDENTIAL SEAL\nUNIT: ???\nCASE LINK: ???",
                    requiredFragments: ["UNIT 312", "MARR", "SEAL ORDER"],
                    availableFragments: ["UNIT 312", "MARR", "SEAL ORDER", "4471", "ORVIN", "TRANSIT LINE 9"],
                    distractorFragments: ["HELIX ROUTE", "QUIET CHOIR", "BLOCK P03"],
                    requiredPDATags: ["marr_unit_312"], allowPartialHints: true)
            case .hard:
                cred = CredentialInjectionConfig(
                    systemRequest: "ACCESS REQUEST:\nARCHIVE RELAY LOCK\nTAG: ???\nAUTH: ???\nROUTE: ???",
                    requiredFragments: ["EVN-0442", "RELAY", "ARCHIVE", "MAINT"],
                    availableFragments: ["EVN-0442", "RELAY", "ARCHIVE", "MAINT", "4471", "ORVIN", "PMCA"],
                    distractorFragments: ["HELIX ROUTE", "QUIET CHOIR", "INCINERATE", "TIER 3"],
                    requiredPDATags: ["elias_venn", "helix_routing"], allowPartialHints: true)
            }
            return HackPuzzleConfig(id: id, puzzleType: .credentialInjection, difficulty: difficulty,
                                    title: "DEBUG CREDENTIAL INJECT", subtitle: "Assemble verified fragments",
                                    credentialInjection: cred)
        case .patternDecode:
            let pat: PatternDecodeConfig
            switch difficulty {
            case .easy:
                pat = PatternDecodeConfig(symbols: ["○", "△", "□", "—", "◆", "◎"],
                                          sequence: [0, 2, 4], replayLimit: 99, showDurationPerSymbol: 0.55)
            case .medium:
                pat = PatternDecodeConfig(symbols: ["○", "△", "□", "—", "◆", "◎"],
                                          sequence: [1, 3, 0, 5], replayLimit: 2, showDurationPerSymbol: 0.45)
            case .hard:
                pat = PatternDecodeConfig(symbols: ["○", "△", "□", "—", "◆", "◎"],
                                          sequence: [2, 5, 1, 4, 0], replayLimit: 1, showDurationPerSymbol: 0.4)
            }
            return HackPuzzleConfig(id: id, puzzleType: .patternDecode, difficulty: difficulty,
                                    title: "DEBUG PATTERN DECODE", subtitle: "Reproduce the symbol chain",
                                    patternDecode: pat)
        }
    }

    private func registerDefaults() {
        register(HackPuzzleConfig(
            id: "ch1_checkpoint_bypass",
            puzzleType: .signalRouting,
            difficulty: .easy,
            title: "CHECKPOINT ARCHIVE BYPASS",
            subtitle: "Route maintenance signal through Node 7 buffer",
            successMessage: "PDA — ACCESS SIGNAL ROUTED",
            failureMessage: "PDA — ROUTE REJECTED",
            targetInteractableID: "checkpoint_security_override",
            requiredFlag: "ch1_relay_credential",
            setsFlagOnSuccess: "ch1_checkpoint_override_used",
            maxAttempts: nil,
            signalRouting: SignalRoutingConfig(
                rows: 3, columns: 3,
                startIndex: 0, exitIndex: 8,
                blockedIndices: [2, 5],
                unstableIndices: [],
                allowedPath: [0, 1, 4, 7, 8]
            )
        ))

        register(HackPuzzleConfig(
            id: "ch2_restricted_bypass",
            puzzleType: .frequencyMatch,
            difficulty: .medium,
            title: "RESTRICTED SECTOR — CAMERA LOOP",
            subtitle: "Match surveillance sweep frequency to bypass checkpoint",
            successMessage: "PDA — SURVEILLANCE LOOP SYNCHRONISED",
            failureMessage: "PDA — FREQUENCY MISMATCH",
            targetInteractableID: "ch2_restricted_override",
            requiredFlag: "ch2_maintenance_credential",
            setsFlagOnSuccess: "ch2_restricted_override_used",
            frequencyMatch: FrequencyMatchConfig(
                bandCount: 3,
                targetValues: [0.32, 0.58, 0.44],
                tolerances: [0.11, 0.11, 0.11],
                jitterAmount: 0,
                autoSuccess: true
            )
        ))

        register(HackPuzzleConfig(
            id: "ch3_marr_seal_bypass",
            puzzleType: .credentialInjection,
            difficulty: .medium,
            title: "RESIDENTIAL SEAL OVERRIDE",
            subtitle: "Inject verified credential fragments into PMCA seal gate",
            successMessage: "PDA — SEAL CREDENTIAL ACCEPTED",
            failureMessage: "PDA — CREDENTIAL REJECTED",
            requiredPDATags: ["marr_unit_312"],
            targetInteractableID: "override_marr_apt",
            requiredFlag: "c09_processed",
            setsFlagOnSuccess: "ch3_override_used",
            credentialInjection: CredentialInjectionConfig(
                systemRequest: """
ACCESS REQUEST:
PMCA RESIDENTIAL SEAL
UNIT: ???
CASE LINK: ???
AUTHORITY: ???
""",
                requiredFragments: ["UNIT 312", "MARR", "SEAL ORDER"],
                availableFragments: ["UNIT 312", "MARR", "SEAL ORDER", "4471", "ORVIN", "TRANSIT LINE 9"],
                distractorFragments: ["HELIX ROUTE", "QUIET CHOIR", "BLOCK P03", "ORRA"],
                requiredPDATags: ["marr_unit_312"],
                allowPartialHints: true
            )
        ))

        register(HackPuzzleConfig(
            id: "ch4_archive_credential",
            puzzleType: .credentialInjection,
            difficulty: .medium,
            title: "ARCHIVE VAULT CREDENTIAL",
            subtitle: "Inject verified P04 archive access fragments",
            successMessage: "PDA — ARCHIVE CREDENTIAL ACCEPTED",
            failureMessage: "PDA — CREDENTIAL REJECTED",
            targetInteractableID: "ch4_archive_override",
            requiredFlag: "c14_processed",
            setsFlagOnSuccess: "ch4_archive_override_used",
            credentialInjection: CredentialInjectionConfig(
                systemRequest: """
ACCESS REQUEST:
PMCA ARCHIVE VAULT P04
CLERK: ???
CASE: ???
AUTHORITY: ???
""",
                requiredFragments: ["1147-F", "GHOST AUDIT", "P04 VAULT"],
                availableFragments: ["1147-F", "GHOST AUDIT", "P04 VAULT", "0442-M", "C14 MEMO", "CALYX"],
                distractorFragments: ["TIER 3", "HELIX ROUTE", "QUIET CHOIR"],
                requiredPDATags: ["elias_venn"],
                allowPartialHints: true
            )
        ))

        register(HackPuzzleConfig(
            id: "ch5_camera_bypass",
            puzzleType: .frequencyMatch,
            difficulty: .medium,
            title: "HELIX CAMERA BYPASS",
            subtitle: "Match corporate surveillance sweep frequency",
            successMessage: "PDA — SURVEILLANCE LOOP SYNCHRONISED",
            failureMessage: "PDA — FREQUENCY MISMATCH",
            targetInteractableID: "ch5_camera_override",
            requiredFlag: "ch5_deletion_read",
            setsFlagOnSuccess: "ch5_camera_bypass_used",
            frequencyMatch: FrequencyMatchConfig(
                bandCount: 3,
                targetValues: [0.28, 0.54, 0.41],
                tolerances: [0.10, 0.10, 0.10],
                jitterAmount: 0.02,
                autoSuccess: true
            )
        ))

        register(HackPuzzleConfig(
            id: "ch6_transit_frequency",
            puzzleType: .frequencyMatch,
            difficulty: .hard,
            title: "TRANSIT CONTROL FREQUENCY",
            subtitle: "Align train control bands for Route 7-B access",
            successMessage: "PDA — TRANSIT FREQUENCY LOCKED",
            failureMessage: "PDA — CONTROL SIGNAL REJECTED",
            targetInteractableID: "ch6_frequency_override",
            requiredFlag: "ch6_manifest_read",
            setsFlagOnSuccess: "ch6_frequency_bypass_used",
            frequencyMatch: FrequencyMatchConfig(
                bandCount: 3,
                targetValues: [0.31, 0.57, 0.46],
                tolerances: [0.08, 0.08, 0.08],
                jitterAmount: 0.03,
                autoSuccess: true
            )
        ))

        register(HackPuzzleConfig(
            id: "ch7_choir_pattern",
            puzzleType: .patternDecode,
            difficulty: .medium,
            title: "CHOIR RELAY PATTERN",
            subtitle: "Decode encrypted undercity access sequence",
            successMessage: "PDA — RELAY PATTERN ACCEPTED",
            failureMessage: "PDA — PATTERN MISMATCH",
            targetInteractableID: "ch7_choir_override",
            requiredFlag: "ch7_census_read",
            setsFlagOnSuccess: "ch7_pattern_bypass_used",
            patternDecode: PatternDecodeConfig(
                symbols: ["○", "△", "□", "—", "◆", "◎"],
                sequence: [1, 4, 0, 5],
                replayLimit: 2,
                showDurationPerSymbol: 0.45
            )
        ))

        register(HackPuzzleConfig(
            id: "ch8_archive_signal",
            puzzleType: .signalRouting,
            difficulty: .medium,
            title: "CENTRAL ARCHIVE SIGNAL ROUTE",
            subtitle: "Route access signal through Node 12-A buffer",
            successMessage: "PDA — ARCHIVE SIGNAL ROUTED",
            failureMessage: "PDA — ROUTE REJECTED",
            targetInteractableID: "ch8_signal_override",
            requiredFlag: "ch8_access_read",
            setsFlagOnSuccess: "ch8_signal_bypass_used",
            signalRouting: SignalRoutingConfig(
                rows: 4, columns: 4,
                startIndex: 0, exitIndex: 15,
                blockedIndices: [2, 5, 9, 10],
                unstableIndices: [6],
                allowedPath: nil
            )
        ))

        register(HackPuzzleConfig(
            id: "ch8_archive_credential",
            puzzleType: .credentialInjection,
            difficulty: .hard,
            title: "ORRA VAULT CREDENTIAL",
            subtitle: "Inject Saint Orra seal fragments for Vault 1",
            successMessage: "PDA — VAULT CREDENTIAL ACCEPTED",
            failureMessage: "PDA — SEAL REJECTED",
            targetInteractableID: "ch8_credential_override",
            requiredFlag: "ch8_signal_bypass_used",
            setsFlagOnSuccess: "ch8_credential_bypass_used",
            credentialInjection: CredentialInjectionConfig(
                systemRequest: """
ACCESS REQUEST:
PMCA CENTRAL ARCHIVE VAULT 1
SEAL: ???
CENSUS: ???
BROADCAST: ???
""",
                requiredFragments: ["ORRA-SEAL", "CENSUS", "2130"],
                availableFragments: ["ORRA-SEAL", "CENSUS", "2130", "0442-M", "1147-F", "BROADCAST", "VAULT 1"],
                distractorFragments: ["TIER 3", "INCINERATE", "CALYX CHAIR"],
                requiredPDATags: ["saint_orra"],
                allowPartialHints: true
            )
        ))
    }
}
