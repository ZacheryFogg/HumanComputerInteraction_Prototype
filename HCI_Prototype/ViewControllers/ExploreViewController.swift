//
//  ExploreViewController.swift
//  HCI_Prototype
//
//  Created by Zach Fogg on 12/7/21.
//


import UIKit
import InstantSearchVoiceOverlay

class ExploreViewController: UIViewController {
    
    @IBOutlet weak var audioOutputLabel: UILabel!
    
    let voiceOverlayController = VoiceOverlayController()
        
    var speechService: SpeechService!
         
    var allowSwipe: Bool = false
    
    var endingSwipeTranslation = CGPoint(x: 0.0, y: 0.0)
    
    let minTravelDistForSwipe: CGFloat = 50.0
    
    var previousAudioOutputs: [String] = []
    
    var possibleVoiceCommandSet: [String] = [
        "'What's around me?'",
        "'Where Am I?'",
        "'Terminate exploration'",
        "'Playback most recent audio'",
        "'Help'"
    ]
   
    var sampleWhereAmI: [String] = [
        "You are approaching the intersection of X and Y",
        "You are X and Y",
        "I am at your dear mother's house"
    ]
    
    var sampleAroundMe: [String] = [
        "I am to your left. You are to my right",
        "10 meters in front of you is the entrance to your mother",
        "I am 10 meters behind your mom"
    
    ]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        guard UIAccessibility.isVoiceOverRunning else {return}
//        speechService.say("Voices in my head again, trapped in a war inside my own skin. They. Are. Pulling. Me ... under!")
        speechService.say("Exploration Session Started")
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isUserInteractionEnabled = true
        self.view.isMultipleTouchEnabled = true
        
        // Preconfigure voiceOverlayController
        voiceOverlayController.delegate = self
        voiceOverlayController.settings.autoStart = true
        voiceOverlayController.settings.autoStop = true
        voiceOverlayController.settings.autoStopTimeout = 3.0
        
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
        
        
//        simulate()
        
    }
    

    
    func simulate() {
        let seconds = 3.0
//        await Task.sleep(UInt64(seconds * Double(NSEC_PER_SEC)))
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.createAndPresentPopup(color: UIColor.systemRed, message: "This is a very important Alert")
//            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
//                self.createAndPresentPopup(color: UIColor.systemBlue, message: "This is a very important Alert")
//            }
        }
        
        
    }
    
    func createAndPresentPopup(color: UIColor, message: String) {
        let popupViewController = self.storyboard?.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
        popupViewController.modalTransitionStyle = .coverVertical
        popupViewController.modalPresentationStyle = .popover
        popupViewController.passedMessage = message
        popupViewController.color = color
        present(popupViewController, animated: true, completion: {print("This is where we could dimiss")})
    }
    
    func promptCancelExploration(){
        // Present the confirm cancelation modal with message
        let cancelViewController = self.storyboard?.instantiateViewController(withIdentifier: "CancelViewController") as! CancelViewController
        cancelViewController.modalTransitionStyle = .flipHorizontal
        cancelViewController.modalPresentationStyle = .overCurrentContext
        cancelViewController.passedMessage = explorationCancelationPrompt
        cancelViewController.speechService = speechService
        cancelViewController.parentVC = self
        cancelViewController.calledFrom = "Exploration"
        
        present(cancelViewController, animated: true, completion: nil)
    }
    
    func interpretValidMenuSwipe(swipeDirection: SwipeDirection){
        speechService.stopSpeaking()
        switch swipeDirection {
        case .Up:
            // Present the confirm cancelation modal with message
            promptCancelExploration()
                        
        case .Down:
            // Here we will play back the most recent audio output
            if let phrase = previousAudioOutputs.last{
                speechService.say(phrase)
            } else {
                speechService.say(noPlayback)
            }
            
        case .Left:
            // Here we will present that same modal view by w/ different text
            outputInformation(phrase: getAroundMe())
        case .Right:
            // Here we will present a modal view over the explore view
            outputInformation(phrase: getWhereAmI())
        case .Undetermined:
            break
        }
    }
    
   

    // Ouput information that is not an explicit navigation instruction in both audio format and to screen visually
    func outputInformation(phrase: String){
        speechService.say(phrase)
        previousAudioOutputs.append(phrase)
        audioOutputLabel.text = phrase
    }
    
    func getAroundMe() -> String{
        if let sample = sampleAroundMe.randomElement(){
            return sample
        }
        return "Nothing is around you, you exist in a void"
    }
    
    func getWhereAmI() -> String{
        if let sample = sampleWhereAmI.randomElement(){
            return sample
        }
        return "You are the infinite, and are thus, everywhere"
    }
    
    /*
    When a user has finished dictating a command, interpret it and perform the desired action
     */
    func interpretValidVoiceCommand(text: String){
    
        speechService.stopSpeaking()
        
        let command = text.lowercased()
        
        // Check for Around Me
        let aroundMePhrases: [String] = ["around", "near"]
        
        for phrase in aroundMePhrases{
            if (command.contains(phrase)){
                outputInformation(phrase: getAroundMe())
                return
            }
        }
        
        // Check for Where Am I
        let whereAmIPhrases: [String] = ["where"]
        
        for phrase in whereAmIPhrases {
            if (command.contains(phrase)){
                outputInformation(phrase: getWhereAmI())
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
        
        // Check for cancel
        let cancelPhrases: [String] = ["cancel", "end", "stop"]
        
        for phrase in cancelPhrases {
            if (command.contains(phrase)){
                promptCancelExploration()
                return
            }
        }
        
        
        // Check for Playback
        let playbackPhrases : [String] = ["playback", "play back", "repeat", "play"]
        print(command)
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
}

extension ExploreViewController: VoiceOverlayDelegate {
    
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
    
    /*
    When a user has finished dictating a command, interpret it and perform the desired action
     */
    func interpretValidVoiceCommand(command: String){
        
    }
}

/* Logic associated with handling gestures */
extension ExploreViewController: UIGestureRecognizerDelegate {
    
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
//        print(angle)
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ConfirmCancelationExplore"){
            var messageToPass = "Passed Message"
            
            let destinationVC = segue.destination as! CancelViewController
            destinationVC.passedMessage = messageToPass
        }
        else {
            print("Not Cancellation Seque")
        }
    }
}





