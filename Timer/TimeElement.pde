import java.awt.Color;

public class TimeElement {


  public int start_time, end_time;
  private double current_time;
  public color background;
  public color foreground;
  public int pageIndex;
  public int speed;
  public boolean countdown, isCue, showtime;
  public int flash;
  public String rehearsalMark;
  public String audioCue;


  public TimeElement (int start_time, int end_time, String background, String foreground, 
            int pageIndex, int speed, boolean countdown, String rehearsalMark, boolean isCue, int flash, boolean showtime) {

    this.start_time = start_time;
    this.end_time = end_time;
    this.isCue = isCue;
    this.flash = flash;
    this.showtime = showtime;
    try {
      this.background = parseColour(background);
    } catch (Exception e) { this.background = #000000; }
    try {
      this.foreground = parseColour(foreground);
    } catch (Exception e) { this.foreground = #ffffff; }
    this.pageIndex = pageIndex;
    this.speed = speed;
    this.countdown = countdown;
    this.rehearsalMark = rehearsalMark;
   }
   
   public void setSample(String path){
     
     audioCue = path;
   }

  public boolean isActive (double current_time){
    
    this.current_time =  current_time;

    if((current_time >= start_time) && (current_time <= end_time)){
      return true;
    } else {
      return false;
    }
    

  }
  
  public void setTime (long time){
    this.current_time = time;
  }
  
  public long mapTime (long disp_time){
    
    int low, high;
    long mapped;

    this.current_time = disp_time;


    low = min(start_time, end_time);
    
    
    if (this.countdown){
      //low = min(start_time, end_time);
      high = max (start_time, end_time);
      mapped = high - disp_time;
      mapped = (long) max(mapped, 0);
      return mapped;
    } else {
      return disp_time;
    }
    
  }
  
  public color getForeground(){
    return getForeground(current_time);
  }
  
  public color getBackground() {
    return getBackground(current_time);
  }
   
  
  
  
  public color getForeground(double disp_time){
    if(disp_time < (start_time + flash)) {
      return background;
    }else {
      return foreground;
    }
    
  }
  
  public color getBackground(double disp_time) {
    if(disp_time < (start_time + flash)) {
      return foreground;
    } else {
      return background;
    }
  }
  

  private color parseColour(String col) throws NumberFormatException {
    color colour;
    if (col == null) { throw new NumberFormatException(); 
    } else if (col.compareToIgnoreCase("black")==0) {
        colour = #000000;
    }else if (col.compareToIgnoreCase("white") ==0 ) {
        colour = #FFFFFF;
    } else if (col.compareToIgnoreCase("red") ==0 ) {
        colour = #FF0000;
    } else if (col.compareToIgnoreCase("orange") ==0 ) {
        colour = #FF8000;
    } else if (col.compareToIgnoreCase("yellow") ==0 ) {
        colour = #FFFF00;
    } else if (col.compareToIgnoreCase("green") ==0 ) {
        colour = #00FF00;
    } else if (col.compareToIgnoreCase("blue") ==0 ) {
        colour = #0000FF;
    } else if (col.compareToIgnoreCase("purple") ==0 ) {
        colour = #A020F0;
    } else if (col.compareToIgnoreCase("pink") == 0 ) {
        colour = #ffb6c1;
    } else if (col.compareToIgnoreCase("periwinkle") == 0){
        colour = #CCCCFF;
    } else {
      colour = Integer.parseInt(col, 16);
    }
    
    System.out.println(col);
    System.out.println(colour);
    return colour;
  }
    


}
