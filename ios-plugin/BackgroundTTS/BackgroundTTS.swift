import Foundation
import Capacitor
import AVFoundation
import MediaPlayer

@objc(BackgroundTTS)
public class BackgroundTTS: CAPPlugin, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()

    override public func load() {
        print("[PAGES] BackgroundTTS loaded - background audio enabled")
        synthesizer.delegate = self
        setupAudio()
        setupRemote()
    }

    private func setupAudio() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers, .mixWithOthers])
            try session.setActive(true)
        } catch {
            print("[PAGES] Audio session error: \(error)")
        }
    }

    @objc func enableBackground(_ call: CAPPluginCall) {
        setupAudio()
        call.resolve(["enabled": true])
    }

    @objc func speak(_ call: CAPPluginCall) {
        guard let text = call.getString("text") else { call.reject("no text"); return }
        let rate = call.getFloat("rate") ?? 0.5
        setupAudio()
        synthesizer.stopSpeaking(at: .immediate)
        let utter = AVSpeechUtterance(string: text)
        utter.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        utter.rate = rate
        utter.volume = 1.0

        var info: [String: Any] = [:]
        info[MPMediaItemPropertyTitle] = String(text.prefix(60))
        info[MPMediaItemPropertyArtist] = "PAGES - 백그라운드 재생"
        info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info

        synthesizer.speak(utter)
        call.resolve()
    }

    @objc func pause(_ call: CAPPluginCall) {
        synthesizer.pauseSpeaking(at: .word)
        call.resolve()
    }

    @objc func resume(_ call: CAPPluginCall) {
        setupAudio()
        synthesizer.continueSpeaking()
        call.resolve()
    }

    @objc func stop(_ call: CAPPluginCall) {
        synthesizer.stopSpeaking(at: .immediate)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        call.resolve()
    }

    private func setupRemote() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.isEnabled = true
        center.pauseCommand.isEnabled = true
        center.playCommand.addTarget { [weak self] _ in
            self?.setupAudio()
            self?.synthesizer.continueSpeaking()
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            self?.synthesizer.pauseSpeaking(at: .word)
            return .success
        }
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        notifyListeners("ttsFinished", data: [:])
    }
}