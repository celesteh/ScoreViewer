ScoreViewer
===========

Two related processing apps for timekeeping in performance. 

# Timer

The Timer half is a networked stopwatch, useable for performance. It counts up or down in either seconds or minutes:seconds.
There is one XML file per piece. The file specifies the title, the durations of each section, how many milliseconds per 'second', and the colours used to display the time. It is possible to demarcate section changes with colour changes.

The computer that starts the timer acts as the 'master' computer and sends out broadcast messages of OSC saying to start, stop, or go on to the next piece or return to a previous one. When the clock is tunning, it also sends out it's version of the current time, to prevent drift.

To use this with multiple computers, all of them should be on the same wifi network or LAN. It's fine to use ad hoc networks for this purpose.

## OSC Control

The program listens on port 1200 for OSC messages sent from an external control program or device. These commands should be sent to only one computer in the network. The computer that receives them will become the master computer. The messages are:

* `/remotestart` - starts the timer
* `/remotestop` - stops the timer
* `/remotenext` - move to the next piece in the order
* `/remoteprev` - move to the previous piece in the order

## Order of Pieces

The order is set in the [order.xml](Timer/data/order.wml) file. The id of each piece is the same as the name of their xml file, minus the .xml extension

## XML for tming files

See [color.xml](Timer/data/color.xml) for a good example of a timing file that uses colourful queues.

`<type>` can be `seconds` or `minutes`.
Optional specifications in type are:
* `countdown ="1"` - count down in time.
* `flash="1"` - If your piece has multiple sections, invert the colours for two seconds on every section change.

Each setion is specified in a `<timing>` tag. These must include:
* `start="N"` - where N is the time in seconds.
* `end="N"` - where N is the end of the section in seconds.

Every timing section should start one second after the end of the previous section.

Optional `<timing>` parameters are:
* `bgcolour="N"` and `fgcolour="N"`. Colours may be specified as `#FFFFFF` or 
  - white
  - black
  - red
  - orange
  - yellow
  - green
  - blue
  - purple
  - pink
  - periwinkle
* `rehearsalMark="A"` where A is the mark
* `speed="1000"` Specify the number of actual miliseconds for each "second"

## Issues and future plans

* Macintoshes seem to be having issues with broadcast messages. 
* Future plans include building in support for OSCGroups. 
* A GUI to set the order is under development. 
* A GUI for creating timings for each pice will also be developed eventually.

# Viewer

This part of the project is extremely neglected. The idea is that the viewer would sync to the timer and could be attached to a projector.  
This did work six years ago, but no effort has been made since to keep it going. The OSC syntax has not changed, so hypothetically, it may still work.


