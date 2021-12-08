//
//  SelectDestinationViewController.swift
//  HCI_Prototype
//
//  Created by Zach Fogg on 12/7/21.
//

import UIKit
import InstantSearchVoiceOverlay

class SelectDestinationViewController: UIViewController {
    
        
    let voiceOverlayController = VoiceOverlayController()
        
    let speechService = SpeechService()
         
    var allowSwipe: Bool = false
    
    var endingSwipeTranslation: CGPoint!
    
    let minTravelDistForSwipe: CGFloat = 50.0
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        guard UIAccessibility.isVoiceOverRunning else {return}
//        speechService.say("Voices in my head again, trapped in a war inside my own skin. They. Are. Pulling. Me ... under!")
        speechService.say("Enter destination or choose from saved")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.view.isUserInteractionEnabled = true
        self.view.isMultipleTouchEnabled = true
        
    }
}
