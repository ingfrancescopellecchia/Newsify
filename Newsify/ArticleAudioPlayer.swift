//
//  ArticleAudioPlayer.swift
//  Newsify
//
//  Gestisce la lettura audio (text-to-speech) delle notizie.
//

import AVFoundation
import Combine
import SwiftUI

/// Manager condiviso che legge il testo di una notizia usando AVSpeechSynthesizer.
/// È pensato per essere usato da più card contemporaneamente: se si avvia la
/// lettura di un nuovo articolo mentre un altro sta già parlando, quello
/// precedente viene interrotto automaticamente.
final class ArticleAudioPlayer: NSObject, ObservableObject {

    /// Istanza condivisa: un'unica "voce" per tutta l'app.
    static let shared = ArticleAudioPlayer()

    /// True mentre il synthesizer sta effettivamente parlando.
    @Published private(set) var isSpeaking = false

    /// Identificatore dell'articolo attualmente in lettura (nil se nessuno).
    @Published private(set) var currentArticleID: String?

    private let synthesizer = AVSpeechSynthesizer()

    private override init() {
        super.init()
        synthesizer.delegate = self

        // Permette la riproduzione anche se il dispositivo è in modalità silenziosa,
        // ed eventualmente mentre l'app va in background durante l'ascolto.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    /// Restituisce true se l'articolo con quell'id è quello attualmente in lettura.
    func isPlaying(_ articleID: String) -> Bool {
        isSpeaking && currentArticleID == articleID
    }

    /// Avvia o ferma la lettura per un dato articolo.
    /// Se un altro articolo era in riproduzione, viene fermato prima di iniziare quello nuovo.
    func toggle(articleID: String, text: String) {
        if isPlaying(articleID) {
            stop()
            return
        }

        stop() // interrompe un'eventuale lettura precedente di un altro articolo
        play(articleID: articleID, text: text)
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        currentArticleID = nil
    }

    private func play(articleID: String, text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = Self.bestItalianVoice()
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0

        currentArticleID = articleID
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    /// Tra tutte le voci italiane installate sul dispositivo, sceglie quella di qualità
    /// migliore: Premium (la più naturale) > Enhanced > standard di sistema.
    /// Le voci Premium/Enhanced NON sono incluse di default: vanno scaricate da
    /// Impostazioni > Accessibilità > Contenuto vocale > Voci > Italiano.
    private static func bestItalianVoice() -> AVSpeechSynthesisVoice? {
        let italianVoices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language == "it-IT" }

        if let premium = italianVoices.first(where: { $0.quality == .premium }) {
            return premium
        }
        if let enhanced = italianVoices.first(where: { $0.quality == .enhanced }) {
            return enhanced
        }
        return AVSpeechSynthesisVoice(language: "it-IT")
    }
}

extension ArticleAudioPlayer: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Il delegate di AVSpeechSynthesizer non garantisce di essere chiamato sul main thread,
        // quindi aggiorniamo le @Published properties passando esplicitamente da DispatchQueue.main.
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
            self?.currentArticleID = nil
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
            self?.currentArticleID = nil
        }
    }
}
