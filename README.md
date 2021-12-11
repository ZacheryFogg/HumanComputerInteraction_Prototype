# HumanComputerInteraction_Prototype

Final Project for CS 228: Human Computer Interaction

Instructions for using UI: 

Although the audio output will instruct you on this upon UI startup: 

To gesture with the touchscreen (mouse input) click and hold for approximately 1 second (the word "vibrate" will appear in the console 
to demonstrate the intent to give haptic touch) and swipe in a direction: up, down, left, right - you should NOT release the click in between the longpress and the gesture. In some contexts, a gesture will not be associated to any action.

To dictate a voice command, double tap anywhere, voice a command, wait 2 seconds in silence, the UI will automatically parse and perform an action if 
your command matches any of the primitive commands. The possible commands for a context can be heard by dictating 'help' or by looking at the
list of valid commands (this written list is just there for demonstration purposes - the information will be given in audio output format).

For this prototype, voice command recognition it primitive, and relies on a few manually specified keyworks for each action. For example, the only keywords that can start a navigation session are the words ["navigate","navigation"], which can be simplified to the splice : "navigat". If we had more resources, a voice command would be analyzed for underlying sentiment rather than simple keywords, similar to how an AI voice assistant can set an alarm for tomorrow morning at 7:00am, in a variety of ways. 

Any visual UI element is not associated with any functionality for the target user. If the UI was a black screen, it would function in the same way as it currently does (save for the destination selection process), as voice commands and gestures are the only ways to interact with the UI. 

I demonstrate all areas of the UI in this 'Video ReadMe' on youtube, so skim that for a full walkthrough of functionality, but in any view, simply double tap and say "help" to be notified of the current affordances, and what you are expected to do in the current view. 

Notes about the UI: 

We were not able to implement integration with VoiceOver in the simulator so the "Destination Selection" view is very lack luster. Long pressing and not gesturing will just result in the selection of "Los, Angeles" from the menu. 

'Help' outputs are not added to recent audio playback as this could crowd important information that is not repeatable

Notes about implementation: 

If I had more time to spend on this Prototype, I would abstract the gesture recognizing logic and the voice command overlay logic out to individual services so that all views could share and configure one instance: they currently all instantiate there own instances of each ... which is unecessary as only one view is recieving input at a time. 
