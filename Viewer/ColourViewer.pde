//import processing.net.*;
//import processing.video.*;
//import javax.swing.JOptionPane;
//import javax.swing.JFrame;
import java.net.*;
import java.awt.*;
import java.awt.geom.*;
import java.awt.image.BufferedImage;
import java.awt.image.RenderedImage;
import java.util.Iterator;


ScoreViewer viewer;

int port;
long count;

OSCPortOut sender;
Rectangle monitor;

PFont fontA;

double start_time;
float min_time, max_time;
float set_time, elapsed_time;
float font_point;

PageCapture pdf;
RenderedImage img;

color  cblack, cwhite;



void setup () {

  port = 1200;
  start_time = 0;
  min_time = 0; 
  max_time = 20 * 60;
  set_time = 200; 
  elapsed_time = 0;
  
  Rectangle monitor;

  frameRate(20);  

  GraphicsDevice gd;
  
  GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
  GraphicsDevice[] gs = ge.getScreenDevices();
  // gs[1] gets the *second* screen. gs[0] would get the primary screen
  if (gs.length > 1) {
    gd = gs[1];
  } else {
    gd = gs[0];
  }    
  
  //GraphicsConfiguration[] gc = gs[0].getDefaultConfiguration();//getConfigurations();
  
  monitor = new Rectangle();
  monitor = gs[0].getDefaultConfiguration().getBounds();//gc[0].getBounds();
  
  //frame.setLocation((int)(monitor.width / 2), (int)(monitor.height / 2));
  //frame.setLocation((int)(monitor.x + (monitor.width / 2)), 
  //                  (int)(monitor.y +(monitor.height / 2)));
  frame.setLocation((int) monitor.x, (int) monitor.y);
  frame.setAlwaysOnTop(true);
  
  cblack = #000000;
  cwhite = #FFFFFF;

  pdf = new PageCapture(dataPath("reading.pdf"));
 
  try{

    //addy = InetAddress.getByAddress(b);
    InetAddress addy;
    addy = InetAddress.getByName("255.255.255.255");
    
    OSCPortIn receiver = new OSCPortIn(port);
    sender = new OSCPortOut(addy, port);
    
    viewer = new ScoreViewer(min_time, max_time, millis(), gd, pdf, sender);
    
    OSCListener listener;
    
   listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        //System.out.println("Message received!");
        try {
          set_time = (((Number) message.getArguments()[0])).floatValue();
        } catch (Exception e){
          set_time = min_time;     
        }
        viewer.notifyStart(set_time, false, millis());
     }
    };
    receiver.addListener("/start", listener);
    
   listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        //System.out.println("Message received!");
        try {
         viewer.notifyStop();
        } catch (Exception e){};
      }
     };
    receiver.addListener("/stop", listener);
    
   listener = new OSCListener() {
     public void acceptMessage  (java.util.Date time, OSCMessage message) {
        //System.out.println("Message received!");
        try {
          elapsed_time = (((Number) message.getArguments()[0])).floatValue();
          viewer.notifyTime(elapsed_time);
          //master = false;
        } catch (Exception e){};
      };
     };
    receiver.addListener("/time", listener);



    receiver.startListening();
  
  } catch (Exception e){ 
    viewer = new ScoreViewer(min_time, max_time, millis(), gd, pdf, null);
  };

  GraphicsConfiguration grc = gd.getDefaultConfiguration();
  javax.swing.JFrame f = new javax.swing.JFrame(/*"Score"*/grc);
  f.removeNotify();
  f.setUndecorated(true);
  f.addNotify();
  f.add(viewer);
  
  int xoffs = grc.getBounds().x;
  int yoffs = grc.getBounds().y;
  f.setLocation(xoffs, yoffs);

  f.pack();
  f.setVisible(true);
  background(1);
  
  size(480, 120);
  
  font_point = 16;
  fontA = createFont("Verdana", font_point);

  /*
  JButton startButton = new JButton("Start");
  startButton.setText("Start");
  startButton.setToolTipText("Start showing the Score");
  startButton.setActionCommand("start");
  startButton.addActionListener( this );
  add( startButton );
  */  
}
/*
public void actionPerformed(ActionEvent ae) {
  if ( "start".equals( ae.getActionCommand() ) ) {
    System.out.println("start command received");
    viewer.notifyStart(0, true);
    try {
      Object args[] = new Object[1];
      args[0] = set_time;
      OSCMessage msg = new OSCMessage( "/start", args);
      sender.send(msg); 
      master = true;
    } catch (Exception e) { }    
  } else {
    super.actionPerformed(ae);
  }
}
*/


void draw() {
 
 background(1);
 fill(cwhite);
 rect(0, 0, width, height);
 fill(cblack);
 textFont(fontA);
 textAlign(CENTER);
 textSize(font_point);
 if (! viewer.isRunning()) {
   text("Click to Start", 200, 100); 
 } else {
   text("Running", 200, 30);
   text("Click when the piece is over", 200, 100);
 }
 //viewer.repaint();
 viewer.updateTime(millis());

}

void mouseClicked() {
  
  System.out.println("click");
  viewer.toggle(millis());
  viewer.repaint();
  if (! viewer.isRunning()) {
    exit();
  }
}



