package nl.didactor.security;

import java.util.*;
import nl.didactor.builders.DidactorBuilder;
import nl.didactor.builders.DidactorRel;
import nl.didactor.builders.PeopleBuilder;
import nl.didactor.functions.PeopleClassFunction;
import org.mmbase.bridge.util.Queries;
import org.mmbase.security.SecurityException;
import org.mmbase.security.*;
import org.mmbase.bridge.*;
import org.mmbase.storage.search.Step;
import org.mmbase.util.logging.Logger;
import org.mmbase.util.logging.Logging;
import org.mmbase.module.core.*;
import org.mmbase.module.corebuilders.InsRel;


/**
 * @javadoc
 * @version $Id$
 */
public class Authorization extends org.mmbase.security.Authorization {

    private static final Logger log = Logging.getLoggerInstance(Authorization.class);

    private static final String EVERYBODY = "everybody";
    private static final Set<String>  possibleContexts = Collections.unmodifiableSet(new HashSet<String>(Arrays.asList( new String[]{EVERYBODY, "owner"})));
    private static final Set<String>  privateTypes     = Collections.unmodifiableSet(new HashSet<String>(Arrays.asList( new String[]{"problems"})));

    /**
     *	This method does nothing
     */
    @Override
    protected void load() {
    }

    /**
     *	This method does nothing
     */
    @Override
    public void create(org.mmbase.security.UserContext user, int nodeid) {
    }

    /**
     *	This method does nothing
     */
    @Override
    public void update(org.mmbase.security.UserContext user, int nodeid) {
    }


    /**
     */
    @Override
    public boolean check(org.mmbase.security.UserContext user, int nodeid, Operation operation) {
        if (! (user instanceof nl.didactor.security.UserContext)) {
            return false;
        } else {
            // This is in no way an elaborate implementation

            nl.didactor.security.UserContext uc = (nl.didactor.security.UserContext) user;

            MMObjectBuilder objectBuilder = MMBase.getMMBase().getBuilder("object");
            MMObjectNode node = objectBuilder.getNode(nodeid);
            if (node == null) {
                return true;
            }

            String ownerField = user.getOwnerField();
            if (uc.getRank().getInt() <= Authentication.DIDACTOR_USER.getInt()) {
                if (operation.equals(Operation.DELETE) ||
                    (operation.equals(Operation.WRITE) && uc.getUserNumber() != nodeid) ||
                    (operation.equals(Operation.READ) && privateTypes.contains(objectBuilder.getTableName()))) {
                    String context = getContext(user, nodeid);
                    boolean ownNode = context.equals(ownerField);
                    boolean access;
                    if (! ownNode) {
                        Set<String> myRoles = uc.getRoles();
                        if (myRoles.contains("teacher") || myRoles.contains("coach")) {
                            try {
                                Cloud cloud = ContextProvider.getDefaultCloudContext().getCloud("mmbase", user);
                                NodeQuery q = Queries.createRelatedNodesQuery(cloud.getNode(uc.getUserNumber()), cloud.getNodeManager("classes"), "classes", "destination");

                                PeopleClassFunction function = new PeopleClassFunction();
                                function.setNode(cloud.getNode(((UserContext) user).getUserNumber()));

                                PeopleBuilder people = (PeopleBuilder) MMBase.getMMBase().getBuilder("people");
                                MMObjectNode owner = people.getUser(context);
                                boolean studentsNode = function.isTeacherOrCoach(cloud.getNode(owner.getNumber()));
                                access = studentsNode;
                            } catch (Exception e) {
                                log.warn(e);
                                access = false;
                            }
                        } else {
                            access = false;
                        }
                    } else {
                        access = true;
                    }
                    if (! access && node.getBuilder() instanceof InsRel) {
                        // for relations we grant access if you have access to at least one of the end points.
                        String sourceContext = getContext(user, node.getIntValue("snumber"));
                        String destinationContext = getContext(user, node.getIntValue("dnumber"));
                        access = sourceContext.equals(ownerField) || destinationContext.equals(ownerField);
                    }
                    if (! access) {
                        log.warn("Access denied to " + user + " (" + user.getOwnerField() + ") for " + operation + " on " + node + " (" + context + ")");
                    }
                    return access;
                }

            }


            if (operation.equals(Operation.DELETE)) {
                if (uc.getUserNumber() == nodeid) {
                    // you may not delete yourself
                    return false;
                }


                if (node.getBuilder().getTableName().equals("people")) {
                    try {
                        UserContext otherUser = new UserContext(node, "check");
                        if (uc.getRank().getInt() < Rank.ADMIN.getInt() && otherUser.getRank().getInt() > uc.getRank().getInt()) {
                            // you may not delete user with equal/higher rank (unless, you are
                            // administrator, then you may delete other administrators)
                            return false;
                        }
                    } catch (Exception e) {
                        // if exception from new UserContext, (propably user withouth roles), then
                        // you may delete correspoding node.
                        return true;
                    }
                }

            }
        }
        return true;
    }

    /**
     * This method will call the 'preDelete()' method for the builder to which this node that is deleted belongs.
     */
    @Override
    public void verify(org.mmbase.security.UserContext user, int nodeid, Operation operation) throws org.mmbase.security.SecurityException {
        super.verify(user, nodeid, operation);
        if (operation.equals(Operation.DELETE)) {
            MMObjectBuilder objectBuilder = MMBase.getMMBase().getBuilder("object");
            MMObjectNode node = objectBuilder.getNode(nodeid);
            if (node == null) return;
            MMObjectBuilder builder = node.getBuilder();
            if (builder instanceof DidactorBuilder) {
                DidactorBuilder dbuilder = (DidactorBuilder)builder;
                dbuilder.preDelete(node);
            } else if (builder instanceof DidactorRel) {
                DidactorRel dbuilder = (DidactorRel)builder;
                dbuilder.preDelete(node);
            }
        }
    }

    /**
     * This method does nothing
     */
    @Override
    public void remove(org.mmbase.security.UserContext user, int nodeid) {

    }

    /**
     * Checks that you don't link to roles you don't have yourself. All other relations are permitted.
     */
    public boolean check(org.mmbase.security.UserContext user, int nodeid, int srcNodeid, int dstNodeid, Operation operation) {
        nl.didactor.security.UserContext uc = (nl.didactor.security.UserContext) user;
        if (operation.equals(Operation.CREATE)) {
            if (uc.getRank().getInt() < Rank.ADMIN.getInt()) {
                // you may only give roles, which you have yourself (or, you are administrator)
                MMObjectBuilder objectBuilder = MMBase.getMMBase().getBuilder("object");
                MMObjectNode node = objectBuilder.getNode(dstNodeid);
                if (node.getBuilder().getTableName().equals("roles")) {
                    return uc.getRoles().contains(node.getStringValue("name"));
                }
            }
        }

        return true;
    }



    /**
     * This method does nothing, except from giving a specified string back
     */
    @Override
    public String getContext(org.mmbase.security.UserContext user, int nodeNumber) throws SecurityException {
        Node node = LocalContext.getCloudContext().getCloud("mmbase", user).getNode(nodeNumber);
        if (node.getNodeManager().hasField("context")) {
            Object context = node.getValue("context");
            if(context != null) {
                if (log.isDebugEnabled()) {
                    log.debug("Type of context " + context.getClass() + " " + context);
                }
                if (context instanceof Node) {
                    return ((org.mmbase.bridge.Node) context).getContext();
                } else {
                    return org.mmbase.util.Casting.toString(context);
                }
            } else {
                MMObjectBuilder objectBuilder = MMBase.getMMBase().getBuilder("object");
                MMObjectNode mnode = objectBuilder.getNode(nodeNumber);
                return org.mmbase.util.Casting.toString(mnode.getValues().get("owner"));
            }
        } else {
            MMObjectBuilder objectBuilder = MMBase.getMMBase().getBuilder("object");
            MMObjectNode mnode = objectBuilder.getNode(nodeNumber);
            return org.mmbase.util.Casting.toString(mnode.getValues().get("owner"));
        }
    }

    /**
     * Since this is not authorization, we simply allow every change of context.
     */
    @Override
    public void setContext(org.mmbase.security.UserContext user, int nodeNumber, String context) throws SecurityException {
        MMObjectBuilder objectBuilder = MMBase.getMMBase().getBuilder("object");
        MMObjectNode node = objectBuilder.getNode(nodeNumber);
        node.setValue("owner", context);
    }

    /**
     * This method does nothing, except from returning a dummy value
     */
    @Override
    public Set getPossibleContexts(org.mmbase.security.UserContext user, int nodeid) throws SecurityException {
        Set<String> result = new HashSet<String>(possibleContexts);
        result.add(getContext(user, nodeid)); // add current context too
        return result;
    }

    @Override
    public QueryCheck check(org.mmbase.security.UserContext user, org.mmbase.bridge.Query query, Operation operation) {
        if (user.getRank().getInt() <= Authentication.DIDACTOR_USER.getInt()) {
            for (Step step : query.getSteps()) {
                if (privateTypes.contains(step.getTableName())) {
                    return NO_CHECK;
                }
            }
        }
        return COMPLETE_CHECK;

    }

}
