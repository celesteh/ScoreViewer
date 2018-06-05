
import java.util.Iterator;
import java.io.File;
import java.awt.Color;

public class TimingReader implements Iterator {

  TimeElement [] timings;
  String pdf_filename;
  public String title;
  public int start, end;
  public int speed;
  public boolean seconds;
  public boolean mod;
  public boolean inverse;
  public String id;
  public boolean countdown;
  public int countby;
  

  
  public TimingReader (String filename) {
        
   XML xml, header;
   XML [] timing_list;
   String bgcolour, fgcolour, rehearsalMark;
   int pagenum;
       
   xml = loadXML(filename);
   
   header = xml.getChild("title");
   if (header != null) {
     title = header.getContent();
     System.out.println("Title is " + title);
   }
   
   header = xml.getChild("id");
   if (header != null) {
     id = header.getContent();
   }
   
   header = xml.getChild("pdf");
   if (header != null) {
     pdf_filename = header.getContent();
     if (header.hasAttribute("inverse")) {
       inverse = (header.getInt("inverse") == 1);
     }
   }
   
   header = xml.getChild("start");
   if (header != null) {
     start = Integer.parseInt(header.getContent());
   } else {
     start = 0;
   }

   header = xml.getChild("end");
   if (header != null) {
     end = Integer.parseInt(header.getContent());
   } else {
     end = -1;
   }
  
  countdown = false;
   header = xml.getChild("type");
   if (header != null) {
     seconds = (header.getContent().compareToIgnoreCase("seconds") == 0);
     if(header.hasAttribute("sections_start_with_zero")) {
       mod = (header.getInt("sections_start_with_zero") == 1);
     } // starts with zero
     
     if(header.hasAttribute("countdown")) {
       countdown = (header.getInt("countdown") == 1);
     } // starts with zero
     
     if (header.hasAttribute("countby")) {
       countby = header.getInt("countby");
     } else {
       countby=0;
     }
   } else {
     
     seconds = false;
   }
 
   
  
    timing_list = xml.getChildren("timing");
    timings = new TimeElement[timing_list.length];
    
    for(int i = 0; i < timing_list.length; i++) {
      
      bgcolour = null;
      fgcolour = null;
      pagenum = -1;
      
      if (timing_list[i].hasAttribute("bgcolour")) {
        bgcolour = timing_list[i].getString("bgcolour");
      }
      
      if (timing_list[i].hasAttribute("bgcolor")) {
        bgcolour = timing_list[i].getString("bgcolor");
      }

      if (timing_list[i].hasAttribute("fgcolour")) {
        fgcolour = timing_list[i].getString("fgcolour");
      }

      if (timing_list[i].hasAttribute("fgcolor")) {
        fgcolour = timing_list[i].getString("fgcolor");
      }

      if (timing_list[i].hasAttribute("page")) {
        pagenum = timing_list[i].getInt("page");
      } else {
        pagenum = -1;
      }
      
      if (timing_list[i].hasAttribute("speed")){
        speed = timing_list[i].getInt("speed");
      } else {
        speed = 1000; // 1 second = 1 second
      }
      
      if (timing_list[i].hasAttribute("rehearsalMark")){
        rehearsalMark = timing_list[i].getString("rehearsalMark");
      } else { 
        rehearsalMark = "";
      }
      
      timings[i] = new TimeElement(
        timing_list[i].getInt("start"),
        timing_list[i].getInt("end"),
        bgcolour, fgcolour, pagenum, speed, countdown, rehearsalMark);
    }
    
  }

  public boolean hasNext() {
    
    return true;
  }
  
  public void remove() {}
  
  public Object next() {
    
    return this;
    
  }
  
  public TimeElement at( double current_time) {
   
    boolean flag = false;
    TimeElement range;
    
    range = timings[0];
    
    for(int i = 0; (! flag) && i< timings.length; i++) { 
      
      range = timings[i];
      flag =   range.isActive(current_time);
      
    }
    
    if (flag) {
      return range;
    } else {
      return null;
    }
  
     
  }
  

}