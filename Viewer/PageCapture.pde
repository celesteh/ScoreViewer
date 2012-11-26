/*
import org.icepdf.core.exceptions.PDFException;
import org.icepdf.core.exceptions.PDFSecurityException;
import org.icepdf.core.pobjects.Document;
import org.icepdf.core.pobjects.Page;
import org.icepdf.core.util.GraphicsRenderingHints;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.awt.image.RenderedImage;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Iterator;
*/

public class PageCapture implements java.util.Iterator {
 
  int page;
  org.icepdf.core.pobjects.Document document;
  RenderedImage nextImage;
  float scale;
  float rotation;

   PageCapture (String filePath) {


      // open the file
      document = new org.icepdf.core.pobjects.Document();
      try {
         document.setFile(filePath);
      } catch (org.icepdf.core.exceptions.PDFException ex) {
         System.out.println("Error parsing PDF document " + ex);
      } catch (org.icepdf.core.exceptions.PDFSecurityException ex) {
         System.out.println("Error encryption not supported " + ex);
      } catch (java.io.FileNotFoundException ex) {
         System.out.println("Error file not found " + ex);
      } catch (java.io.IOException ex) {
         System.out.println("Error IOException " + ex);
      }

      // save page captures to file.
      scale = 1.0f;
      rotation = 0f;
      page = 0;
      
      
      nextImage = getNextImage();
   }
   
   public boolean hasNext(){
     
       return (nextImage != null);
   }
   
   public void remove () {}
   
   public Object next () {
       
      Object obj;
      
      obj = (Object) nextImage;
      nextImage = getNextImage();
      
      return obj;
      
     
   }
   
   public java.awt.image.BufferedImage at(int i) {
     
         java.awt.image.RenderedImage rendImage;
          java.awt.image.BufferedImage image = (java.awt.image.BufferedImage) document.getPageImage(
             i, org.icepdf.core.util.GraphicsRenderingHints.SCREEN, Page.BOUNDARY_CROPBOX, 
             rotation, scale);
           rendImage = image;
           return image;
   }
   
   private java.awt.image.BufferedImage getNextImage() {

     java.awt.image.BufferedImage rendImage = null;

        if ((document != null) &&
        (page < document.getNumberOfPages())) {
          
          rendImage = at(page);
         
           page ++;
         } else {
           System.out.println("either document is null or we're out of pages"+ page);
           document.dispose();
           document = null;
         }

        return rendImage;
   }  
  
}

