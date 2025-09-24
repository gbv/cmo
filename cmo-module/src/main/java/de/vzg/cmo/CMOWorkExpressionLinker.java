package de.vzg.cmo;

import java.util.List;
import java.util.Optional;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.access.MCRAccessException;
import org.mycore.common.MCRException;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.mei.MEIAttributeConstants;
import org.mycore.mei.MEIElementConstants;
import org.mycore.mei.MEIExpressionWrapper;
import org.mycore.mei.MEIExpressionWrapper.RealizationOf;
import org.mycore.mei.MEIUtils;
import org.mycore.mei.MEIWorkWrapper;
import org.mycore.mei.MEIWrapper;

public class CMOWorkExpressionLinker {

  private static final Logger LOGGER = LogManager.getLogger();

  /**
   * Extracts the CMO identifier from the given MEIWrapper.
   * @param meiWrapper the MEIWrapper to extract the identifier from
   * @return an Optional containing the CMO identifier, or an empty Optional if not found
   */
  private Optional<String> getCMOIdentifier(MEIWrapper meiWrapper) {
    Element identifier = meiWrapper.getXpath(
        ".//mei:" + MEIElementConstants.IDENTIFIER + "[@type='CMO']");
    if (identifier == null) {
      return  Optional.empty();
    }

    return Optional.of(identifier.getTextTrim())
        .filter(s -> !s.isBlank());
  }


  /**
   * Adds a relation to the expression pointing to the work and saves the expression.
   * If the expression already has a realizationOf element pointing to the work, nothing is done.
   * @param work the work object
   * @param expression the expression object
   * @throws CMOLinkAlreadyExistsException if the expression already has a realizationOf element pointing to a different work
   */
  void addWorkRelationToExpressionAndSave(MCRObject expression, MCRObject work) throws CMOLinkAlreadyExistsException {
    MEIExpressionWrapper expressionWrapper =
        MEIWrapper.getWrapper(expression, MEIExpressionWrapper.class);

    Element relationList = expressionWrapper.getOrCreateElement(
        MEIElementConstants.RELATION_LIST);

    boolean relationExists = false;

    MCRObjectID workId = work.getId();


    for (RealizationOf realization : expressionWrapper.getRealizations()) {
      if (!realization.target().equals(workId.toString())) {
        throw new CMOLinkAlreadyExistsException(expression.getId(), workId);
      } else {
        relationExists = true;
      }
    }

    if (!relationExists) {
      MEIWorkWrapper workWrapper = MEIWrapper.getWrapper(work, MEIWorkWrapper.class);
      Optional<String> linkLabel = getCMOIdentifier(workWrapper);

      Element newRelation = new Element(MEIElementConstants.RELATION, MEIUtils.MEI_NAMESPACE);
      newRelation.setAttribute(MEIAttributeConstants.REL, "isRealizationOf");
      newRelation.setAttribute(MEIAttributeConstants.TARGET, workId.toString());
      linkLabel.ifPresent(s -> newRelation.setAttribute("label", s));
      relationList.addContent(newRelation);
      try {
        MCRMetadataManager.update(expression);
      } catch (MCRAccessException e) {
        throw new MCRException("Impossible", e);
      }
    }
  }

  private boolean addExpressionLinkToWork(MCRObject expression, MCRObject work) {
    MEIWorkWrapper workWrapper = MEIWrapper.getWrapper(work, MEIWorkWrapper.class);
    Element expressionList = workWrapper.getOrCreateElement(
        MEIElementConstants.EXPRESSION_LIST);

    MCRObjectID toID = expression.getId();
    MEIExpressionWrapper expressionWrapper = MEIWrapper.getWrapper(expression, MEIExpressionWrapper.class);

    boolean expressionExists = false;
    for (Element expressionElement : expressionList.getChildren(
        MEIElementConstants.EXPRESSION, MEIUtils.MEI_NAMESPACE)) {
      String codeVal = expressionElement
          .getAttributeValue(MEIAttributeConstants.CODEDVAL);
      if (codeVal != null && codeVal.equals(toID.toString())) {
        expressionExists = true;
        break;
      }
    }

    if (!expressionExists) {
      Element newExpression = new Element(MEIElementConstants.EXPRESSION,
          MEIUtils.MEI_NAMESPACE);
      newExpression.setAttribute(MEIAttributeConstants.CODEDVAL, toID.toString());
      newExpression.setAttribute("auth.uri", MCRFrontendUtil.getBaseURL() + "receive/");
      Optional<String> expressionCMOId = getCMOIdentifier(expressionWrapper);
      expressionCMOId.ifPresent(s -> newExpression.setAttribute("label", s));
      expressionList.addContent(newExpression);
    }
    return !expressionExists;

  }

  /**
   * Links the given work to the given expressions.
   * This method adds a realizationOf relation to each expression pointing to the work,
   * and adds an expression element to the work pointing to each expression.
   * Saves both objects if any changes were made.
   * @param work the work object
   * @param expressions the list of expression objects
   * @throws CMOLinkAlreadyExistsException if any expression already has a realizationOf element pointing to a different work
   */
  public void linkWorkAndExpression(MCRObject work, List<MCRObject> expressions) throws CMOLinkAlreadyExistsException {
    boolean updatedWork = false;
    for (MCRObject expression : expressions) {
      this.addWorkRelationToExpressionAndSave(expression, work);
      boolean modified = addExpressionLinkToWork(expression, work);
      updatedWork = updatedWork || modified;
      LOGGER.info("Linked work {} to expression {}", work.toString(), expression.toString());
    }

    if (updatedWork) {
      try {
        MCRMetadataManager.update(work);
      } catch (MCRAccessException e) {
        throw new MCRException("Impossible", e);
      }
    }
  }

    /**
     * Validates if the expression can be linked to the work.
     * An expression can be linked if any of the following is true:
     * <ul>
     *   <li>it has no realizationOf element</li>
     *   <li>it has a realizationOf element that points to the work</li>
     * </ul>
     * @param expressionWrapper the expression wrapper
     * @param expressionId the id of the expression
    
     * @return true if the expression can be linked to the work, false otherwise
     */
    public boolean validateExpression(
        MEIExpressionWrapper expressionWrapper, MCRObjectID expressionId) {
        for (RealizationOf realization : expressionWrapper.getRealizations()) {
            if (!realization.target().equals(expressionId.toString())) {
                return false;
            }
        }
        return true;
    }

  /**
   * Unlinks the given work from the given expression.
   * This method removes the realizationOf relation from the expression pointing to the work,
   * and removes the expression element from the work pointing to the expression.
   * Saves both objects if any changes were made.
   * @param work the work object
   * @param expression the expression object
   */
  public void unlinkWorkAndExpression(MCRObject work, MCRObject expression) {
    MEIWorkWrapper workWrapper = MEIWorkWrapper.getWrapper(work, MEIWorkWrapper.class);
    MEIExpressionWrapper expressionWrapper = MEIExpressionWrapper.getWrapper(expression, MEIExpressionWrapper.class);

    Element expressionList = workWrapper.getOrCreateElement(
        MEIElementConstants.EXPRESSION_LIST);

    List<Element> matchingExpressions = expressionList.getChildren(
            MEIElementConstants.EXPRESSION, MEIUtils.MEI_NAMESPACE)
        .stream()
        .filter(expressionElement -> {
          String codeVal = expressionElement
              .getAttributeValue(MEIAttributeConstants.CODEDVAL);
          return codeVal != null && codeVal.equals(expression.getId().toString());
        })
        .toList();

    if (!matchingExpressions.isEmpty()) {
      matchingExpressions.forEach(Element::detach);
      try {
        MCRMetadataManager.update(work);
      } catch (MCRAccessException e) {
        throw new MCRException("Impossible", e);
      }
    }

    Element relationList = expressionWrapper.getOrCreateElement(
        MEIElementConstants.RELATION_LIST);
    List<Element> matchingRelations = relationList.getChildren(MEIElementConstants.RELATION,
            MEIUtils.MEI_NAMESPACE)
        .stream()
        .filter(relationElement -> {
          String target = relationElement
              .getAttributeValue(MEIAttributeConstants.TARGET);
          return target != null && target.equals(work.getId().toString());
        })
        .toList();
    if (!matchingRelations.isEmpty()) {
      matchingRelations.forEach(Element::detach);
      try {
        MCRMetadataManager.update(expression);
      } catch (MCRAccessException e) {
        throw new MCRException("Impossible", e);
      }
    }
  }


    public static class CMOLinkAlreadyExistsException extends Exception {
        public CMOLinkAlreadyExistsException(MCRObjectID source, MCRObjectID target) {
            super("Already exists in work relation: " + source.toString() + " -> " + target.toString());
        }
    }
}
