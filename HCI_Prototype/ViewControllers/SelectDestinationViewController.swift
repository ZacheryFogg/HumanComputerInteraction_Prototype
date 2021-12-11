//
//  SelectDestinationViewController.swift
//  HCI_Prototype
//
//  Created by Zach Fogg on 12/7/21.
//

import UIKit
import InstantSearchVoiceOverlay

class SelectDestinationViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
//    @IBOutlet var searchField: UITextField!
    
    let data = ["New York, NY", "Los Angeles, CA", "Chicago, IL", "Houston, TX",
           "Philadelphia, PA", "Phoenix, AZ", "San Diego, CA", "San Antonio, TX",
           "Dallas, TX", "Detroit, MI", "San Jose, CA", "Indianapolis, IN",
           "Jacksonville, FL", "San Francisco, CA", "Columbus, OH", "Austin, TX",
           "Memphis, TN", "Baltimore, MD", "Charlotte, ND", "Fort Worth, TX"]
    
    
    let voiceOverlayController = VoiceOverlayController()
        
    var speechService: SpeechService!
         
    var allowSwipe: Bool = false // This will be set to true once a user long presses to simulate the haptic touch menu
    
    var endingSwipeTranslation = CGPoint(x: 0, y:0) // Track how a user swipes to determine direction
        
    var filteredData: [String]!
    
    var parentVC: NavigationViewController!
    
    var previousAudioOutputs: [String] = []

    var possibleVoiceCommandSet: [String] = [
        "Address of your desired destination",
        "Terminate Navigation",
        "'Help'"
    ]
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = "Destination Selection"

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        speechService.say(selectDestinationStartInstruction)
        previousAudioOutputs.append(selectDestinationStartInstruction)
        
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
        
        // Attacking gesture recognizers to the view
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
        
        // Search bar Configuration
        tableView.dataSource = self
        searchBar.delegate = self
        filteredData = data
        
    }
    
    /*
     Create cells for each item in the dataSource and populate the table view them
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")

        cell.backgroundColor = UIColor(red: 29/255, green: 85/255, blue: 120/255, alpha: 1.0)
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = filteredData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    /*
     Respond to changes in the search bar status to filter data
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

            filteredData = searchText.isEmpty ? data : data.filter { (item: String) -> Bool in
                // If dataItem matches the searchText, return true to include it
                return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
            tableView.reloadData()
        }
    
    
    func interpretValidMenuSwipe(swipeDirection: SwipeDirection){
        switch swipeDirection {
        case .Up:
            // User terminates destination selection and goes back to start screen
            terminate()
        case .Down:
            if let phrase = previousAudioOutputs.last{
                speechService.say(phrase)
            } else {
                speechService.say(noPlayback)
            }
        default:
            break
        }
        print("Menu swipes here would be handled by Voice Over and that is hard to do on a simulator. So functionality will be assumed")
        
    }
    
    /*
     Try and parse voice input to match some primitive commands
     */
    func interpretValidVoiceCommand(text: String){
        speechService.stopSpeaking()
        
        let command = text.lowercased()
        
        // Check for Help
        let helpPhrases : [String] = ["help"]
        
        for phrase in helpPhrases {
            if (command.contains(phrase)){
                speechService.say(selectDestinationInstructions)
                return
            }
        }
        
        // Check for Termination
        let cancelPhrases: [String] = ["cancel", "terminate"]
        for phrase in cancelPhrases {
            if (command.contains(phrase)){
                terminate()
                
            }
        }
        
        // If the user did not ask for help or to terminate the view, then
        // we will assume that the input is valid as we have no backend
        parentVC.retrieveDestinationAndTerminateChild(child: self, destination: text)
    }
    
    /*
     Terminate session and return to start menu
     */
    func terminate(){
        speechService.say("Terminating destination selection. Returning to start screen.")
        parentVC.dismissFromChild(child: self)
    }
    
}

/*
 Make this view a delegate for the voice overlay controller so that it can recieve voice command events
 */
extension SelectDestinationViewController: VoiceOverlayDelegate {
    
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


extension SelectDestinationViewController: UIGestureRecognizerDelegate {
    
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
    
    /*
     This is the second component of a "gesture" where the user has long pressed and will now "swipe" in a direction
     */
    @objc func panHandler(sender: UIPanGestureRecognizer) {
        // A swipe will only be processed if a long press is also in progress
        if allowSwipe{
            if sender.state == .changed{
                endingSwipeTranslation = sender.translation(in: sender.view!.superview)
            }
        }
    }
    
    /* A double tap will always start a dictation event in any view*/
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
                // This is a special hardcoded case where we just want to pretend that the user used VoiceOver to select one of the destinations
                // represented by a cell... here we just always navigate to Los Angeles
                print("Just selecting a cell")
                speechService.stopSpeaking()
                let text = "Los Angeles, California"
                parentVC.retrieveDestinationAndTerminateChild(child: self, destination: text)
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
