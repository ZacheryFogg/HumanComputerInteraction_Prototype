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
         
    var allowSwipe: Bool = false
    
    var endingSwipeTranslation = CGPoint(x: 0, y: 0)
        
    var calledFrom: String!
    
    var passedMessage: String!
    
    var helpInstructions: String!
    
    var color: UIColor!
    
    var speechService: SpeechService!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageLabel.text = passedMessage
        self.view.backgroundColor = color
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        voiceOverlayController.settings.layout.inputScreen.subtitleBulletList = ["Confirm Message", "Help", "Playback"]
        voiceOverlayController.settings.layout.inputScreen.subtitleInitial = "Current Possible Commands"
        voiceOverlayController.settings.layout.inputScreen.titleInProgress = "Executing Command:"
        voiceOverlayController.settings.autoStopTimeout = 2.0
        
        
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
        
        messageLabel.isAccessibilityElement = true
        messageLabel.accessibilityHint = "Message notification"
    }
    
    func interpretValidVoiceCommand(text: String){
        speechService.stopSpeaking()
        let command = text.lowercased()
        
        // Confirm Termination
        let confirmPhrases: [String] = ["confirm", "continue"]
        for phrase in confirmPhrases{
            if (command.contains(phrase)){
                confirmMessage()
                return
            }
        }
        
        // Check for Help
        let helpPhrases : [String] = ["help"]
        for phrase in helpPhrases {
            if (command.contains(phrase)){
                speechService.say(self.helpInstructions!)
                return
            }
        }
        
        // Check for Return
        let cancelPhrases: [String] = ["cancel", "return"]
        for phrase in cancelPhrases {
            if (command.contains(phrase)){
                speechService.say("Returning to \(calledFrom!)")
                self.dismiss(animated: true, completion: nil)
                return
            }
        }
        
        // Check for Playback
        let playbackPhrases: [String] = ["playback", "repeat", "play"]
        for phrase in playbackPhrases {
            if (command.contains(phrase)){
                playbackRecent()
                return
            }
        }
        
        // If reaches this point, then command was not able to be matched to an action
        speechService.say(couldNotInterpretDication)
    }
    
    // User acknowledged the message
    func confirmMessage(){
        speechService.say("You acknowledged this message. Returning to \(calledFrom!)")
        self.dismiss(animated: true, completion: nil)
    }
    
    // User wa
    func playbackRecent(){
        speechService.stopSpeaking()
        speechService.say(passedMessage)
    }
    func interpretValidMenuSwipe(swipeDirection: SwipeDirection){
        speechService.stopSpeaking()
        switch swipeDirection {
        case .Up:
            confirmMessage()
        case .Down:
            playbackRecent()
        case .Left:
            speechService.say(noActionOnLeft)
        case .Right:
            speechService.say(noActionOnRight)
        case .Undetermined:
            break
        }
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
            print("Error in Dictation: \(error!)")
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
        
        let angle = (atan2(endPoint.y, endPoint.x) * -180)/Double.pi
        
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
            endingSwipeTranslation = CGPoint(x: 0, y: 0)
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



