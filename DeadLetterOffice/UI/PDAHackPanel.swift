import SpriteKit

/// Reusable PDA hack puzzle container — routes to type-specific views.
enum PDAHackPanel {

    static func present(
        config: HackPuzzleConfig,
        panelSize: CGSize,
        textMultiplier: CGFloat,
        unlockedPDATags: Set<String>,
        onResult: @escaping (HackPuzzleResult) -> Void
    ) -> SKNode {
        let mult = max(0.85, min(1.35, textMultiplier))

        let onSuccess = { onResult(.success) }
        let onCancel = { onResult(.cancelled) }
        let onFail = { (reason: String) in onResult(.failed(reason: reason)) }

        switch config.puzzleType {
        case .signalRouting:
            guard let payload = config.signalRouting else {
                onResult(.failed(reason: "Missing signal routing config"))
                return SKNode()
            }
            return SignalRoutingPuzzleView.build(
                config: payload, panelSize: panelSize, mult: mult,
                onSuccess: onSuccess, onCancel: onCancel)

        case .frequencyMatch:
            guard let payload = config.frequencyMatch else {
                onResult(.failed(reason: "Missing frequency match config"))
                return SKNode()
            }
            return FrequencyMatchPuzzleView.build(
                config: payload, panelSize: panelSize, mult: mult,
                onSuccess: onSuccess, onCancel: onCancel, onFail: onFail)

        case .credentialInjection:
            guard let payload = config.credentialInjection else {
                onResult(.failed(reason: "Missing credential injection config"))
                return SKNode()
            }
            return CredentialInjectionPuzzleView.build(
                config: payload, panelSize: panelSize, mult: mult,
                unlockedTags: unlockedPDATags,
                onSuccess: onSuccess, onCancel: onCancel, onFail: onFail)

        case .patternDecode:
            guard let payload = config.patternDecode else {
                onResult(.failed(reason: "Missing pattern decode config"))
                return SKNode()
            }
            return PatternDecodePuzzleView.build(
                config: payload, panelSize: panelSize, mult: mult,
                onSuccess: onSuccess, onCancel: onCancel)
        }
    }
}
