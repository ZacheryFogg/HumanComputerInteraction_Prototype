//
//  NavigationViewController.swift
//  HCI_Prototype
//
//  Created by Zach Fogg on 12/7/21.
//
 
import UIKit
import InstantSearchVoiceOverlay

class NavigationViewController: UIViewController {
    
    // Outlets
    @IBOutlet var navigationInstruction: UILabel!
    @IBOutlet var otherVoiceOutputs: UILabel!
    
    //    @IBOutlet var upSwipeMenuImage: UIImageView!
    //    @IBOutlet var upSwipeMenuLabel: UILabel!
        
    @IBOutlet var leftSwipeMenuImage: UIImageView!
    @IBOutlet var leftSwipeMenuLabel: UILabel!

    @IBOutlet var rightSwipeMenuImage: UIImageView!
    @IBOutlet var rightSwipeMenuLabel: UILabel!
        
//        @IBOutlet var downSwipeMenuImage: UIImageView!
//        @IBOutlet var downSwipeMenuLabel: UILabel!
    
    
    let voiceOverlayController = VoiceOverlayController()
        
    var speechService: SpeechService!
         
    var endingSwipeTranslation = CGPoint(x: 0.0, y: 0.0)
    
    let minTravelDistForSwipe: CGFloat = 50.0
    
    var allowSwipe: Bool = false
    
    var previousAudioOutputs: [String] = []
    
    var previousNavigationInstructions: [String] = []
    
    var destination: String = ""
    
    var currentDistanceRemaining: Float = 0.0
    var currentTimeRemaining: String = "10 minutes"
    
    var possibleVoiceCommandSet: [String] = [
        "'What's around me?'",
        "'Where Am I?'",
        "'Terminate navigation'",
        "'Playback most recent audio'",
        "'Help'"
    ]
    
    var sampleInstructions: [String] = [
        "Continue along X for Y",
        "Take an X on Y in Z meters",
        "Continue along A for B meters",
        "In X meters, your destination will be on you Y"
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationInstruction.text = sampleInstructions.first!
        otherVoiceOutputs.text = sampleAroundMe.first!
        
        leftSwipeMenuImage.image = UIImage(systemName: "arrow.left")?.withRenderingMode(.alwaysTemplate)
        leftSwipeMenuImage.tintColor = .white
        
        leftSwipeMenuLabel.text = "What's Around Me?"
        leftSwipeMenuLabel.textColor = .white
        leftSwipeMenuLabel.textAlignment = .left
    
        
        rightSwipeMenuImage.image = UIImage(systemName: "arrow.right")?.withRenderingMode(.alwaysTemplate)
        rightSwipeMenuImage.tintColor = .white
        
        rightSwipeMenuLabel.text = "Where Am I?"
        rightSwipeMenuLabel.textColor = .white
        rightSwipeMenuLabel.textAlignment = .right
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        guard UIAccessibility.isVoiceOverRunning else {return}
//        speechService.say("Navigation Session Started to: \(location)")
//        speechService.say("The destination is: \(currentDistanceRemaining) kilometers away")
//        speechService.say("The journey should take: \(currentTimeRemaining)")
        presentChooseDestinationView()
    }
    
    func presentChooseDestinationView(){
        let destinationViewController = self.storyboard?.instantiateViewController(withIdentifier: "SelectDestinationViewController") as! SelectDestinationViewController
        destinationViewController.modalTransitionStyle = .coverVertical
        destinationViewController.modalPresentationStyle = .popover
        destinationViewController.parentVC = self
        destinationViewController.speechService = speechService
        present(destinationViewController, animated: true, completion: nil)
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
        voiceOverlayController.settings.layout.inputScreen.subtitleInitial = "Current Possible Commands"
        voiceOverlayController.settings.layout.inputScreen.titleInProgress = "Executing Command:"
        voiceOverlayController.settings.autoStopTimeout = 2.0
        
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
            promptCancelNavigation()
        case .Down:
            // Here we will play back the most recent audio output
            if let phrase = previousAudioOutputs.last{
                speechService.say(phrase)
            } else {
                speechService.say(noPlayback)
            }
        case .Left:

            let phrase = "X is 50 meters to your left, Y is 10 meters to your direction"
            speechService.say(phrase)
            previousAudioOutputs.append(phrase)
            
        case .Right:
            
            let phrase = "You are at the intersection of X and Y"
            speechService.say(phrase)
            previousAudioOutputs.append(phrase)
            
        case .Undetermined:
            break
        }
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
                promptCancelNavigation()
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
    
    // Ouput an instruction in both audio format and to screen visually
    func outputInstruction(phrase: String){
        speechService.say(phrase)
        previousAudioOutputs.append(phrase)
        navigationInstruction.text = phrase
    }
    
    // Ouput information that is not an explicit navigation instruction in both audio format and to screen visually
    func outputInformation(phrase: String){
        speechService.say(phrase)
        previousAudioOutputs.append(phrase)
        otherVoiceOutputs.text = phrase
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
    
    func promptCancelNavigation(){
        // Present the confirm cancelation modal with message
        let cancelViewController = self.storyboard?.instantiateViewController(withIdentifier: "CancelViewController") as! CancelViewController
        cancelViewController.modalTransitionStyle = .flipHorizontal
        cancelViewController.modalPresentationStyle = .overCurrentContext
        cancelViewController.passedMessage = navigationCancelationPrompt
        cancelViewController.speechService = speechService
        cancelViewController.parentVC = self
        cancelViewController.calledFrom = "Navigation"
        
        present(cancelViewController, animated: true, completion: nil)
    }
    
    func createAndPresentPopup(color: UIColor, message: String) {
        let popupViewController = self.storyboard?.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
        popupViewController.modalTransitionStyle = .coverVertical
        popupViewController.modalPresentationStyle = .popover
        popupViewController.passedMessage = message
        popupViewController.color = color
        present(popupViewController, animated: true, completion: nil)
    }
    
    func retrieveDestinationAndTerminateChild(child: SelectDestinationViewController, destination: String) {
        child.dismiss(animated: true, completion: nil)
        self.destination = destination
        startNavigationToDestination(destination: destination)
    }
    
    func startNavigationToDestination(destination: String){
        outputInformation(phrase: "Starting navigation to: \(destination)")
    }
    
    func terminateFromChild(child: UIViewController){
        child.dismiss(animated: true , completion: nil)
        self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }

}

extension NavigationViewController: VoiceOverlayDelegate {
    
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

extension UIViewController {
    func dismissFromChild(child: UIViewController){
        child.dismiss(animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
    }
    
    func dismissChild(child: UIViewController){
        child.dismiss(animated: true, completion: nil)
    }
}
