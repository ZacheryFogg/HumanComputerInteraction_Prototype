//
//  SpeechService.swift
//  HCI_Prototype
//
//  Created by Zach Fogg on 12/6/21.
//

import AVFoundation

class SpeechService {
    
    private let synthesizer = AVSpeechSynthesizer()
    var rate: Float = AVSpeechUtteranceDefaultSpeechRate * 1.1
    
    func say(_ phrase: String) {
        
        let utterance = AVSpeechUtterance(string: phrase)
        utterance.rate = rate
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance) // can be stopped and paused, etc...
    }
    
    func stopSpeaking(){
        synthesizer.stopSpeaking(at: .immediate)
    }
}
