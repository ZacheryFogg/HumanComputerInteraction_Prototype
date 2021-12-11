//
//  ConfigurationConstants.swift
//  HCI_Prototype
//
//  Created by Zach Fogg on 12/7/21.
//

import Foundation
import UIKit

// Constants

let minTravelDistForSwipe: CGFloat = 50.0


// Configuration for Audio Feedback

let appStartInstructions: String =
    """
    Double tap anywhere to start dictation.
    Dictate - 'Help' - to hear the current possible commands and gestures.
    To use swipe gestures, long press until you feel haptic feedback, and then swipe in the desired direction
    """

let undeterminedInputCommand: String =
    """
    Your voice command could not be interpreted and matched to any of the possible actions.
    Double tap an press 'Help' to here the current possible commands and gestures
    """

let noPlayback: String = "There is no recent audio to playback at this time"

let navigationCancelationPrompt =
"""
Are you sure that you want to end your navigation session?


Gesture upwards or dictate - 'Confirm' - to confirm cancelation.


Gesture downwards or dictate - 'Return to Navigation' - to return to navigation
"""


let explorationCancelationPrompt =
"""
Are you sure that you want to end your exploration session?


Swipe up or dictate - 'Confirm' - to confirm cancelation.


Swipe down or dictate - 'Return to Exploration' - to return to exploration
"""


let startHelpInstructions =
"""
You are currently at the start menu.
You can start a navigation session by dictating: "Start Navigation", or gesturing right.
You can start an exploration session by dictating: "Start Exploration", or gesturing left.
You can hear the most recent instruction by dictating "Playback" or gesturing downwards.
"""

let explorationHelpInstructions =
"""
You are currently in an Exploration Session menu.
You can find out where you are by dictating: "Where am I?", or gesturing right.
You can here about the significant landmarks in you vicinity by dictating: "What's Around Me?", or gesturing left.
You can hear the most recent instruction by dictating: "Playback", or gesturing downwards.
You can terminate this Exploration session and return to the main menu by dictating: "Terminate Exploration", or gesturing upwards.
"""

let navigationHelpInstructions =
"""
You are currently in an Navigation Session menu.
You can find out where you are by dictating: "Where am I?", or gesturing right.
You can here about the significant landmarks in your vicinity by dictating: "What's Around Me?", or gesturing left.
You can hear the most recent instruction by dictating: "Playback", or gesturing downwards.
You can terminate this Navigation session and return to the main menu by dictating: "Terminate Navigation", or gesturing upwards.
"""

let couldNotInterpretDication =
"""
Your voice command did not match any of the current available commands.
Please dictate: 'Help', to hear a list of the current commands available to you.
"""

let terminationHelpInstructionsP1 =

"""
You are currently being prompted to confirm the termination of your: 
"""

let terminationHelpInstructionsP2 =
"""
 session. Gesture upwards or dictate: 'Confirm', to confirm the termination.
Gesture downwards or dictate: 'Cancel', to cancel the termination and return to your session.
"""

let selectDestinationInstructions =

"""
You are currently being prompted to choose a destination.
You may dictate your destination, or you may use Voice Over
functionality to type your destination into the search bar.
You can also terminate this navigation session by gesturing upwards
or dictating: 'Terminate Navigation'
"""

let alertHelpInstructions =
"""
You have just been notified of an immediate hazard.
To repeat the alert, gesture downwards or dictate - "Playback".
To dismiss the alert, short swipe downwards or dictate - "Confirm".
To hear these instructions again, dictate - "Help"
"""

let selectDestinationStartInstruction = "Dictate or enter a destination or choose from a previously saved location"
