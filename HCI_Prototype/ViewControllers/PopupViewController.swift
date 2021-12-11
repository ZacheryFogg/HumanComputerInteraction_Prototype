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
    
    var endingSwipeTranslation = CGPoint(x: 0, y: 0)
        
    var calledFrom: String!
    
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
        
        self.view.isUserInteractionEnabled = true
        self.view.isMultipleTouchEnabled = true
        
        // Preconfigure voiceOverlayController
        voiceOverlayController.delegate = self
        voiceOverlayController.settings.autoStart = true
        voiceOverlayController.settings.autoStop = true
        voiceOverlayController.settings.layout.inputScreen.subtitleBulletList = ["Confirm Alert", "Help", "Playback"]
        voiceOverlayController.settings.layout.inputScreen.subtitleInitial = "Current Possible Commands"
        voiceOverlayController.settings.layout.inputScreen.titleInProgress = "Executing Command:"
        voiceOverlayController.settings.autoStopTimeout = 2.0
        
        // Do any additional setup after loading the view.
//        startDictationButton.backgroundColor = .systemRed
//        startDictationButton.setTitleColor(.white, for: .normal)x
//
//        startDictationButton.isAccessibilityElement = true
//        startDictationButton.accessibilityHint = "Pressing this button start a process to listen for a voice command"
        
        // Add gesture recognizers to view
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.delegate = self
        self.view.addGestureRecognizer(longPressGesture)

        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panHandler))
        panGesture.delegate = self
        self.view.addGestureRecognizer(panGesture)
        
         
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler))
        doubleTapGesture.delegate = self
        doubleTapGesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapGesture)
        
        messageLabel.contentMode = .scaleToFill
        messageLabel.numberOfLines = 0
        
    }
    
    func interpretValidVoiceCommand(text: String){
        speechService.stopSpeaking()
        let command = text.lowercased()
        
        // Confirm Termination
        let confirmPhrases: [String] = ["confirm", "continue"]
        
        for phrase in confirmPhrases{
            if (command.contains(phrase)){
                dismiss(animated: true, completion: nil)
                return
            }
        }
        
        // Check for Help
        let helpPhrases : [String] = ["help"]
        
        for phrase in helpPhrases {
            if (command.contains(phrase)){
                speechService.say(alertHelpInstructions)
                return
            }
        }
        
        // Check for cancel
        let cancelPhrases: [String] = ["cancel", "return"]
        
        for phrase in cancelPhrases {
            if (command.contains(phrase)){
                speechService.say("Returning to \(calledFrom!)")
                self.dismiss(animated: true, completion: nil)
                return
                
            }
        }
        
        let playbackPhrases: [String] = ["playback", "repeat", "play"]
    
        for phrase in playbackPhrases {
            if (command.contains(phrase)){
                speechService.stopSpeaking()
                speechService.say(passedMessage)
                return
            }
        }
        
        speechService.say(couldNotInterpretDication)
    }
    func interpretValidMenuSwipe(swipeDirection: SwipeDirection){
//        self.dismiss(animated: true, completion: nil)
    }
}

extension PopupViewController: VoiceOverlayDelegate {
    
    func startDictationEvent() {
        speechService.stopSpeaking()
        voiceOverlayController.start(on: self, textHandler: {text, final, _ in
        
            if final {
                print(text)
                self.dismiss(animated: true, completion: nil)
                if !text.isEmpty {self.interpretValidVoiceCommand(text: text)}
            }
        }, errorHandler: { error in
            print("Error in Dictation: \(error)")
        })
    }
    
    func recording(text: String?, final: Bool?, error: Error?) {
        return
    }
    
}

extension PopupViewController: UIGestureRecognizerDelegate {
    
    /*
     Determine the direction of a swipe that met the required distance
     */
    func determineSwipeDirection(endPoint: CGPoint) ->  SwipeDirection{
        let rightStart = -45.0
        let rightEnd = 45.0
        
        let leftStart = 135.0
        let leftEnd = -135.0
        
        let upStart = rightEnd + 0.01
        let upEnd = leftStart - 0.01
        
        let downStart = leftEnd + 0.01
        let downEnd = rightStart - 0.01
        
        // This logic should be updated later
//        print("End: \(endPoint)")
        let angle = (atan2(endPoint.y, endPoint.x) * -180)/Double.pi
        print(angle)
        
        if angle >= rightStart && angle <= rightEnd {return SwipeDirection.Right}
        if angle >= upStart && angle <= upEnd { return SwipeDirection.Up}
        if angle >= leftStart || angle <= leftEnd { return SwipeDirection.Left}
        if angle >= downStart && angle <= downEnd {return SwipeDirection.Down}
        
        return SwipeDirection.Undetermined
        
    }

        
    @objc func panHandler(sender: UIPanGestureRecognizer) {
        // A swipe will only be processed if a long press is also in progress
        if allowSwipe{
            if sender.state == .changed{
                endingSwipeTranslation = sender.translation(in: sender.view!.superview)
            }
        }
    }
    
    @objc func singleTapHandler(sender: UITapGestureRecognizer) {
        speechService.stopSpeaking()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doubleTapHandler(sender: UITapGestureRecognizer) {
        speechService.stopSpeaking()
        startDictationEvent()
    }
    
  
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        switch gestureRecognizer.state {
        case .began:
            print("vibrate")
            allowSwipe = true
        case .ended:
            if (abs(endingSwipeTranslation.x) >= minTravelDistForSwipe || abs(endingSwipeTranslation.y) >= minTravelDistForSwipe){
                let result: SwipeDirection = determineSwipeDirection(endPoint: endingSwipeTranslation)
                if result != SwipeDirection.Undetermined {
                    interpretValidMenuSwipe(swipeDirection: result)
                } else {
                    print("Undetermined Swipe Direction")
                }
            } else {
                print("Failed Swipe Gesture: \(endingSwipeTranslation)")
            }
            allowSwipe = false

        case .failed:
            allowSwipe = false
        default:
            break
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}



