import AVFoundation
import Foundation

/// Native iOS speech for PDA Field Notes — does not use bundled audio or affect music.
final class FieldNotesSpeechManager: NSObject {

    static let shared = FieldNotesSpeechManager()

    private let synthesizer = AVSpeechSynthesizer()
    private(set) var isSpeaking = false

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        stop()
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.88
        utterance.volume = speechVolume()
        utterance.voice = preferredVoice()

        synthesizer.speak(utterance)
        isSpeaking = true
    }

    func stop() {
        guard synthesizer.isSpeaking || synthesizer.isPaused else {
            isSpeaking = false
            return
        }
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }

    func toggleSpeech(text: String) {
        if isSpeaking { stop() } else { speak(text) }
    }

    private func speechVolume() -> Float {
        let sfx = GameState.shared.sfxVolume
        return max(0.15, min(1.0, sfx))
    }

    private func preferredVoice() -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        let gbVoices = voices.filter { $0.language.hasPrefix("en-GB") }

        let preferredNames = ["Kate", "Serena", "Martha", "Fiona", "Stephanie"]
        for name in preferredNames {
            if let match = gbVoices.first(where: { $0.name.localizedCaseInsensitiveContains(name) }) {
                return match
            }
        }

        if #available(iOS 13.0, *) {
            if let female = gbVoices.first(where: { $0.gender == .female }) {
                return female
            }
        }

        if let anyGB = gbVoices.first { return anyGB }
        return AVSpeechSynthesisVoice(language: "en-GB")
            ?? AVSpeechSynthesisVoice(language: "en-US")
    }
}

extension FieldNotesSpeechManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
}
