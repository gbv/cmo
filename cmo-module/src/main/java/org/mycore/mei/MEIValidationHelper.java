package org.mycore.mei;

import java.time.format.DateTimeParseException;
import java.time.temporal.TemporalAccessor;

import org.jdom2.Element;
import org.mycore.common.MCRException;
import org.mycore.datamodel.classifications2.MCRCategoryDAO;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;

public class MEIValidationHelper {

    public static boolean validateDateText(Element dateElement) {
        boolean dateFieldSet = anyDateFieldSet(dateElement);
        if (dateFieldSet) {
            return !isEmpty(dateElement.getTextTrim());
        }
        return true;
    }

    public static boolean validateRelationN(Element element){
        final String n = element.getAttributeValue("n");
        if(!isEmpty(n)){
            return n.matches("^(\\p{L}|\\p{N}|\\p{P}|\\p{S})*$");
        }
        return true;
    }

    public static boolean validateRelation(Element element){
        final String objectID = element.getAttributeValue("target");
        if(!isEmpty(objectID)){
            try {
                final MCRObjectID instance = MCRObjectID.getInstance(objectID);
                return MCRMetadataManager.exists(instance);
            } catch (MCRException e){
                return false;
            }
        }
        return isEmpty(element.getAttributeValue("n"));
    }

    public static boolean validateCalendar(Element dateElement) {
        boolean dateFieldSet = anyDateFieldSet(dateElement);
        if (dateFieldSet) {
            final String calendar = dateElement.getAttributeValue("calendar");
            if (calendar.startsWith("cmo_calendar:")) {
                final MCRCategoryDAO dao = MCRCategoryDAOFactory.getInstance();
                return dao.exist(MCRCategoryID.fromString(calendar));
            }

            return false;
        }
        return true;
    }

    public static boolean validateDate(Element dateElement) {
        boolean approx = Boolean.parseBoolean(dateElement.getAttributeValue("approx"));
        boolean range = Boolean.parseBoolean(dateElement.getAttributeValue("range"));

        String notBefore = dateElement.getAttributeValue("notbefore");
        String notAfter = dateElement.getAttributeValue("notafter");
        String startDate = dateElement.getAttributeValue("startdate");
        String endDate = dateElement.getAttributeValue("enddate");
        String isodate = dateElement.getAttributeValue("isodate");

        if (range) {
            return isValidDateAttr(startDate) && isValidDateAttr(endDate);
        } else if (approx) {
            return isValidDateAttr(notBefore) && isValidDateAttr(notAfter);
        } else {
            return isValidDateAttr(isodate);
        }
    }

    public static boolean validateOneExpression(Element expressionList) {
        return expressionList.getChildren("expression", MEIUtils.MEI_NAMESPACE).stream().anyMatch(e -> {
            final String dataAttr = e.getAttributeValue("codedval");
            return dataAttr != null && !dataAttr.isEmpty();
        });
    }

    private static boolean anyDateFieldSet(Element dateElement) {
        boolean approx = Boolean.parseBoolean(dateElement.getAttributeValue("approx"));
        boolean range = Boolean.parseBoolean(dateElement.getAttributeValue("range"));

        String notBefore = dateElement.getAttributeValue("notbefore");
        String notAfter = dateElement.getAttributeValue("notafter");
        String startDate = dateElement.getAttributeValue("startdate");
        String endDate = dateElement.getAttributeValue("enddate");
        String isodate = dateElement.getAttributeValue("isodate");

        return (approx && (!isEmpty(notBefore) || !isEmpty(notAfter)))
            || (range && (!isEmpty(startDate) || !isEmpty(endDate)))
            || (!range && !approx && !isEmpty(isodate));
    }

    private static boolean isValidDateAttr(String dateAttr) {
        if (isEmpty(dateAttr)) {
            return true;
        }

        try{
            final TemporalAccessor parse = MCRDateHelper.MEI_FORMATTER.parse(dateAttr);
            return true;
        } catch (DateTimeParseException e){
            return false;
        }
    }

    private static boolean isEmpty(String dateAttr) {
        return dateAttr == null || dateAttr.isEmpty();
    }
}
