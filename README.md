ScoreViewer
===========

Two related processing apps for timekeeping in performance. 

# Timer

The Timer half is a networked stopwatch, useable for performance. It counts up or down in either seconds or minutes:seconds.
There is one XML file per piece. The file specifies the title, the durations of each section, how many milliseconds per 'second', and the colours used to display the time. It is possible to demarcate section changes with colour changes.

The computer that starts the timer acts as the 'master' computer and sends out broadcast messages of OSC saying to start, stop, or go on to the next piece or return to a previous one. When the clock is tunning, it also sends out it's version of the current time, to prevent drift.

It also listens to slightly different OSC messages on port 1200, so it can be controlled by a different OSC app. The computer that receives those messages becomes the master.

Currently concert order is set in code, which is not ideal. Another beneficial innovation would be an interface for creating XML files, to make this more accessible to non-technical users.  Also, macintoshes seem to be having issues with broadcast messages. Future plans include building in support for OSCGroups.

# Viewer

This part of the project is extremely neglected. The idea is that the viewer would sync to the timer and could be attached to a projector.  
This did work six years ago, but no effort has been made since to keep it going. The OSC syntax has not changed, so hypothetically, it may still work.
