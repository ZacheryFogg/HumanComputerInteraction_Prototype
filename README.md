# HumanComputerInteraction_Prototype

Instructions for using UI: 

Although the audio output will instruct you on this upon UI startup: 

To gesture with the touchscreen (mouse input) click and hold for approximately 1 second (the word "vibrate" will appear in the console 
to demonstrate the intent to give haptic touch) and swipe in a direction: up, down, left, right - you should NOT release the click in between the longpress and the gesture. Sometimes a gesture will produce no actions in a context. 

To dictate a voice command, double tap anywhere, voice a command, wait 2 seconds, the UI will automatically parse and perform an action if 
your command matches any of the primitive commands. The possible commands for a context can be heard by dictating 'help' or by looking at the
list of valid commands (this written list is just there for demonstration purposes - the information will be given in audio output format)





Notes about the UI: 

We were not able to implement integration with VoiceOver in the simulator so the "Destination Selection" view is very lack luster. Long pressing and not gesturing will just result in the selection of "Los, Angeles" from the menu. 

'Help' outputs are not added to playback as this could crowd important information that is not repeatable

Notes about implementation: 

If I had more time to spend on this Prototype I would abstract the gesture recognizing logic and the voice command overlay logic out to individual services so that all view could share and configure one instance: they currently all instantiate there own instances of each ... which is unecessary as only one view is recieving input at a time. 
