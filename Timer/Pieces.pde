


public class Pieces implements Iterator {

  String[] order;
  int index;
 FileListManager frame;
 
  public Pieces () {
    index = -1;
    /*
  frame = new FileListManager();
  
  frame.addActionListener( new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        try {
          System.out.println("ok");
        //order = frame.getOrder();
        Object src;
        String [] results;
        src =e.getSource();
        System.out.println(src);
        results = ((FileListManager) src).getOrder();
        System.out.println(results.length);
        Pieces.this.order = results;
        index = 0;
        
        } catch (Exception ex) {}
      }
  }); 
 
  frame.showOpenDialog(); 
  */

  }
  public Pieces (String[] order) {
    this.order = order;
    index = 0;
    
  }

  public void setOrder (String[] order) {
    
    this.order = order;
    index = 0;
  }
  
  public boolean ready() {
    
    return (order != null);
  }
  
    public boolean hasNext() {
    
    return (ready() && (index < order.length));
  }
  
  public void remove() {}
  
  public Object id(String id){
    TimingReader times = null;
    Boolean found = false;
    int localIndex = index;
    
    while ((! found) && this.hasNext()) {
      times = (TimingReader) this.next();
      found = (times.id  == id);
    }
    
    // restart from the start
    index = 0;
    while ((! found) && (index <= localIndex) && this.hasNext()) {
      times = (TimingReader) this.next();
      found = (times.id  == id);
    }
    
    index = localIndex;
      
    return (Object) times;
  }
  
  public Object next() {
    
    TimingReader times;
    System.out.println("next " + order.length + " in queue.");
    System.out.println(order[index]);
    
    times = new TimingReader(order[index]);
    index += 1;
    
    return (Object) times;
    
  }
  
  
  public Object prev() {
    TimingReader times;
    //System.out.println("next " + order.length + " in queue.");
    //System.out.println(order[index]);
    
    index -=2;
    if (index < 0) { index = 0; }
    
    times = new TimingReader(order[index]);
    index += 1;
    
    return (Object) times;
    
  }
  
  
  public void hide () {
    
    frame.close();
  }
  
  

}
