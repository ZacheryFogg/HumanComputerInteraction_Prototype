//
//  PopupViewController.swift
//  HCI_Prototype
//
//  Created by Zach Fogg on 12/7/21.
//


import Foundation


import UIKit
import InstantSearchVoiceOverlay

class PopupViewController: UIViewController {
    
    
    @IBOutlet var messageLabel: UILabel!
    
    let voiceOverlayController = VoiceOverlayController()
        
    let speechService = SpeechService()
         
    var allowSwipe: Bool = false
    
    var endingSwipeTranslation: CGPoint!
    
    let minTravelDistForSwipe: CGFloat = 50.0
    
    var passedMessage: String!
    var color: UIColor!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageLabel.text = passedMessage
        self.view.backgroundColor = color
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        guard UIAccessibility.isVoiceOverRunning else {return}
//        speechService.say("Voices in my head again, trapped in a war inside my own skin. They. Are. Pulling. Me ... under!")
        speechService.say(passedMessage)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.view.isUserInteractionEnabled = true
        self.view.isMultipleTouchEnabled = true
        
    }
}




