package nl.didactor.utils.files;

import java.io.File;

/**
 * @javadoc
 * @version $Id$
 */
public class CommonUtils {
    /**
     * @javadoc
     */
    public static String fixPath(String sPath) {
        if (File.separator.equals("\\")) {
            //Something like Windows
            return sPath.replaceAll("/", File.separator + File.separator);
        } else { 
            //Something like Unix
            return sPath.replaceAll("\\\\", File.separator);
        }
        
    }
}
