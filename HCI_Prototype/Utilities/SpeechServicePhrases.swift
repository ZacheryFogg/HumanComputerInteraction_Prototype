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
