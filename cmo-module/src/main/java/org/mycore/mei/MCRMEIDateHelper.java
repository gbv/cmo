package org.mycore.mei;

import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.temporal.ChronoField;
import java.util.Locale;

import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

public class MCRMEIDateHelper {

    private static DateTimeFormatter MEI_FORMATTER = new DateTimeFormatterBuilder().parseCaseInsensitive()
        .appendValue(ChronoField.YEAR, 4)
        .parseDefaulting(ChronoField.MONTH_OF_YEAR, 1)
        .parseDefaulting(ChronoField.DAY_OF_MONTH, 1)
        .optionalStart()
        .appendValue(ChronoField.MONTH_OF_YEAR, 2)
        .optionalStart()
        .appendValue(ChronoField.DAY_OF_MONTH, 2)
        .toFormatter(Locale.ROOT);

    /**
     * Parses a mei:date Element and
     * @param meiDate
     * @return
     */
    public static String getSolrDateFieldContent(NodeList meiDate) {
        assert meiDate.getLength() > 0;

        Element dateNode = (Element) meiDate.item(0);

        DateRange dr = new DateRange();

        String oneDate = dateNode.getAttribute("isodate");
        if (oneDate != null && oneDate.trim().length() > 0) {
            return oneDate;
        }

        dr.setLowBound(dateNode.getAttribute("startdate"));
        dr.setHighBound(dateNode.getAttribute("enddate"));
        dr.setLowBound(dateNode.getAttribute("notbefore"));
        dr.setHighBound(dateNode.getAttribute("notafter"));

        return dr.getSOLRString();
    }

    private static class DateRange {

        String lowBound = null;

        String highBound = null;

        String calendar;

        public DateRange() {
        }

        public DateRange(String lowBound, String highBound, String calendar) {
            this.lowBound = lowBound;
            this.highBound = highBound;
            this.calendar = calendar;
        }

        public String getLowBound() {
            return lowBound;
        }

        public void setLowBound(String lowBound) {
            if (lowBound != null && lowBound.trim().length() > 0) {
                this.lowBound = lowBound;
            }
        }

        public String getHighBound() {
            return highBound;
        }

        public void setHighBound(String highBound) {
            if (highBound != null && highBound.trim().length() > 0) {
                this.highBound = highBound;
            }
        }

        public String getCalendar() {
            return calendar;
        }

        public void setCalendar(String calendar) {
            this.calendar = calendar;
        }

        public String getSOLRString() {
            //LocalDate lowBound = LocalDate.parse(this.lowBound, MEI_FORMATTER);
            //LocalDate highBound = LocalDate.parse(this.highBound, MEI_FORMATTER);

            /*
            if (getLowBound().length() == 4) {
                lowBound = lowBound.with(TemporalAdjusters.firstDayOfYear());
            }

            if (getLowBound().length() == 7) {
                lowBound = lowBound.with(TemporalAdjusters.firstDayOfMonth());
            }

            if (getHighBound().length() == 4) {
                highBound = highBound.with(TemporalAdjusters.lastDayOfYear());
            }

            if (getHighBound().length() == 7) {
                highBound = highBound.with(TemporalAdjusters.lastDayOfMonth());
            }

            LocalTime localTime = LocalTime.of(0, 0, 0, 0);

            String lowBoundString = ZonedDateTime.of(lowBound, localTime, ZoneId.of("UTC"))
                .format(DateTimeFormatter.ISO_INSTANT);
            String highBoundString = ZonedDateTime.of(highBound, localTime, ZoneId.of("UTC"))
                .format(DateTimeFormatter.ISO_INSTANT);

*/

            String lb = this.getLowBound();
            String hb = this.getHighBound();

            if (lb != null && hb != null) {
                if (lb.equals(hb)) {
                    return lb;
                } else {
                    return "[" + lb + " TO " + hb + "]";
                }
            } else if (hb == null) {
                return "[" + lb + " TO *]";
            } else {
                return "[* TO " + hb + "]";
            }

        }
    }

}
