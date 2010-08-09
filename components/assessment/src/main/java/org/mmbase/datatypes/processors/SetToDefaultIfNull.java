/*

This software is OSI Certified Open Source Software.
OSI Certified is a certification mark of the Open Source Initiative.

The license (Mozilla version 1.0) can be read at the MMBase site.
See http://www.MMBase.org/license

*/
package org.mmbase.datatypes.processors;

import org.mmbase.bridge.*;
import org.mmbase.util.logging.*;

/**

 * @author Michiel Meeuwissen
 * @version $Id: Related.java 38784 2009-09-22 20:26:32Z andre $
 */

public class SetToDefaultIfNull implements Processor {

    private static final Logger log = Logging.getLoggerInstance(SetToDefaultIfNull.class);

    private static final long serialVersionUID = 1L;
    @Override
    public Object process(Node node, final Field field, final Object value) {
        if (node.getValueWithoutProcess(field.getName()) == null) {
            log.debug("Field " + field + " is null");
            Object defaultValue = field.getDataType().getDefaultValue(node.getCloud().getLocale(), node.getCloud(), field);
            log.debug("Default value " + defaultValue);
            if (! node.mayWrite()) {
                node = node.getCloud().getCloudContext().getCloud("mmbase", "class", null).getNode(node.getNumber());
            }
            node.setValue(field.getName(), defaultValue);
            node.commit();
            return node.getValue(field.getName());
        }
        return value;
    }
}
