/*
import processing.net.*;
import processing.video.*;
import javax.swing.JOptionPane;
import javax.swing.JFrame;
import java.net.*;
import java.awt.*;
import java.awt.geom.*;
import java.awt.image.BufferedImage;
import java.awt.image.RenderedImage;
import java.util.Iterator;
*/

public class ScoreViewer extends javax.swing.JPanel implements Runnable{
  
  Rectangle monitor;
  Iterator pdf;
  float font_point;
  PFont numfont;
  BufferedImage img;
  BufferedImage nextImg;
  long count;
  OSCPortOut sender;
  float min_time;
  double start_time, current_time;
  boolean running;
  boolean master;
  float set_time, elapsed_time;
  java.awt.image.BufferedImageOp imgFilter;
  float max_time;
  color  cblack, cwhite;
  java.awt.Font font;
  Rectangle2D numBounds;
  Color foregroundc, backgroundc;

  
  public ScoreViewer (float minTime, float maxTime, double startTime, 
                      GraphicsDevice gd, Iterator pages, OSCPortOut oscout) {

    GraphicsConfiguration[] gc = gd.getConfigurations();
  
    monitor = new Rectangle();
    monitor = gc[0].getBounds();
   
  
    println(monitor.x + " " + monitor.y + " " + monitor.width + " " + monitor.height);
    //size(monitor.width, monitor.height);
  
  //size(displayWidth, displayHeight); // update this
    setPreferredSize(new java.awt.Dimension(monitor.width, monitor.height));
    setLocation(monitor.x, monitor.y);
    //setAlwaysOnTop(true); //update this
    //background (0);
    //frameRate(20);

    font_point = (monitor.width /3 * 1.5) /8;
    //numfont = createFont("Verdana", font_point); 
    //textFont(numfont); 
    //textAlign(CENTER);
    //textSize(font_point);
    
    pdf = pages;
    nextImg();

    count = 0;
    min_time = minTime;
    max_time = maxTime;
    start_time = startTime;
    
    sender = oscout;
    
 
    cblack = #000000;
    cwhite = #FFFFFF;
    foregroundc = Color.white;
    backgroundc = Color.black;
   
     font = new java.awt.Font("Verdana", java.awt.Font.PLAIN, (int)font_point);
     

  }
  
  public java.awt.Dimension getPreferredSize() {
    
    return new java.awt.Dimension(monitor.width, monitor. height);
  }
  
  
  public void notifyStart(float setTime, boolean isMaster, long startTime) {
  
      start_time = startTime;
      set_time = setTime;
      
      if (set_time < min_time){ set_time = min_time;}
      
      if (! running) {
        nextImg();
       }
   
       running = true;
       master = isMaster;
       if (sender == null){
         master = false;
       }
       
       if (master) {
         try {
           Object args[] = new Object[1];
           args[0] = 0; //set_time;
           OSCMessage msg = new OSCMessage( "/start", args);
           sender.send(msg); 
           master = true;
         } catch (Exception e) {
           master = false;
         }
       }
  }
  
  public void notifyStop() {
    try {
      OSCMessage msg = new OSCMessage( "/stop", null);
      sender.send(msg); 
    } catch (Exception e) { }

    running = false;
    master = false; 
  }
  
  public void notifyTime(float elapsed) {
    elapsed_time = elapsed;
    running = true;
  }
  
  
  void init () {


    //super.init();  
  }


  public void run() {
  }
  
  
  public void paintComponent (java.awt.Graphics g) {
  
    long disp_time;
    float the_time;
    color fillc;
    String timeStr;

    super.paintComponent(g); 
    
    //System.out.println("painting");

    Graphics2D g2 = (Graphics2D) g;
    //background (0);
    //fill(cblack);
    //rect(0, 0, monitor.width, monitor.height);
    //fill(cwhite);
    g2.setBackground(backgroundc);
    g2.setPaint(backgroundc);
    g2.fill(new Rectangle(this.getPreferredSize()));

    if (running && (set_time >= 0)) {
      /*
      textSize(font_point);
      the_time = (((float)(current_time - start_time)) / 1000) +set_time;
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
      disp_time = calculateTime();
      timeStr = formatTime(disp_time);
      if (master) {
        try{
           Object args[] = new Object[1];
           args[0] = disp_time;//the_time;
           OSCMessage msg = new OSCMessage( "/time", args);
           sender.send(msg);   
         } catch (Exception e) {}
      }
        
      if (advance(disp_time)) {    
        img = /*(RenderedImage)*/ nextImg();
      }

  
      g2.drawRenderedImage (img, new AffineTransform());
      g2.setPaint(foregroundc);
      g2.setFont(font);
      //timeStr = Long.toString(disp_time);
      numBounds =  font.getStringBounds(timeStr, g2.getFontRenderContext());
      g2.drawString(timeStr, ///*(monitor.width * 6.45)/8, monitor.height * 0.8*/
                    (int)(monitor.width-numBounds.getWidth()), (int)( monitor.height-numBounds.getHeight())); 
  
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

  private String formatTime (long disp_time) {
    int minutes, seconds;
    String clockTime;
  
     minutes = (int) Math.floor(disp_time / 60);
     seconds = (int) (disp_time % 60);
     
     clockTime = Integer.toString(minutes) + ":";
     if (seconds < 10) {
       clockTime += "0"; // pad the seconds
     }
     clockTime += Integer.toString(seconds);
     
     return clockTime;
  }
 
  private java.awt.image.BufferedImage nextImg() {
  
    if (imgFilter == null) {
    
      short[] lookupData = new short[256];

      for (int cnt = 0; cnt < 256; cnt++){
        lookupData[cnt] = (short)(255-cnt);
      }//end for loop
  
      java.awt.image.ShortLookupTable lookupTable = new java.awt.image.ShortLookupTable(0,lookupData);
    
      imgFilter = new java.awt.image.LookupOp(lookupTable,null);
    }

    if (pdf == null) { System.out.println("the pdf is not initted");
    } else {
    if (pdf.hasNext()) {
      img = nextImg;
      nextImg = (java.awt.image.BufferedImage) pdf.next();
      //nextImg = imgFilter.filter(nextImg, null);
     }
  }
     return img;
  }
  
  
  
  boolean advance (long disp_time) {
    
    int interval;
  
    if (count != disp_time) {
      count = disp_time;
      //if (disp_time % 50 == 0) {
      //  return true;
      //}
      
      interval = (10 * 60 / 6); // =100
      
      switch((int)disp_time) {
        
        case ((int)(10 * 60 / 6)):
        case ((int)((10 * 60 / 6) * 2)):
        case ((int)((10 * 60 / 6) * 3)):
        case ((int)((10 * 60 / 6) * 4)):
        case ((int)((10 * 60 / 6) * 5)):
        case (10* 60):
        case ((12 * 60) + 30):
        case (15* 60):
          return true;
      }
    }  
    return false;
  }
  
  
  public boolean isRunning() {
    
    return running;
  }
  
  public void toggle(long startTime) {
    
    
    System.out.println(startTime);
    if (! isRunning()) {
      
      notifyStart(0, true, startTime);
    } else {
      
      notifyStop();
    }
  }
  
    
  
  public void updateTime(long newTime) {
    current_time = newTime;
    if( isRunning()){
      this.repaint();    
    }
  }
}
