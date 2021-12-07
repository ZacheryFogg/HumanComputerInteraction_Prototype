//
//  SpeechService.swift
//  HCI_Prototype
//
//  Created by Zach Fogg on 12/6/21.
//

import AVFoundation

class SpeechService {
    
    private let systhesizer = AVSpeechSynthesizer()
    var rate: Float = AVSpeechUtteranceDefaultSpeechRate * 1.0
    
    func say(_ phrase: String) {
        
        let utterance = AVSpeechUtterance(string: phrase)
        utterance.rate = rate
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        systhesizer.speak(utterance) // can be stopped and paused, etc...
    }
    
}
