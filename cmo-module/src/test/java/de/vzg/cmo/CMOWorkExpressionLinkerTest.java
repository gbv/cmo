package de.vzg.cmo;

import static org.junit.Assert.*;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.jdom2.output.XMLOutputter;
import org.junit.Test;
import org.mycore.access.MCRAccessException;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.MCRSystemUserInformation;
import org.mycore.common.MCRStoreTestCase;
import org.mycore.datamodel.classifications2.MCRCategory;
import org.mycore.datamodel.classifications2.MCRCategoryDAO;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.utils.MCRXMLTransformer;
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

public class CMOWorkExpressionLinkerTest extends MCRStoreTestCase {

  public static final String[] IDS = {"cmo_expression_00000001",
      "cmo_expression_00000002",
      "cmo_expression_00000003",
      "cmo_work_00000001",
      "cmo_work_00000002",
      "cmo_work_00000003"};

  private static final String BASE_URL = "https://127.0.0.1/";

  private CMOWorkExpressionLinker linker;

  private static final Logger LOGGER = LogManager.getLogger();


  @Override
  protected Map<String, String> getTestProperties() {
    Map<String, String> testProperties = super.getTestProperties();
    testProperties.put("MCR.baseurl", BASE_URL);

    return testProperties;
  }

  @Override
    public void setUp() throws Exception {
        super.setUp();

      try(InputStream is = CMOWorkExpressionLinkerTest.class.getClassLoader().getResourceAsStream("MEI/classification/state.xml")) {
        Document doc = new SAXBuilder().build(is);
        MCRCategory category = MCRXMLTransformer.getCategory(doc);
        MCRCategoryDAO dao = MCRCategoryDAOFactory.getInstance();
        if(dao.exist(category.getId())) {
          dao.replaceCategory(category);
        } else {
          dao.addCategory(null, category);
        }
      }

        MCRSessionMgr.getCurrentSession().setUserInformation(MCRSystemUserInformation.getSuperUserInstance());
        prepareTestData(IDS);
        linker = new CMOWorkExpressionLinker();
        MCRFrontendUtil.prepareBaseURLs(BASE_URL);

  }

    private void prepareTestData(String ...ids) throws IOException, JDOMException, MCRAccessException {
      for(String id: ids) {
        MCRObject obj = loadObject(id);
        storeObject(obj);
        MCRMetadataManager.retrieveMCRObject(MCRObjectID.getInstance(id));
      }
    }

    private void storeObject(MCRObject obj) throws MCRAccessException {
      MCRMetadataManager.update(obj);
    }



    private MCRObject loadObject(String id) throws IOException, JDOMException {
        try (InputStream is = CMOWorkExpressionLinkerTest.class.getClassLoader()
            .getResourceAsStream("MEI/link/work_expression/" + id + ".xml")) {

          byte[] bytes = is.readAllBytes();
          return new MCRObject(bytes, false);
        }
    }



    @Override
    public void tearDown() throws Exception {
        for(String id: IDS) {
          prepareTestData(IDS);
          MCRMetadataManager.deleteMCRObject(MCRObjectID.getInstance(id));
        }
        super.tearDown();
    }

    @Test
    public void linkWorkAndExpressionAddsRelationAndExpressionEntryWithLabels() throws Exception {
        MCRObject work = retrieve("cmo_work_00000001");
        MCRObject expression = retrieve("cmo_expression_00000001");

        linker.linkWorkAndExpression(work, List.of(expression));


        MEIExpressionWrapper expressionWrapper = getExpressionWrapper("cmo_expression_00000001");

        LOGGER.info(new XMLOutputter().outputString(expressionWrapper.getRoot()));

        List<RealizationOf> realizations = expressionWrapper.getRealizations();
        assertEquals(1, realizations.size());
        RealizationOf realization = realizations.get(0);
        assertEquals("cmo_work_00000001", realization.target());
        assertEquals("test1", realization.label());

        List<Element> expressionElements = getExpressionElements("cmo_work_00000001");
        assertEquals(1, expressionElements.size());
        Element expressionElement = expressionElements.get(0);
        assertEquals("cmo_expression_00000001",
            expressionElement.getAttributeValue(MEIAttributeConstants.CODEDVAL));
        assertEquals(BASE_URL + "receive/", expressionElement.getAttributeValue("auth.uri"));
        assertEquals("Example 1", expressionElement.getAttributeValue(MEIAttributeConstants.LABEL));
    }

    @Test
    public void linkWorkAndExpressionAddsRelationWithoutLabelsWhenIdentifiersMissing()
        throws Exception {
        MCRObject work = retrieve("cmo_work_00000002");
        MCRObject expression = retrieve("cmo_expression_00000002");

        linker.linkWorkAndExpression(work, List.of(expression));

        MEIExpressionWrapper expressionWrapper = getExpressionWrapper("cmo_expression_00000002");
        List<RealizationOf> realizations = expressionWrapper.getRealizations();
        assertEquals(1, realizations.size());
        RealizationOf realization = realizations.get(0);
        assertEquals("cmo_work_00000002", realization.target());
        assertNull(realization.label());

        List<Element> expressionElements = getExpressionElements("cmo_work_00000002");
        assertEquals(1, expressionElements.size());
        Element expressionElement = expressionElements.get(0);
        assertEquals("cmo_expression_00000002",
            expressionElement.getAttributeValue(MEIAttributeConstants.CODEDVAL));
        assertEquals(BASE_URL + "receive/", expressionElement.getAttributeValue("auth.uri"));
        assertNull(expressionElement.getAttributeValue(MEIAttributeConstants.LABEL));
    }

    @Test
    public void linkWorkWithoutIdentifierToExpressionWithIdentifierUsesExpressionLabel() throws Exception {
        MCRObject work = retrieve("cmo_work_00000003");
        MCRObject expression = retrieve("cmo_expression_00000003");

        linker.linkWorkAndExpression(work, List.of(expression));

        MEIExpressionWrapper expressionWrapper = getExpressionWrapper("cmo_expression_00000003");
        List<RealizationOf> realizations = expressionWrapper.getRealizations();
        assertEquals(1, realizations.size());
        RealizationOf realization = realizations.get(0);
        assertEquals("cmo_work_00000003", realization.target());
        assertNull(realization.label());

        List<Element> expressionElements = getExpressionElements("cmo_work_00000003");
        assertEquals(1, expressionElements.size());
        Element expressionElement = expressionElements.get(0);
        assertEquals("cmo_expression_00000003",
            expressionElement.getAttributeValue(MEIAttributeConstants.CODEDVAL));
        assertEquals("Example 3", expressionElement.getAttributeValue(MEIAttributeConstants.LABEL));
    }

    @Test
    public void linkWorkWithIdentifierToExpressionWithoutIdentifierKeepsRelationLabelOnly()
        throws Exception {
        MCRObject work = retrieve("cmo_work_00000001");
        MCRObject expression = retrieve("cmo_expression_00000002");

        linker.linkWorkAndExpression(work, List.of(expression));

        MEIExpressionWrapper expressionWrapper = getExpressionWrapper("cmo_expression_00000002");
        List<RealizationOf> realizations = expressionWrapper.getRealizations();
        assertEquals(1, realizations.size());
        RealizationOf realization = realizations.get(0);
        assertEquals("cmo_work_00000001", realization.target());
        assertEquals("test1", realization.label());

        List<Element> expressionElements = getExpressionElements("cmo_work_00000001");
        assertEquals(1, expressionElements.size());
        Element expressionElement = expressionElements.get(0);
        assertEquals("cmo_expression_00000002",
            expressionElement.getAttributeValue(MEIAttributeConstants.CODEDVAL));
        assertNull(expressionElement.getAttributeValue(MEIAttributeConstants.LABEL));
    }

    @Test
    public void linkWorkAndExpressionHandlesMultipleExpressionsAndAvoidsDuplicates()
        throws Exception {
        linker.linkWorkAndExpression(
            retrieve("cmo_work_00000001"),
            List.of(retrieve("cmo_expression_00000001"), retrieve("cmo_expression_00000002")));

        MEIWorkWrapper workWrapperAfterFirstLink = getWorkWrapper("cmo_work_00000001");
        List<Element> expressionElements = getExpressionElements(workWrapperAfterFirstLink);
        assertEquals(2, expressionElements.size());
        List<String> codedValues = expressionElements.stream()
            .map(element -> element.getAttributeValue(MEIAttributeConstants.CODEDVAL))
            .collect(Collectors.toList());
        assertTrue(codedValues.containsAll(List.of("cmo_expression_00000001", "cmo_expression_00000002")));

        linker.linkWorkAndExpression(
            retrieve("cmo_work_00000001"),
            List.of(retrieve("cmo_expression_00000001")));

        MEIExpressionWrapper expressionWrapper = getExpressionWrapper("cmo_expression_00000001");
        assertEquals(1, expressionWrapper.getRealizations().size());

        List<Element> expressionElementsAfterSecondLink = getExpressionElements("cmo_work_00000001");
        assertEquals(2, expressionElementsAfterSecondLink.size());
    }

    @Test
    public void linkWorkAndExpressionThrowsWhenExpressionAlreadyLinkedToDifferentWork() throws Exception {
        linker.linkWorkAndExpression(
            retrieve("cmo_work_00000001"),
            List.of(retrieve("cmo_expression_00000001")));

        CMOWorkExpressionLinker.CMOLinkAlreadyExistsException exception = assertThrows(
            CMOWorkExpressionLinker.CMOLinkAlreadyExistsException.class,
            () -> linker.linkWorkAndExpression(
                retrieve("cmo_work_00000002"),
                List.of(retrieve("cmo_expression_00000001"))));
        assertTrue(exception.getMessage().contains("cmo_expression_00000001"));
    }

    @Test
    public void unlinkWorkAndExpressionRemovesRelationAndExpressionEntry() throws Exception {
        linker.linkWorkAndExpression(
            retrieve("cmo_work_00000001"),
            List.of(retrieve("cmo_expression_00000001")));

        linker.unlinkWorkAndExpression(
            retrieve("cmo_work_00000001"),
            retrieve("cmo_expression_00000001"));

        MEIExpressionWrapper expressionWrapper = getExpressionWrapper("cmo_expression_00000001");
        assertTrue(expressionWrapper.getRealizations().isEmpty());
        List<Element> expressionElements = getExpressionElements("cmo_work_00000001");
        assertTrue(expressionElements.isEmpty());
    }

    @Test
    public void unlinkWorkAndExpressionWithoutExistingLinkDoesNothing() throws Exception {
        linker.unlinkWorkAndExpression(
            retrieve("cmo_work_00000001"),
            retrieve("cmo_expression_00000002"));

        MEIExpressionWrapper expressionWrapper = getExpressionWrapper("cmo_expression_00000002");
        assertTrue(expressionWrapper.getRealizations().isEmpty());
        List<Element> expressionElements = getExpressionElements("cmo_work_00000001");
        assertTrue(expressionElements.isEmpty());
    }

    @Test
    public void validateExpressionWithoutRealizationReturnsTrue() {
        MEIExpressionWrapper expressionWrapper = getExpressionWrapper("cmo_expression_00000002");
        boolean result = linker.validateExpression(
            expressionWrapper,
            MCRObjectID.getInstance("cmo_expression_00000002"));
        assertTrue(result);
    }

    @Test
    public void validateExpressionWithExistingRealizationReturnsFalse() throws Exception {
        linker.linkWorkAndExpression(
            retrieve("cmo_work_00000001"),
            List.of(retrieve("cmo_expression_00000001")));

        MEIExpressionWrapper expressionWrapper = getExpressionWrapper("cmo_expression_00000001");
        boolean result = linker.validateExpression(
            expressionWrapper,
            MCRObjectID.getInstance("cmo_expression_00000001"));
        assertFalse(result);
    }

    private MCRObject retrieve(String id) {
        return MCRMetadataManager.retrieveMCRObject(MCRObjectID.getInstance(id));
    }

    private MEIExpressionWrapper getExpressionWrapper(String id) {
        return MEIWrapper.getWrapper(retrieve(id), MEIExpressionWrapper.class);
    }

    private MEIWorkWrapper getWorkWrapper(String id) {
        return MEIWrapper.getWrapper(retrieve(id), MEIWorkWrapper.class);
    }

    private List<Element> getExpressionElements(String workId) {
        MEIWorkWrapper workWrapper = getWorkWrapper(workId);
        return getExpressionElements(workWrapper);
    }

    private List<Element> getExpressionElements(MEIWorkWrapper workWrapper) {
        Element expressionList = workWrapper.getElement(MEIElementConstants.EXPRESSION_LIST);
        if (expressionList == null) {
            return List.of();
        }
        return expressionList.getChildren(MEIElementConstants.EXPRESSION, MEIUtils.MEI_NAMESPACE);
    }
}
