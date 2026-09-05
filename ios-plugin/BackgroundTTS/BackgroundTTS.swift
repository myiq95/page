import Foundation
import Capacitor
import AVFoundation
import MediaPlayer

@objc(BackgroundTTS)
public class BackgroundTTS: CAPPlugin, AVSpeechSynthesizerDelegate {
    private let synth = AVSpeechSynthesizer()
    override public func load() {
        synth.delegate = self
        setup()
    }
    private func setup() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers, .mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {}
        let c = MPRemoteCommandCenter.shared()
        c.playCommand.isEnabled = true
        c.pauseCommand.isEnabled = true
        c.playCommand.addTarget { [weak self] _ in self?.setup(); self?.synth.continueSpeaking(); return .success }
        c.pauseCommand.addTarget { [weak self] _ in self?.synth.pauseSpeaking(at: .word); return .success }
    }
    @objc func enableBackground(_ call: CAPPluginCall) { setup(); call.resolve() }
    @objc func speak(_ call: CAPPluginCall) {
        guard let t = call.getString("text") else { call.reject("no text"); return }
        let r = call.getFloat("rate") ?? 0.9
        setup()
        synth.stopSpeaking(at: .immediate)
        let u = AVSpeechUtterance(string: t)
        u.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        u.rate = r
        u.volume = 1.0
        var info: [String: Any] = [:]
        info[MPMediaItemPropertyTitle] = String(t.prefix(60))
        info[MPMediaItemPropertyArtist] = "PAGES"
        info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        synth.speak(u)
        call.resolve()
    }
    @objc func pause(_ call: CAPPluginCall) { synth.pauseSpeaking(at: .word); call.resolve() }
    @objc func resume(_ call: CAPPluginCall) { setup(); synth.continueSpeaking(); call.resolve() }
    @objc func stop(_ call: CAPPluginCall) { synth.stopSpeaking(at: .immediate); MPNowPlayingInfoCenter.default().nowPlayingInfo=nil; call.resolve() }
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        notifyListeners("ttsFinished", data: [:])
    }
}