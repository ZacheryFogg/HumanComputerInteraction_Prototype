//
//  NavigationViewController.swift
//  HCI_Prototype
//
//  Created by Zach Fogg on 12/7/21.
//
 
import UIKit
import InstantSearchVoiceOverlay

class NavigationViewController: UIViewController {
    
    let voiceOverlayController = VoiceOverlayController()
        
    let speechService = SpeechService()
         
    var endingSwipeTranslation = CGPoint(x: 0.0, y: 0.0)
    
    let minTravelDistForSwipe: CGFloat = 50.0
    
    var allowSwipe: Bool = false
    
    var previousVoiceCommands: [String] = []
    
    var location: String = "Your Mom's House"
    var currentDistanceRemaining: Float = 0.0
    var currentTimeRemaining: String = "10 minutes"
    
    var possibleVoiceCommandSet: [String] = [
        "'What's around me?'",
        "'Where Am I?'",
        "'Cancel navigation'",
        "'Playback most recent audio'",
        "'Help'"
    ]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        guard UIAccessibility.isVoiceOverRunning else {return}
        speechService.say("Navigation Session Started to: \(location)")
        speechService.say("The destination is: \(currentDistanceRemaining) kilometers away")
        speechService.say("The journey should take: \(currentTimeRemaining)")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isUserInteractionEnabled = true
        self.view.isMultipleTouchEnabled = true
        
        // Preconfigure voiceOverlayController
        voiceOverlayController.delegate = self
        voiceOverlayController.settings.autoStart = true
        voiceOverlayController.settings.autoStop = true
        voiceOverlayController.settings.layout.inputScreen.subtitleBulletList = possibleVoiceCommandSet
        voiceOverlayController.settings.layout.inputScreen.titleListening = "Current Possible Commands"
        voiceOverlayController.settings.autoStopTimeout = 3.0
        
        // Do any additional setup after loading the view.
        
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
        
    }
    
    func interpretValidMenuSwipe(swipeDirection: SwipeDirection){
        speechService.stopSpeaking()
        switch swipeDirection {
        case .Up:
            
            // Present the confirm cancelation modal with message
            let cancelViewController = self.storyboard?.instantiateViewController(withIdentifier: "CancelViewController") as! CancelViewController
            cancelViewController.modalTransitionStyle = .flipHorizontal
            cancelViewController.modalPresentationStyle = .overCurrentContext
            cancelViewController.passedMessage = navigationCancelationPrompt
            cancelViewController.calledFrom = "Navigation"
            
            present(cancelViewController, animated: true, completion: nil)
                        
        case .Down:
            // Here we will play back the most recent audio output
            if let phrase = previousVoiceCommands.last{
                speechService.say(phrase)
            } else {
                speechService.say(noPlayback)
            }
        case .Left:

            let phrase = "X is 50 meters to your left, Y is 10 meters to your direction"
            speechService.say(phrase)
            previousVoiceCommands.append(phrase)
            
        case .Right:
            
            let phrase = "You are at the intersection of X and Y"
            speechService.say(phrase)
            previousVoiceCommands.append(phrase)
            
        case .Undetermined:
            break
        }
    }
    
    // Dismiss modal view and the
    func confirmedCancelation(){
        self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
}

extension NavigationViewController: VoiceOverlayDelegate {
    
    func startDictationEvent() {
        voiceOverlayController.start(on: self, textHandler: {text, final, _ in
            
            if final {
                print("Final Text: \(text)")
            } else {
                print("In progress: \(text)")
            }
        }, errorHandler: { error in
            
        })
    }
    
    func recording(text: String?, final: Bool?, error: Error?) {
        if let str = text {
            print("Hey now: \(str)")
        }
        
    }
    
    /*
    When a user has finished dictating a command, interpret it and perform the desired action
     */
    func interpretValidVoiceCommand(command: String){
        
    }
}

/* Logic associated with handling gestures */
extension NavigationViewController: UIGestureRecognizerDelegate {
        
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
    
    @objc func doubleTapHandler(sender: UITapGestureRecognizer) {
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
