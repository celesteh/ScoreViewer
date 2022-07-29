import processing.net.*;
//import processing.sound.*;
//import processing.video.*;
//import processing.oscP5.*;
import javax.swing.JOptionPane;
import javax.swing.JFrame;
import java.net.*;
import java.util.Iterator;
import java.io.File;
import java.util.*;
//import http.*;

//SimpleHTTPServer server;
// web support forthcoming

// kill all clickability
int port = 1200;

 //byte [] b = {(byte)192, (byte)168, (byte)2, (byte)10};
 
 //OSCPortOut sender;
 List <OSCPortOut> known;
 OSCPortOut helper;

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

TimeElement previous = null;

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

    InetAddress broadcast = InetAddress.getByName("255.255.255.255");
    known = new ArrayList<OSCPortOut>();
    InetAddress idEcho = InetAddress.getByName("10.42.0.1");
    helper = new OSCPortOut(idEcho, 57120);
    
    OSCPortIn receiver = new OSCPortIn(port);
    OSCPortOut sender = new OSCPortOut(broadcast, port);
    
    known.add(sender);
    
    // manage known identities
     OSCListener listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        //System.out.println("ID Message received!");
        try{
          // get the data from the message
          Object[] args = message.getArguments();
          String remoteIP = (String) args[0];
          int remotePort = (int)Math.round((Float)args[1]);
          boolean found = false;
          OSCPortOut item;
          // See if the peer is already known
          ListIterator<OSCPortOut> itr=known.listIterator();    
          while(itr.hasNext() && (!found)){    
            item = itr.next();
            if(item.toString().equals(remoteIP)){
              found = true;
            };
          };
          if(! found) { // add them if not
            InetAddress newPeer = InetAddress.getByName(remoteIP);
            known.add(new OSCPortOut(newPeer, remotePort));
          }
          
        } catch (Exception e) {};
     };
    };  
    receiver.addListener("/ip", listener);
    
    
    // control from remote phone or device
     listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        System.out.println("Start Message received!");
        master = true;
        try{ 
          OSCMessage msg = new OSCMessage( "/start");
          //sender.send(msg);
          broadcast( msg);
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
         //sender.send(msg);
         broadcast( msg);
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
          //sender.send(msg);
          broadcast( msg);
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
         nextq();        
         //try{ 
          OSCMessage msg = new OSCMessage( "/nextq");
          //sender.send(msg);
          //broadcast( msg);
        //} catch (Exception e) {};

        } catch (Exception e){};
      };
     };
    receiver.addListener("/remotenextq", listener);


    listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        System.out.println("Prev message received!");
        master = true;
        try {
         prev();
          OSCMessage msg = new OSCMessage( "/prev");
          //sender.send(msg);
          broadcast( msg);
        } catch (Exception e){};
      };
     };
    receiver.addListener("/remoteprev", listener);

    listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        System.out.println("Prev message received!");
        master = true;
        try {
         prevq();
          OSCMessage msg = new OSCMessage( "/prevq");
          //sender.send(msg);
          //broadcast( msg);
        } catch (Exception e){};
      };
     };
    receiver.addListener("/remoteprevq", listener);



    listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        System.out.println("Index message received!");
        Object[] args = message.getArguments();
        Integer index = Math.round((Float) args[0]);
        master = true;
        try {
         index(index);
          OSCMessage msg = new OSCMessage( "/index", args);
          //sender.send(msg);
          broadcast( msg);
        } catch (Exception e){};
      };
     };
    receiver.addListener("/remoteindex", listener);


    // communication between display computers
 
        listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        System.out.println("Index message received!");
        Object[] args = message.getArguments();
        Integer index = (Integer)  args[0];//;Math.round((Float)args[0]);
        //master = true;
        try {
         index(index);
        } catch (Exception e){};
      };
     };
    receiver.addListener("/index", listener);

    
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
        System.out.println("Prev message received!");
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
        System.out.println("Next message received!");
        try {
          if (! master) {
             nextq();
          }
        } catch (Exception e){};
      };
     };
    receiver.addListener("/nextq", listener);

    listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        System.out.println("Prev message received!");
        try {
          if (! master) {
             prevq();
          }
        } catch (Exception e){};
      };
     };
    receiver.addListener("/prevq", listener);

  
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
          
          id = (((String) message.getArguments()[0])) + ".xml";
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
  //  frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
  //  frame.setContentPane((new FileListManager()));
    //frame.add(new FileListManager());
    //frame.setSize(260, 200);
    //FileListManager frame = new FileListManager();
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
  //order = new Pieces( new String[] {"schooltime1.xml" });
  order = new Pieces("order.xml");
  advance();
}




void draw() {
  
  long disp_time;
  //float the_time;
  color fillc;
  String text = " ";
  float x, y;
  
  boolean showTitle = false;
  boolean showMark = false;
  boolean showTime = true;
  
  TimeElement curr = null;
  
  
  // This is the wrong place to put this, but this is the looping part of the thread
  if (millis() - last_ping > 3000) { //every 3 seconds
    last_ping = millis();
         try{
           Object args[] = new Object[1];
           args[0] = port;//the_time;
           OSCMessage msg = new OSCMessage( "/ip", args); //the hope is that this keeps my wifi from sleeping
           //System.out.println("alive");
            //sender.send(msg);
            helper.send(msg);
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
            //sender.send(msg);
            broadcast( msg);
            System.out.println("/time " + disp_time);
          } catch (Exception e) {}
       }
 

    

    
      curr = times.at(disp_time);
      
      
      if ( curr != null) {
        
        curr.setTime(disp_time);
        
        showTime = curr.showtime; //(!curr.isCue) && (times.showtime);
        showMark = curr.isCue || times.marks;
        fill(curr.getBackground());
        rect(0, 0, displayWidth, displayHeight);
      
        if(showTime ){
          System.out.println("show time");
          speed = curr.speed;
          //fill(curr.background);
          //rect(0, 0, displayWidth, displayHeight);
          fill(curr.getForeground());    
          
          if (showMark) {
            font_point = (displayWidth /10 * 1.5);
            x = (displayWidth * 1.45)/3;;
            y = displayHeight * 0.85;//displayHeight - (textAscent());
          } else {
            x = (displayWidth * 1.45)/3;
            y = displayHeight * 0.75;
          }
      
          textSize(font_point);
          if (! blank) {
            text(formatTime(disp_time,times.seconds, times.mod, curr), 
              x, y);
          }
        } else {
          showMark = true;
        }
        if (showMark) {
          text = curr.rehearsalMark;
          System.out.println("show mark");
        }
        
      } else {
        
        running = false;
        blank = true;
        if((order != null) && order.hasNext()){
          //advance(); //les
          // we're advancing twice sometimes, sotemporaarily removing this line
          showTitle = true;
          text = times.title;
        }
      }

    } else { // display the title
      showTitle = true;
      text = times.title;
    };
    
    if (showTitle || showMark) {
      //running = false;
      if (times != null) {
        float scale = 1;
        int div = 1;
        
        if (showTime) { div = 2;};
        font_point = (displayWidth /5 * 1.5);
        textSize(font_point);
        scale = displayWidth / textWidth(text);
        textSize(font_point* scale);
    
        if ((!running)||(curr == null) ) {
          fill(#000000);
          rect(0, 0, displayWidth, displayHeight);
          y = displayHeight * 0.8;
        } else {
          //fill(curr.background);
           if (showTime && (textAscent() > (displayHeight / 2))){
             //textSize(font_point);
             font_point = font_point * scale;
             scale = (displayHeight ) / (textAscent() * 2);
             textSize(font_point* scale);   
          }
         y = textAscent() +1;//0;//displayHeight - (textAscent() - 1);
        }
        //rect(0, 0, displayWidth, displayHeight);
        
        if ((!running) || (curr == null) ) {
          fill(#ffffff);
        } else {
          fill(curr.getForeground()); 
        }
        
        
    
        //textSize(font_point / 2);
        //if (textWidth(times.title) > displayWidth) {
          
          text(text, displayWidth /2,//(displayWidth * 2/* * 1.45*/)* scale, 
            y);
        //}
      } else {
        //if (times != null) {
        // text(times.title, (displayWidth * 1.45)/7, displayHeight * 0.8);
        //}
      }
    
    }
  }
  
  if (master) {
    if (curr != null){
      if (previous != curr) {
        if (curr.audioCue != null){
          if (curr.audioCue.length() > 0 ) {
            System.out.println("play sound");
            playSound(curr.audioCue);
          }
        }
      }
    }
  }
  previous = curr;

}

void broadcast(OSCMessage msg){
  try{
      ListIterator<OSCPortOut> itr=known.listIterator();    
      while(itr.hasNext()){    
        itr.next().send(msg);
      }

  } catch (Exception e) {};

}


void startTimer () {
  
  if (master) {
    try {
      OSCMessage msg = new OSCMessage( "/start");
      //sender.send(msg);
      broadcast( msg);
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
  if(master){
         try {
        Object args[] = new Object[1];
        args[0] = order.getIndex();
        OSCMessage msg = new OSCMessage( "/index", args);
        //sender.send(msg); 
        broadcast( msg);
       } catch (Exception e) { }     
  }
}

void prev(){
  advance(false);
    if(master){

         try {
        Object args[] = new Object[1];
        args[0] = order.getIndex();
        OSCMessage msg = new OSCMessage( "/index", args);
        //sender.send(msg); 
        broadcast( msg);
       } catch (Exception e) { }     
    }
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
        //sender.send(msg); 
        broadcast( msg);
        master = true;
       } catch (Exception e) { }     
       try {
        Object args[] = new Object[1];
        args[0] = order.getIndex();
        OSCMessage msg = new OSCMessage( "/index", args);
        //sender.send(msg); 
        broadcast( msg);
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

void index(Integer index){
  blank = true;
  running = false;
  
  if ((order != null) && order.ready()) {
    times = (TimingReader) order.index(index);
    
    if (times != null){
     if (master && (times.id != null)) {
       try {
        Object args[] = new Object[1];
        args[0] = times.id;
        OSCMessage msg = new OSCMessage( "/id", args);
        //sender.send(msg);
        broadcast( msg);
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
  }
  blank = false;
}     

void nextq(){advanceq(true);}
void prevq(){advanceq(false);}

void advanceq(boolean forward){
  
  double piece_time = getTime(speed);
  piece_time = times.advance(piece_time, forward);
  setTime(piece_time); // no fix this
  
  String tag;
  if(master) {
    if (forward){
      tag = "/nextq";
    } else {
      tag = "/prevq";
    };
         try {
        Object args[] = new Object[1];
        args[0] = order.getIndex();
        OSCMessage msg = new OSCMessage( tag);
        //sender.send(msg); 
        broadcast( msg);
        master = true;
       } catch (Exception e) { }     
  }
}
  
  

void keyPressed() {
  
  if (key == 'q') { exit(); }  
  if (key == 's') { advance(); }
  if (key == 'n') { advance(); }
  if (key == 'p') { prev(); }
  if (key == '-') { prevq(); }
  if (key == '_') { prevq(); } // common mistype
  if (key == '+') { nextq(); }
  if (key == ' ') { master =true; startTimer(); }
  
}

private void setTime(double time){
   last_time = millis(); 
   piece_time = time; 
}

private long getTime(int speed){
  //long new_time; 
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
  //disp_time = (long) Math.floor(piece_time);     
  last_time = real_time;
  
  return((long)piece_time);

}

private long calculateTime (int speed) {
  long disp_time;
  //float the_time;
  //float tick;
  //double elapsed;
  long multiples;
  
  //println("calculateTime()");
  /*
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
  */
  
  disp_time = (long) Math.floor(this.getTime(speed));
  
  
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

private void playSound(String path){
  
  //SoundFile file = new SoundFile(this, path);
  //file.play();
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
