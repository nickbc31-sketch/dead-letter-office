import Foundation

/// Expands a modular encounter sequence into flat level content for PlatformScene.
/// Chapter 1 is the reference A→B→C layout; later chapters reorder the same module types.
enum PlatformEncounterComposer {

    static func compose(_ level: LevelData, screenWidth: CGFloat) -> LevelData {
        guard let sequence = level.encounterSequence, !sequence.isEmpty else { return level }

        var patrols = level.patrols
        var platformNodes = level.platformNodes ?? []
        var interactables = level.interactables
        var npcs = level.npcs ?? []
        var environmentalTextNodes = level.environmentalTextNodes

        for slot in sequence {
            guard let kind = slot.kind else {
                print("[PlatformEncounterComposer] Unknown module: \(slot.module)")
                continue
            }
            switch kind {
            case .dronePatrol:
                if let patrol = slot.patrol { patrols.append(patrol) }

            case .gantryBypass:
                if let platform = slot.platform { platformNodes.append(platform) }

            case .buildingInvestigation:
                if let building = slot.building {
                    interactables.append(Interactable(
                        id: building.entranceID,
                        type: "building_entrance",
                        position: building.position,
                        requiredFlag: building.requiredFlag,
                        setsFlag: nil,
                        requiredCode: nil,
                        displayText: nil,
                        cartridgeData: nil,
                        linkedDialogueID: nil,
                        linkedLevelID: building.linkedLevelID,
                        buildingVisual: building.visual
                    ))
                    if let sign = building.signageText {
                        environmentalTextNodes.append([
                            "x": "\(building.position[0])",
                            "y": "90",
                            "text": sign
                        ])
                    }
                }

            case .terminalInvestigation:
                if let terminal = slot.terminal {
                    interactables.append(Interactable(
                        id: terminal.id,
                        type: "terminal",
                        position: terminal.position,
                        requiredFlag: terminal.requiredFlag,
                        setsFlag: terminal.setsFlag,
                        requiredCode: nil,
                        displayText: terminal.displayText,
                        cartridgeData: nil,
                        linkedDialogueID: terminal.linkedDialogueID,
                        linkedLevelID: nil,
                        buildingVisual: nil
                    ))
                }

            case .npcEncounter:
                if let npc = slot.npc { npcs.append(npc) }

            case .environmentalStory:
                if let env = slot.environmental {
                    if env.kind == "sign", let signID = env.signID {
                        interactables.append(Interactable(
                            id: signID,
                            type: "information_node",
                            position: [env.x, env.y],
                            requiredFlag: nil,
                            setsFlag: nil,
                            requiredCode: nil,
                            displayText: env.text,
                            cartridgeData: nil,
                            linkedDialogueID: nil,
                            linkedLevelID: nil,
                            buildingVisual: nil
                        ))
                    } else {
                        environmentalTextNodes.append([
                            "x": "\(env.x)",
                            "y": "\(env.y)",
                            "text": env.text
                        ])
                    }
                }
            }
        }

        var composed = level
        composed.patrols = patrols
        composed.platformNodes = platformNodes
        composed.interactables = interactables
        composed.npcs = npcs
        composed.environmentalTextNodes = environmentalTextNodes
        return composed
    }
}

extension LevelData {
    func composed(screenWidth: CGFloat) -> LevelData {
        PlatformEncounterComposer.compose(self, screenWidth: screenWidth)
    }
}
