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
         
    var allowSwipe: Bool = false
    
    var endingSwipeTranslation = CGPoint(x: 0, y:0)
    
    let minTravelDistForSwipe: CGFloat = 50.0
    
    var filteredData: [String]!
    
    var parentVC: NavigationViewController!
    
    var possibleVoiceCommandSet: [String] = [
        "Address of your desired destination",
        "'Help'"
    ]
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        titleLabel.text = "Enter/Dictate Destination, or choose from saved"
        // Configure Search Field
//        searchField.attributedPlaceholder = NSAttributedString(
//            string: "Enter or Dictate Search Query",
//            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
//        )
//
//        searchField.layer.cornerRadius = 5.0
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        guard UIAccessibility.isVoiceOverRunning else {return}
//        speechService.say("Voices in my head again, trapped in a war inside my own skin. They. Are. Pulling. Me ... under!")
        speechService.say("Enter destination or choose from saved")
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
        
        // Search Bar Stuff

        tableView.dataSource = self
        searchBar.delegate = self
//        tableView.tableHeaderView?.layer.backgroundColor = CGColor(red: 89/255, green: 4/255, blue: 35/255, alpha: 1.0)
        filteredData = data
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")

        cell.backgroundColor = UIColor(red: 29/255, green: 85/255, blue: 120/255, alpha: 1.0)
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = filteredData[indexPath.row]
        return cell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as UITableViewCell
//        cell.textLabel?.text = filteredData[indexPath.row]
//        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
          print("You selected cell #\(indexPath.row)!")

      }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            // When there is no text, filteredData is the same as the original data
            // When user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
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
            print("Possibly add recent playback functionality")
        default:
            break
        }
        print("Menu swipes here would be handled by Voice Over and that is hard to do on a simulator. So functionality will be assumed")
        
    }
    
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
        
        parentVC.retrieveDestinationAndTerminateChild(child: self, destination: text)
    }
    
    func terminate(){
        speechService.say("Terminating destination selection. Returning to start screen.")
//        self.presentingViewController?.dismissFromChild()
        parentVC.dismissFromChild(child: self)
    }
    
}


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
