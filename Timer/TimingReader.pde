
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
  public boolean marks;
  public boolean showtime;
  public boolean inverse;
  public int flash;
  public String id;
  public boolean countdown;
  public int countby;
  int last;
  

  
  public TimingReader (String filename) {
        
   XML xml, header;
   XML [] timing_list;
   String bgcolour, fgcolour, rehearsalMark;
   int pagenum;
   boolean first, cue;
   int section_start, section_end, low, high, last_start, last_end;
   int index;
   int [] starts;
   
   this.last = 0;
      
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
     start = parseTime(header.getContent());
   } else {
     start = 0;
   }

   header = xml.getChild("end");
   if (header != null) {
     end = parseTime(header.getContent());
   } else {
     end = -1;
   }
  
  countdown = false;
  seconds = false;
  countby =0;
  flash = 0;
   header = xml.getChild("type");
   if (header != null) {
     seconds = (header.getContent().compareToIgnoreCase("seconds") == 0);
     showtime = (header.getContent().compareToIgnoreCase("marks") != 0);
     marks = ! showtime;
     if(header.hasAttribute("sections_start_with_zero")) {
       mod = (header.getInt("sections_start_with_zero") == 1);
     } // starts with zero
     
     if(header.hasAttribute("countdown")) {
       countdown = (header.getInt("countdown") == 1);
     } // starts with zero
     
     if (header.hasAttribute("countby")) {
       countby = header.getInt("countby");
     } 
     if (header.hasAttribute("flash")){
       flash = header.getInt("flash");
     } 
     
     // new type for showing time / showing rehearsal marks
     if(header.hasAttribute("marks")){
       marks = (header.getInt("marks") == 1);
     } 
   }
 
   
  
    timing_list = xml.getChildren("timing");
    timings = new TimeElement[timing_list.length * 2];
    starts = new int[timing_list.length];
    first = true;
    index = 0;
    last_start = 0;
    last_end = 0;
    
    // first get start times
    for(int i = 0; i < timing_list.length; i++) {
      if (timing_list[i].hasAttribute("start")){
        // parseTime()
        starts[i] = parseTime(timing_list[i].getString("start"));
        last_start = starts[i];
      } else {
        starts[i] = last_start + 1;
      }
    }

    
    for(int i = 0; i < timing_list.length; i++) {
      
      bgcolour = null;
      fgcolour = null;
      pagenum = -1;
      cue = false;
      
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
      
      if (timing_list[i].hasAttribute("cue")){
        cue = (timing_list[i].getInt("cue") == 1);
      }
      
      if (timing_list[i].hasAttribute("rehearsalMark")){
        rehearsalMark = timing_list[i].getString("rehearsalMark");
      } else { 
        rehearsalMark = timing_list[i].getContent();
      }
      
      section_start = starts[i];
      
      // get or calculate the end
      if (timing_list[i].hasAttribute("end")){
        section_end = parseTime(timing_list[i].getString("end"));
      } else {
        // see if there's a section after this one
        if((i+1) < timing_list.length) {
          section_end = starts[i+1] - 1;
        } else {
          // use the overall duration of the piece
          if(end > section_start) {
            section_end = end;
          } else {
            // a duration of one second
            section_end = section_start +1;
          }
        }
      }
      
      low = min(section_start, section_end);
      high = max(section_start, section_end);
      
      if (!first && (flash > 0)) {
        if (((high - low) > (flash + 1)) || cue){
          System.out.println("Making flash");
          // Make the flash
          // The flash is never a queue
          timings[index] = new TimeElement (
           section_start, section_start + flash, fgcolour, bgcolour, pagenum, speed, countdown, rehearsalMark, false);
          index = index + 1;
          timings[index] = new TimeElement (
            section_start + flash + 1, section_end, bgcolour, fgcolour, pagenum, speed, countdown, rehearsalMark, cue);
          index = index + 1;
        } else {
          timings[index] = new TimeElement(section_start, section_end,
            bgcolour, fgcolour, pagenum, speed, countdown, rehearsalMark, cue);
          index = index +1;
        }
      } else {
      
        timings[index] = new TimeElement(
          section_start,
          section_end,
          bgcolour, fgcolour, pagenum, speed, countdown, rehearsalMark, cue);
        index = index +1;
      }// end if(!first ....
      
      first = false;
    }// end for
  }
  
  
  private int parseTime(String time){
    int seconds = 0;
    
    String [] units = time.split(":", 0);
    for (int i=0; i < units.length; i ++) {
      seconds += Math.pow(60,(units.length -(i+1))) * Integer.parseInt(units[i]);
    }
    return ((Integer) seconds);
  }

  public boolean hasNext() {
    
    //return true;
    return (last < (timings.length -1));
  }
  
  public void remove() {}
  
  public Object next() {
    TimeElement theNext = null;
    
    if (this.hasNext()) {
      last++;
      theNext = timings[last];
    }
    return (Object) theNext;
    
  }
  
  public TimeElement at( double current_time) {
   
    boolean flag = false;
    int i = max(last - 1, 0);
    TimeElement range;
    
    range = timings[last];
    if (range != null) {
      flag = range.isCue; // If it's a queue, we don't care about the time
    }
    
    for(; (! flag) && i< timings.length; i++) { 
      
      range = timings[i];
      if (range != null) {
        flag =   range.isActive(current_time);
        last = i;
      }
    }
    
    if (flag) {
      return range;
    } else {
      return null;
    }
  
     
  }
  
  public double advance (double current_time, boolean forward){
    boolean flag = false;
    TimeElement prev, range, next;
    int index = 0;
    double new_time = 0;
    
    prev = range = timings[0];
     
    for(int i = max(last-1, 0); (! flag) && i< timings.length; i++) { 
      
      prev = range;
      range = timings[i];
      if (range != null) {
        flag =   range.isActive(current_time) || range.isCue;
        index = i;
      }
    }
    
    if (flag) {
      if (forward){
        if((index + 1) < timings.length) {
          new_time = timings[index+1].start_time;
          last = index +1;
        } else {
          new_time = range.end_time;
          last = index;
        }
      } else {
        // go backwards
        new_time = prev.start_time;
        last = max(index -1, 0);
      }
    } else {
      new_time = range.end_time;
      last = index;
    }
  
     return new_time;
  }
  
  

}
