//
//  SpeechServicePhrases.swift
//  HCI_Prototype
//
//  Created by Zach Fogg on 12/7/21.
//

import Foundation

let appStartInstructions: String =
    """
    Double tap anywhere to start dictation.
    Say 'Help' to hear the current possible commands and gestures.
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
Swipe up or dictate. 'Confirm'. to confirm cancelation.
Swipe down or dictate. 'Return to Navigation'. to return to navigation
"""


let explorationCancelationPrompt =
"""
Are you sure that you want to end your exploration session?
Swipe up or dictate: 'Confirm'. To confirm cancelation.
Swipe down or dictate: 'Return to Exploration'... To return to exploration
"""


let startHelpInstructions =
"""
You are currently at the start menu.
You can start a navigation session by dictating "Start Navigation" or gesturing right.
You can start an exploration session by dictating "Start Exploration" or gesturing left.
You can hear the most recent instruction by dictating "Playback" or gesturing down.
"""


let couldNotInterpretDication =
"""
Your voice command did not match any of the current available commands.
Please dictate: 'Help', to hear a list of the current commands available to you.
"""
