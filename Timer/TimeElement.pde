import java.awt.Color;


public class TimeElement {


  public int start_time, end_time;
  public color background;
  public color foreground;
  public int pageIndex;
  public int speed;
  public boolean countdown;
  public String rehearsalMark;


  public TimeElement (int start_time, int end_time, String background, String foreground, 
            int pageIndex, int speed, boolean countdown, String rehearsalMark) {

    this.start_time = start_time;
    this.end_time = end_time;
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

  public boolean isActive (double current_time){
    
    if((current_time >= start_time) && (current_time <= end_time)){
      return true;
    } else {
      return false;
    }

  }
  
  public long mapTime (long disp_time){
    
    int low, high;
    long mapped;
    
    low = min(start_time, end_time);
    
    
    if (this.countdown){
      //low = min(start_time, end_time);
      high = max (start_time, end_time);
      mapped = high - disp_time;
      return mapped;
    } else {
      return disp_time;
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
