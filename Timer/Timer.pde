import processing.net.*;
import processing.video.*;
//import processing.oscP5.*;
import javax.swing.JOptionPane;
import javax.swing.JFrame;
import java.net.*;


int port = 1200;

 //byte [] b = {(byte)192, (byte)168, (byte)2, (byte)10};
 InetAddress addy;
 OSCPortOut sender;

PFont fontA;

double start_time = 0;
float min_time, max_time;
float set_time = 200, elapsed_time = 0;
float font_point;
Boolean running = false;
Boolean master = false;
Boolean cntrl = false;


color cred, corange, cyellow, cgreen, cblue, cpurple, cblack, cwhite;


void setup() {
  //myScale = 1; myMax = 5; count = 0;
  min_time = 0; 
  max_time = 20 * 60;


  size(displayWidth, displayHeight);
  background(0);
  
  frameRate(20);
  
  font_point = (displayWidth /5 * 1.5);
  fontA = createFont("Verdana", font_point); 
  textFont(fontA); 
  textAlign(CENTER);
  textSize(font_point);
  
  cred = #FF0000;
  corange = #FF8000;
  cyellow = #FFFF00;
  cgreen = #00FF11;
  cblue = #0000FF;
  cpurple = #A020F0;
  cblack = #000000;
  cwhite = #FFFFFF;


  background(0);
 



  try{

    addy = InetAddress.getByName("255.255.255.255");
    
    OSCPortIn receiver = new OSCPortIn(port);
    sender = new OSCPortOut(addy, port);
    OSCListener listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        //System.out.println("Message received!");
        try {
          start_time = millis();
          set_time = (((Number) message.getArguments()[0])).floatValue();
          if (set_time < min_time){ set_time = min_time;}
          
          running = true;
          master = false;
        } catch (Exception e){set_time = min_time;};
      };
     };
    receiver.addListener("/start", listener);

   listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        //System.out.println("Message received!");
        try {
         running = false;
         master = false;
        } catch (Exception e){};
      };
     };
    receiver.addListener("/stop", listener);

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



    receiver.startListening();
  } catch (Exception e){};

}




void draw() {
  
  long disp_time;
  //float the_time;
  color fillc;
  int minutes, seconds;
  String clockTime;
  
  
  if (running && (set_time >= 0)) {
     textSize(font_point);
     /*
     the_time = (((float)(millis() - start_time)) / 1000) +set_time;
     disp_time = (long) Math.floor(the_time);     

     if (master) {
       try{
         Object args[] = new Object[1];
         args[0] = the_time;
         OSCMessage msg = new OSCMessage( "/time", args);
          sender.send(msg);   
        } catch (Exception e) {}
     
     } else { // not master
       if (disp_time < elapsed_time) {
         disp_time = (long) Math.floor(elapsed_time);
        }
     }
     
     if(disp_time > max_time) { disp_time = (long) Math.floor(max_time);}
     */
    
     // what's the time, Mr Wolf?
     disp_time = calculateTime();

     // alert the network
     if (master) {
       try{
         Object args[] = new Object[1];
         args[0] = disp_time;//the_time;
         OSCMessage msg = new OSCMessage( "/time", args);
          sender.send(msg);   
        } catch (Exception e) {}
     }
 
     // format
     
     minutes = (int) Math.floor(disp_time / 60);
     seconds = (int) (disp_time % 60);
     
     clockTime = Integer.toString(minutes) + ":";
     if (seconds < 10) {
       clockTime += "0"; // pad the seconds
     }
     clockTime += Integer.toString(seconds);
   
     // set background colour
     
     if ( minutes < 5) {
       fillc = cgreen;
     } else {
       if (minutes < 10) { //between 5 and 10
         fillc = cyellow;
       } else {
         if (minutes < 12) { // between 10 and 12
           fillc = cred;
         } else {
           if ((minutes == 12) && (seconds < 30)) { //between 12 and 12:30
             fillc = cred;
           } else {
             if (minutes < 15) { // between 12:30 and 15
               fillc = cblue;
             } else {
               if (minutes < 20) { // between 15 and 20
                 fillc = cpurple;
               } else {
                 fillc = corange;
               }
     }}}}}
 
     
     fill(fillc);
     rect(0, 0, displayWidth, displayHeight);
     
     fillc = cblack;
     //fillc = #ffffff;
     fill(fillc);
     textSize(font_point);
     //System.out.println(clockTime);
     //System.out.println(font_point);
     text(clockTime, (displayWidth * 1.45)/3, displayHeight * 0.7);
     //text(Long.toString(disp_time), (displayWidth * 1.45)/3, displayHeight * 0.8);
     
     //for (int i = 0; i< displayHeight; i++) {
     //  text(clockTime, i, i); 
     //}
    /*
    if (( disp_time % 100) == 99) {
      fill(cblack);
      rect(0, 0, displayWidth, displayHeight);
      fill(cwhite);


    } else {


      switch((int)((disp_time % 100) / 10)) {
        case 0: case 5: 
          fillc = cred; break;
        case 1: case 6:
          fillc = corange; break;
        case 2: case 7:
          fillc = cyellow; break;
        case 3: case 8:
          fillc = cgreen; break;
        case 4: case 9:
          fillc = cblue; break;
      }
      
      fill(fillc);
      rect(0, 0, displayWidth, displayHeight);
      fill(cblack);
    }
    
    text(Long.toString(disp_time), (displayWidth * 1.45)/3, displayHeight * 0.8);
    */
  } else {
    
    fill(cblack);
    rect(0, 0, displayWidth, displayHeight);
    fill(cwhite);
    textSize(font_point/3);
    text("Colour", (displayWidth * 1.45)/7, displayHeight * 0.8);
    
  }
  

}

private long calculateTime () {
  long disp_time;
  float the_time;

  // how many milliseconds since the clock started?
  the_time = (((float)(millis() - start_time)) / 1000) +set_time;
  disp_time = (long) Math.floor(the_time);     

  if (! master) {
    // if we're behind of the master clock, then catch up to them
       if (disp_time < elapsed_time) {
         disp_time = (long) Math.floor(elapsed_time);
       }
  }
  
  // have we gotten to the maximum time?
  if(disp_time > max_time) { disp_time = (long) Math.floor(max_time);}
  
  return disp_time;
  
  
}




void mouseClicked() {
  
  if (! running) {
    set_time = -1;
    String s = (String)JOptionPane.showInputDialog("Start Time");
    
    if ((s.compareToIgnoreCase("q") == 0) || (s.compareToIgnoreCase("quit") == 0)) {
      exit();
    }
    
    try {
      set_time = (float) Integer.parseInt(s);
    } catch (Exception e) { set_time = min_time; }
    
    start_time = millis();
    if (set_time < min_time) { set_time = min_time;}
    
    running = true;
    
    try {
      Object args[] = new Object[1];
      args[0] = set_time;
      OSCMessage msg = new OSCMessage( "/start", args);
      sender.send(msg); 
      master = true;
    } catch (Exception e) { }
 
  } else {
    
    
    try {
      OSCMessage msg = new OSCMessage( "/stop", null);
      sender.send(msg); 
    } catch (Exception e) { }
    running = false;
    master = false;

    Object[] options = {"Stop",
                    "Quit"};
    int n = JOptionPane.showOptionDialog(null,
      "What do you want to do?",
      "Stop",
      JOptionPane.YES_NO_OPTION,
      JOptionPane.QUESTION_MESSAGE,
      null,     //do not use a custom Icon
      options,  //the titles of buttons
      options[0]); //default button title
      
    if (n == JOptionPane.NO_OPTION) { exit(); }
  }
}


void keyPressed() {
  
  if (key == 'q') { exit(); }  
}
