import processing.net.*;
//import processing.video.*;
//import processing.oscP5.*;
import javax.swing.JOptionPane;
import javax.swing.JFrame;
import java.net.*;
import java.util.Iterator;
import java.io.File;
// kill all clickability
int port = 1200;

 //byte [] b = {(byte)192, (byte)168, (byte)2, (byte)10};
 InetAddress addy;
 OSCPortOut sender;

PFont fontA;

double start_time = 0;
//float min_time = 0, max_time = 890;
float set_time = 0, elapsed_time = 0;
float font_point;
Boolean running = false;
Boolean blank = false;
Boolean master = false;
Boolean cntrl = false;
TimingReader times;
//  String title;
boolean ready;
Pieces order;

double last_time;
float the_time;
double piece_time;
double real_time;
int speed = 0;

double last_ping;

color cred, corange, cyellow, cgreen, cblue, cpurple, cblack, cwhite;


void setup() {
  //myScale = 1; myMax = 5; count = 0;
  

  
//times = new TimingReader("Timings/color.xml");
//advance();

  size(displayWidth, displayHeight);
  background(0);
  
  frameRate(20);
  
  font_point = (displayWidth /5 * 1.5);
  
  fontA = createFont("Verdana", font_point); 
  textFont(fontA); 
  textAlign(CENTER);
  textSize(font_point);




  background(0);
 



  try{

    addy = InetAddress.getByName("255.255.255.255");
    
    OSCPortIn receiver = new OSCPortIn(port);
    sender = new OSCPortOut(addy, port);
    
    // control from remote phone or device
        OSCListener listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        System.out.println("Start Message received!");
        master = true;
        try{ 
          OSCMessage msg = new OSCMessage( "/start");
          sender.send(msg);
        } catch (Exception e) {};
        
        startTimer();
     };
    };  
    receiver.addListener("/remotestart", listener);

     listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        System.out.println("Stop message received!");
        master = true;
        try {
         running = false;
         //master = false;
         OSCMessage msg = new OSCMessage( "/stop");
         sender.send(msg);
        } catch (Exception e){};
      };
     };
    receiver.addListener("/remotestop", listener);

   listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        System.out.println("Next message received!");
        master = true;
        try {
         advance();        
         //try{ 
          OSCMessage msg = new OSCMessage( "/next");
          sender.send(msg);
        //} catch (Exception e) {};

        } catch (Exception e){};
      };
     };
    receiver.addListener("/remotenext", listener);

    listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        System.out.println("Next message received!");
        master = true;
        try {
         prev();
          OSCMessage msg = new OSCMessage( "/prev");
          sender.send(msg);

        } catch (Exception e){};
      };
     };
    receiver.addListener("/remoteprev", listener);


    // communication between display computers
    
    
    listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        System.out.println("Start Message received!");

      if (! master) {
       startTimer();
      }
     };
    };  
    receiver.addListener("/start", listener);

   listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        System.out.println("Stop message received!");
        try {
         running = false;
         master = false;
        } catch (Exception e){};
      };
     };
    receiver.addListener("/stop", listener);

   listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        System.out.println("Next message received!");
        try {
          if (! master) {
             advance();
          }
        } catch (Exception e){};
      };
     };
    receiver.addListener("/next", listener);

    listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        System.out.println("Next message received!");
        try {
          if (! master) {
             prev();
          }
        } catch (Exception e){};
      };
     };
    receiver.addListener("/prev", listener);

  
  listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        //System.out.println("Message received!");
        try {
          elapsed_time = (((Number) message.getArguments()[0])).floatValue();
          running = true;
          //master = false;
        } catch (Exception e){};
      };
     };
    receiver.addListener("/time", listener);

   listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
       String id;
       if (! master) {
        try {
          running = false;
          if(order != null) {
            order.hide();
            order = null;
          }
          
          id = "Timings/" + (((String) message.getArguments()[0])) + ".xml";
          System.out.println("id Message received! " + id);

          times = new TimingReader(id);
        } catch (Exception e){};
       };
      };
     };
    receiver.addListener("/id", listener);


   listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        System.out.println("Die message received!");
        exit();
        try {
         running = false;
         master = false;
        } catch (Exception e){};
      };
     };
    receiver.addListener("/die", listener);


    receiver.startListening();
  } catch (Exception e){};


  //JFrame frame = new JFrame("Order of Pieces");
    //frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    //frame.setContentPane((new FileListManager()));
    //frame.add(new FileListManager());
    //frame.setSize(260, 200);
    //frame.setVisible(true);
    /*
    ready = false;
    

  
          times = new TimingReader(frame.getOrder(index));
        min_time = times.start;
        max_time = times.end;

        title = times.title;
  */
   // frame.setAlwaysOnTop(true); 
  //order = new Pieces( new String[] {"tacet.xml", "bron.xml", "tacet.xml", "zucker.xml", "tacet.xml", "ashley.xml", "tacet.xml"});
  order = new Pieces( new String[] {"schooltime.xml" });
  advance();
}




void draw() {
  
  long disp_time;
  //float the_time;
  color fillc;
  
  boolean showTitle = false;
  
  TimeElement curr;
  
  
  // This is the wrong place to put this, but this is the looping part of the thread
  if (millis() - last_ping > 3000) { //every 3 seconds
    last_ping = millis();
         try{
           OSCMessage msg = new OSCMessage( "/alive"); //the hope is that this keeps my wifi from sleeping
           System.out.println("alive");
            sender.send(msg);
          } catch (Exception e) {}  
  }

  if( times != null) {
     if (times.seconds) {
            font_point = (displayWidth /3 * 1.5);
          } else {
            font_point = (displayWidth /5 * 1.5);
          }    
  } else {
    font_point = (displayWidth /5 * 1.5);
  }
  
  if ((order == null || order.ready()) && (! blank)) {
    
    //System.out.println("(order == null || order.ready()) && (! blank)");
    if(times == null ){
      advance();
    }
    
    //System.out.println("Running is " + running);
    if (running && (set_time >= 0)) {
    
    
      //display the time
      //System.out.println("display the time");
    
       textSize(font_point);
     

     
       // what's the time, Mr Wolf?
       //if (curr != null) {
       //  disp_time = calculateTime(curr.speed);
       //} else {
       //  disp_time = calculateTime(1000);
       //}
       
       disp_time = calculateTime(speed);

       // alert the network
       if (master) {
         try{
           Object args[] = new Object[1];
           args[0] = disp_time;//the_time;
           OSCMessage msg = new OSCMessage( "/time", args);
            sender.send(msg);
            System.out.println("/time " + disp_time);
          } catch (Exception e) {}
       }
 

    

    
      curr = times.at(disp_time);
      
      
      if ( curr != null) {
      
        speed = curr.speed;
        fill(curr.background);
        rect(0, 0, displayWidth, displayHeight);
        fill(curr.foreground);    
    
        textSize(font_point);
        if (! blank) {
          text(formatTime(disp_time,times.seconds, times.mod, curr), 
            (displayWidth * 1.45)/3, displayHeight * 0.75);
        }
      } else {
        
        running = false;
        blank = true;
        if((order != null) && order.hasNext()){
          //advance(); //les
          // we're advancing twice sometimes, sotemporaarily removing this line
          showTitle = true;
        }
      }

    } else { // display the title
      showTitle = true;
    };
    
    if (showTitle) {
      running = false;
      if (times != null) {
        float scale = 1;
    
        fill(#000000);
        rect(0, 0, displayWidth, displayHeight);
        fill(#ffffff);
    
        textSize(font_point / 2);
        //if (textWidth(times.title) > displayWidth) {
          textSize(font_point);
          scale = displayWidth / textWidth(times.title);
          textSize(font_point* scale);
          text(times.title, displayWidth /2,//(displayWidth * 2/* * 1.45*/)* scale, 
            displayHeight * 0.8);
        //}
      } else {
        //if (times != null) {
        // text(times.title, (displayWidth * 1.45)/7, displayHeight * 0.8);
        //}
      }
    
    }
  }

}


void startTimer () {
  
  if (master) {
    try {
      OSCMessage msg = new OSCMessage( "/start");
      sender.send(msg);
      println("sent");
    } catch (Exception e){};
  }
  
  
  println("start");
       start_time = millis();
      if (times != null) {
        if (set_time < times.start) {
          set_time = times.start;
          last_time = 0;
        }
        //set_time = -1;
        last_time = start_time;
        piece_time = set_time;
        println(piece_time);
        real_time = start_time;//millis();
      } 
      running = true;
 }
   

void advance(){
  advance(true);
}

void prev(){
  advance(false);
}

void advance (boolean forward) {
  
  blank = true;
  running = false;
  
  if ((order != null) && order.ready() && (order.hasNext()) || (! forward)) {
    if (forward) {
      times = (TimingReader) order.next(); 
    } else {
      times = (TimingReader) order.prev(); 
    }
    
    
    if (master && (times.id != null)) {
       try {
        Object args[] = new Object[1];
        args[0] = times.id;
        OSCMessage msg = new OSCMessage( "/id", args);
        sender.send(msg); 
        master = true;
       } catch (Exception e) { }     
      
    }
          
     if (times.seconds) {
            font_point = (displayWidth /3 * 1.5);
          } else {
            font_point = (displayWidth /5 * 1.5);
          }    
     //startTimer();
  }
  blank = false;
}


void keyPressed() {
  
  if (key == 'q') { exit(); }  
  if (key == 's') { advance(); }
  if (key == 'n') { advance(); }
  if (key == 'p') { prev(); }
  if (key == ' ') { master =true; startTimer(); }
  
}


private long calculateTime (int speed) {
  long disp_time;
  //float the_time;
  float tick;
  double elapsed;
  long multiples;
  
  //println("calculateTime()");
  
  if (set_time < times.start) {
      set_time = times.start;
      last_time = set_time;
      piece_time = times.start;
  }

 
  
  real_time = millis(); 
  elapsed =  real_time - last_time; 
  
  
  if (speed < 100) { speed = 1000; } // speed is the number of miliseconds in a 'second'

  // how many milliseconds since the clock started?
  //the_time = (((float)(millis() - start_time)) / speed) +set_time;
  tick = (float)(elapsed / speed);
  piece_time += tick;
  //println (piece_time);
  disp_time = (long) Math.floor(piece_time);     
  last_time = real_time;
  
  if (! master) {
    // if we're behind of the master clock, then catch up to them
       if (disp_time < elapsed_time) {
         disp_time = (long) Math.floor(elapsed_time);
       }
  }
  
  if (times.countby > 0){
    //disp_time = (int) disp_time / times.countby;
    multiples = (long) disp_time / times.countby;
    disp_time = multiples * times.countby;
  }

  
  // have we gotten to the maximum time?
  if(disp_time > times.end) { 
    disp_time = (long) Math.floor(times.end); 
    blank = true; 
    running = false; 
    advance();  // go to next piece
    blank = false;
  }
  
  
  
  return disp_time;
  
  
}


private String formatTime(long disp_time, boolean in_seconds, boolean mod, TimeElement curr) {
  String clockTime;
  int minutes;
  int seconds;
  
     // format
     
  if (mod && (curr.start_time > 0)) {
    disp_time %= curr.start_time;
  }


  disp_time = curr.mapTime(disp_time);
 

     
     
  if (! in_seconds) {
    
     minutes = (int) Math.floor(disp_time / 60);
     seconds = (int) (disp_time % 60);
     
     clockTime = Integer.toString(minutes) + ":";
     if (seconds < 10) {
       clockTime += "0"; // pad the seconds
     }
     clockTime += Integer.toString(seconds);  
  } else {
    
    clockTime = Integer.toString((int) Math.floor(disp_time));
  }
  return clockTime;
}
