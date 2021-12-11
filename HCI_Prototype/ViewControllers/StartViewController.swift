//
//  ViewController.swift
//  HCI_Prototype
//
//  Created by Zach Fogg on 11/9/21.
//

import UIKit
import InstantSearchVoiceOverlay

enum SwipeDirection {
    case Up, Down, Left, Right, Undetermined
}

class StartViewController: UIViewController {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var gestureView: UIImageView!
    //04456e darker  UIColor(red: 4/255, green: 69/255, blue: 110/255, alpha: 1.0)
    //1d5578  UIColor(red: 29/255, green: 85/255, blue: 120/255, alpha: 1.0)
    
    // Swipe Menu, this is going to be annoying to configure
//    @IBOutlet var upSwipeMenuImage: UIImageView!
//    @IBOutlet var upSwipeMenuLabel: UILabel!
    
//    @IBOutlet var leftSwipeMenuImage: UIImageView!
//    @IBOutlet var leftSwipeMenuLabel: UILabel!
//
//    @IBOutlet var rightSwipeMenuImage: UIImageView!
//    @IBOutlet var rightSwipeMenuLabel: UILabel!
    
//    @IBOutlet var downSwipeMenuImage: UIImageView!
//    @IBOutlet var downSwipeMenuLabel: UILabel!
    
//    @IBOutlet var centerSwipeMenuImage: UIImageView!
    
    
//    UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
    
    var previousAudioOutputs: [String] = []
    
    let voiceOverlayController = VoiceOverlayController()
        
    let speechService = SpeechService()
         
    var allowSwipe: Bool = false
    
    var endingSwipeTranslation: CGPoint = CGPoint(x: 0.0, y: 0.0)
    
    var possibleVoiceCommandSet: [String] = [
        "'Start Navigation'",
        "'Start Exploration'",
        "'Playback most recent audio'",
        "'Help'"
    ]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        speechService.say(appStartInstructions)
        previousAudioOutputs.append(appStartInstructions)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure Swipe Menu
//        upSwipeMenuImage.image = UIImage(systemName: "arrow.up")?.withRenderingMode(.alwaysTemplate)
//        upSwipeMenuLabel.text = "NA"
//        upSwipeMenuLabel.textColor = .systemBlue
        
//        leftSwipeMenuImage.image = UIImage(systemName: "arrow.left")?.withRenderingMode(.alwaysTemplate)
//        leftSwipeMenuImage.tintColor = .white
//
//        leftSwipeMenuLabel.text = "Explore Mode"
//        leftSwipeMenuLabel.textColor = .white
//        leftSwipeMenuLabel.textAlignment = .left
//
//
//        rightSwipeMenuImage.image = UIImage(systemName: "arrow.right")?.withRenderingMode(.alwaysTemplate)
//        rightSwipeMenuImage.tintColor = .white
//
//        rightSwipeMenuLabel.text = "Navigation Mode"
//        rightSwipeMenuLabel.textColor = .white
//        rightSwipeMenuLabel.textAlignment = .right
        
        gestureView.image = UIImage(named: "startMenu")
        
//        downSwipeMenuImage.image = UIImage(systemName: "arrow.down")?.withRenderingMode(.alwaysTemplate)
//        downSwipeMenuLabel.text = "NA"
//        downSwipeMenuLabel.textColor = .systemBlue
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.isUserInteractionEnabled = true
        self.view.isMultipleTouchEnabled = true
        
        speechService.muted = true
        // Preconfigure voiceOverlayController
        voiceOverlayController.delegate = self
        voiceOverlayController.settings.autoStart = true
        voiceOverlayController.settings.autoStop = true
        voiceOverlayController.settings.layout.inputScreen.subtitleBulletList = possibleVoiceCommandSet
        voiceOverlayController.settings.layout.inputScreen.subtitleInitial = "Current Possible Commands"
        voiceOverlayController.settings.autoStopTimeout = 2.0
        
        // Do any additional setup after loading the view.
//        startDictationButton.backgroundColor = .systemRed
//        startDictationButton.setTitleColor(.white, for: .normal)
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
        
        contentView.layer.cornerRadius = 10.0
        
    }
    
    /*
    When a user has finished dictating a command, interpret it and perform the desired action
     */
    func interpretValidVoiceCommand(text: String){
    
        speechService.stopSpeaking()
        
        let command = text.lowercased()
        
        // Check for Navigation
        let navigationPhrases: [String] = ["navigation", "navigate"]
        
        for phrase in navigationPhrases{
            if (command.contains(phrase)){
                print("Navigation Mode")
                launchNavigationSession()
                return
            }
        }
        
        // Check for Exploration
        let explorePhrases: [String] = ["explore", "exploration"]
        
        for phrase in explorePhrases {
            if (command.contains(phrase)){
                launchExploreSession()
                return
            }
        }
        
        // Check for Help
        let helpPhrases : [String] = ["help"]
        
        for phrase in helpPhrases {
            if (command.contains(phrase)){
                speechService.say(startHelpInstructions)
                return
            }
        }
        
        
        // Check for Playback
        let playbackPhrases : [String] = ["playback", "play back", "repeat"]
        
        for phrase in playbackPhrases {
            if (command.contains(phrase)) {
                if let playbackPhrase = previousAudioOutputs.last{
                    speechService.say(playbackPhrase)
                    return
                } else {
                    speechService.say(noPlayback)
                    return
                }
                
            }
        }
        
        speechService.say(couldNotInterpretDication)
        return
        
    }
    
    func interpretValidMenuSwipe(swipeDirection: SwipeDirection){
        speechService.stopSpeaking()
        switch swipeDirection{
        case .Right:
            self.launchNavigationSession()
        case .Left:
            self.launchExploreSession()
        case .Down:
            if let phrase = previousAudioOutputs.last{
                speechService.say(phrase)
            } else {
                speechService.say(noPlayback)
            }
        default:
            break
            
        }
    }
    
    func launchNavigationSession(){
        let navigationViewController = self.storyboard?.instantiateViewController(withIdentifier: "NavigationViewController") as! NavigationViewController
        navigationViewController.modalTransitionStyle = .flipHorizontal
        navigationViewController.modalPresentationStyle = .fullScreen
        navigationViewController.speechService = speechService
        present(navigationViewController, animated: true, completion: nil)
    }
    
    func launchExploreSession(){
        let exploreViewController = self.storyboard?.instantiateViewController(withIdentifier: "ExploreViewController") as! ExploreViewController
        exploreViewController.modalTransitionStyle = .flipHorizontal
        exploreViewController.modalPresentationStyle = .fullScreen
        exploreViewController.speechService = speechService
        present(exploreViewController, animated: true, completion: nil)
    }
}


extension StartViewController: VoiceOverlayDelegate {
    
    func startDictationEvent() {
        speechService.stopSpeaking()
        voiceOverlayController.start(on: self, textHandler: {text, final, _ in
        
            if final {
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

/* Logic associated with handling gestures */
extension StartViewController: UIGestureRecognizerDelegate {
    
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


