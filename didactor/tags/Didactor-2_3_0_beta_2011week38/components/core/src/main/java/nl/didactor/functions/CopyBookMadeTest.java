package nl.didactor.functions;

import org.mmbase.bridge.*;
import org.mmbase.storage.search.*;
import org.mmbase.bridge.util.Queries;
import org.mmbase.util.logging.*;
import java.util.*;
import java.lang.reflect.*;

/**
 * Retrieves a 'madetests' object for a certain tests and copybook objects.
 *
 * @author Michiel Meeuwissen
 * @version $Id$
 */
public class CopyBookMadeTest {
    protected final static Logger log = Logging.getLoggerInstance(CopyBookMadeTest.class);

    private Node node;

    public void setNode(Node n) {
        node = n;
    }

    private Node test;

    public void setTest(Node t) {
        test = t;
    }


    private boolean clear = false;

    public void setClear(boolean c) {
        clear = c;
    }

    private static final List<String> NODEMANAGERS = new ArrayList<String>();
    static {
        NODEMANAGERS.add("tests");
        NODEMANAGERS.add("learnblocks");
        NODEMANAGERS.add("xmlcontent");
    }

    protected static SortedSet<Integer> getOTypes(Cloud cloud, boolean desc, List<String> names)  {
        SortedSet<Integer> set = new TreeSet<Integer>();
        Iterator<String> i = names.iterator();
        while (i.hasNext()) {
            NodeManager nm = cloud.getNodeManager(i.next());
            set.add(nm.getNumber());
            if (desc) {
                NodeManagerIterator j = nm.getDescendants().nodeManagerIterator();
                while (j.hasNext()) {
                    set.add(j.nextNodeManager().getNumber());
                }
            }
        }
        return set;
    }

    protected static Node getMadeTestHolder(Node test) {
        return test.getFunctionValue("madetestholder", null).toNode();
    }


    /**
     * Returns the made tests object related to the givine copy-book,
     * and optionally to the given test-object
     */
    public NodeList madetests() {
        Cloud cloud = node.getCloud();
        NodeManager madeTests = cloud.getNodeManager("madetests");
        NodeQuery query = Queries.createRelatedNodesQuery(node, madeTests, "related", "destination");
        if (test != null) {
            Step testStep = query.addRelationStep(cloud.getNodeManager("learnobjects"), "related", "source").getNext();
            StepField numberField = query.createStepField(testStep, "number");
            Queries.addConstraint(query, query.createConstraint(numberField, getMadeTestHolder(test)));
            Queries.addConstraint(query, query.createConstraint(query.createStepField(testStep, "otype"), getOTypes(cloud, true, NODEMANAGERS)));
            query.addSortOrder(numberField, SortOrder.ORDER_ASCENDING);
        }
        StepField testsField = query.createStepField(query.getSteps().get(0), "number");
        query.addSortOrder(testsField, SortOrder.ORDER_ASCENDING);

        NodeList found = madeTests.getList(query);
        return found;
    }

    public Node madetest() {
        if (test == null) {
            throw new IllegalArgumentException("Test parameter is required");
        }
        NodeList found = madetests();

        if (found.size() > 0) {
            if (clear) {

                // todo....
            } else {
                return found.getNode(0);
            }
        }
        Cloud cloud = node.getCloud();

        NodeManager madeTests = cloud.getNodeManager("madetests");
        Node madeTest = madeTests.createNode();
        madeTest.commit();

        RelationManager rm = cloud.getRelationManager(node.getNodeManager(), madeTests, "related");

        log.debug("Created a madetests object " + madeTest.getNumber() + " for " + node.getNodeManager().getName() + " " + node.getNumber() + " now relating it");
        Relation rel1 = rm.createRelation(node, madeTest);
        rel1.commit();

        Node madeTestHolder = getMadeTestHolder(test);
        RelationManager rm2 = cloud.getRelationManager(madeTestHolder.getNodeManager(), madeTests, "related");
        Relation rel2 = rm2.createRelation(madeTestHolder, madeTest);
        rel2.commit();
        return madeTest;
    }


}
