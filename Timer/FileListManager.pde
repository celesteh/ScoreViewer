import java.io.File;
import java.io.FilenameFilter;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.StringSelection;
import java.awt.datatransfer.Transferable;
import java.awt.dnd.DnDConstants;
import java.awt.dnd.DragGestureEvent;
import java.awt.dnd.DragGestureListener;
import java.awt.dnd.DragGestureRecognizer;
import java.awt.dnd.DragSource;
import java.awt.dnd.DragSourceDragEvent;
import java.awt.dnd.DragSourceDropEvent;
import java.awt.dnd.DragSourceEvent;
import java.awt.dnd.DragSourceListener;
import java.awt.BorderLayout;
import java.awt.event.*;
import java.awt.Font;
import java.awt.GraphicsConfiguration;
import java.awt.geom.AffineTransform;

import javax.swing.*;
import javax.swing.filechooser.*;

import java.lang.*;


public class FileListManager extends JFrame {
  
  DefaultListModel model;
  FileListGui gui;
  JPanel panel;
  ActionListener listener;
  
   
  public FileListManager () {
    this ("Order of Pieces");
  }
  
  public FileListManager (String title) {
    super (title);
    
    String [] filenames;
    int scaleFactor = 1;
    java.awt.Font font;
    
  
    final java.awt.GraphicsDevice defaultScreenDevice = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice();
    
    GraphicsConfiguration gc = defaultScreenDevice.getDefaultConfiguration();
    AffineTransform at = gc.getDefaultTransform();
    
    font = new Font("Verdana", java.awt.Font.PLAIN, 24);
    font = font.deriveFont(at);
     
    panel = new JPanel();

    gui = new FileListGui();
    model = (DefaultListModel) gui.getModel();
    gui.setFont(font);

    filenames = getXMLFiles();
    
    for (int i = 0; i<filenames.length; i++) {
      model.addElement(filenames[i]);
      //println(filenames[i]);
    }
    
    gui.setModel(model);
    
    panel.setLayout(new BorderLayout());
    model = new DefaultListModel();
    JScrollPane pane = new JScrollPane(gui);
    JButton addButton = new JButton("+");
    addButton.setFont(font); 
    JButton removeButton = new JButton("-");
    removeButton.setFont(font);
    JButton okButton = new JButton("Ok");
    okButton.setFont(font);

    addButton.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        FilenameFilter xmlFilter;
        JFileChooser fc;
        int returnVal;
        
        xmlFilter = new FilenameFilter() {
          public boolean accept(File dir, String name) {
            //println(name);
            return name.toLowerCase().endsWith(".xml");
          }
        };
        
        fc = new JFileChooser();
        FileNameExtensionFilter filter = new FileNameExtensionFilter(
        "xml", "XML");
        fc.setFileFilter(filter);
        returnVal = fc.showOpenDialog(FileListManager.this);
        if(returnVal == JFileChooser.APPROVE_OPTION) {
            gui.addElement(fc.getSelectedFile().getName());
        }
      }
    });
    
    removeButton.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        int index;
        index = gui.getSelectedIndex();
        if (index >= 0) {
          gui.remove(index);
        }
      } 
    });
    
    okButton.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        ActionEvent event;
        
        event = new ActionEvent(FileListManager.this, 0, "ok");
        FileListManager.this.close();
        if(listener != null) {
          listener.actionPerformed(event);
        }
      }
    });
        
        
    panel.add(pane, BorderLayout.NORTH);
    panel.add(addButton, BorderLayout.WEST);
    panel.add(removeButton, BorderLayout.EAST); 
    panel.add(okButton, BorderLayout.SOUTH);
 
    this.setContentPane(panel);   
  }
  
  public String[] getXMLFiles(){
    File dir;
    FilenameFilter xmlFilter;
    String [] filenames;
    
    dir = new File(dataPath(""));
    
    xmlFilter = new FilenameFilter() {
      public boolean accept(File dir, String name) {
        return name.toLowerCase().endsWith(".xml");
      }
    };
    
    filenames = dir.list(xmlFilter);
    
    return filenames;
  } 
  
  public int showOpenDialog() {
    
      this.setSize(260, 200);
      this.setVisible(true);
      this.toFront();
      this.setAlwaysOnTop(true);
      
      java.awt.EventQueue.invokeLater(new Runnable() {
        @Override
        public void run() {
          FileListManager.this.toFront();
          FileListManager.this.repaint();
        }
    });
      return 1;
  }
  
  public String[] getOrder() {
    return gui.getOrder();
  }
  
  public void addActionListener(ActionListener listener){
    this.listener = listener;
  }
  
  
  public void close() {
    
        FileListManager.this.setVisible(false);
        FileListManager.this.setAlwaysOnTop(false);
  }
  
}


public class FileListGui extends JList {

  DefaultListModel model;

  public FileListGui() {
    super(new DefaultListModel());
    
    model = (DefaultListModel) getModel();
    
    setDragEnabled(true);
    setDropMode(DropMode.INSERT);

    setTransferHandler(new MyListDropHandler(this));

    new MyDragListener(this);
    
  }
  
  public void addElement(String name) {
    
    model.addElement(name);
  }
  
  
  public void move(int old_index, int new_index) {
    Object element;
   
    element = model.get(old_index);
    model.add(new_index, element);
    if(new_index < old_index){
      model.remove(old_index + 1);
    } else {
      model.remove(old_index);
    }
  }
  
  public void remove(int index) {
    model.remove(index);
  }

  public String[] getOrder() {
    
    String [] filenames = new String [model.getSize()];
    for (int i = 0; i < model.getSize(); i++) {
      filenames[i] = "Timings/" + (String) model.getElementAt(i);
    }
    
    return filenames;
  }
  /*
  public static void main(String[] a){
    JFrame f = new JFrame();
    f.add(new JScrollPane(new FileListGui()));
    f.setSize(300,300);
    f.setVisible(true);
  }
  */
}

class MyDragListener implements DragSourceListener, DragGestureListener {
  FileListGui list;

  DragSource ds = new DragSource();

  public MyDragListener(FileListGui list) {
    this.list = list;
    DragGestureRecognizer dgr = ds.createDefaultDragGestureRecognizer(list,
        DnDConstants.ACTION_MOVE, this);

  }

  public void dragGestureRecognized(DragGestureEvent dge) {
    StringSelection transferable = new StringSelection(Integer.toString(list.getSelectedIndex()));
    ds.startDrag(dge, DragSource.DefaultCopyDrop, transferable, this);
  }

  public void dragEnter(DragSourceDragEvent dsde) {
  }

  public void dragExit(DragSourceEvent dse) {
  }

  public void dragOver(DragSourceDragEvent dsde) {
  }

  public void dragDropEnd(DragSourceDropEvent dsde) {
    if (dsde.getDropSuccess()) {
      System.out.println("Succeeded");
      list.setModel(list.getModel());
    } else {
      System.out.println("Failed");
    }
  }

  public void dropActionChanged(DragSourceDragEvent dsde) {
  }
}

class MyListDropHandler extends TransferHandler {
  FileListGui list;

  public MyListDropHandler(FileListGui list) {
    this.list = list;
  }

  public boolean canImport(TransferHandler.TransferSupport support) {
    if (!support.isDataFlavorSupported(DataFlavor.stringFlavor)) {
      return false;
    }
    JList.DropLocation dl = (JList.DropLocation) support.getDropLocation();
    if (dl.getIndex() == -1) {
      return false;
    } else {
      return true;
    }
  }

  public boolean importData(TransferHandler.TransferSupport support) {
    if (!canImport(support)) {
      return false;
    }

    Transferable transferable = support.getTransferable();
    String indexString;
    try {
      indexString = (String) transferable.getTransferData(DataFlavor.stringFlavor);
    } catch (Exception e) {
      return false;
    }

    int index = Integer.parseInt(indexString);
    JList.DropLocation dl = (JList.DropLocation) support.getDropLocation();
    int dropTargetIndex = dl.getIndex();

    System.out.println(dropTargetIndex + " : ");
    System.out.println("inserted");
    
    list.move(index, dropTargetIndex);
    return true;
  }

  
}
