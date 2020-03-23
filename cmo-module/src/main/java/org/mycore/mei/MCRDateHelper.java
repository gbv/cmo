package org.mycore.mei;

import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.temporal.ChronoField;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.function.Predicate;
import java.util.stream.Collectors;

import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

public class MCRDateHelper {

    protected static DateTimeFormatter MEI_FORMATTER = new DateTimeFormatterBuilder().parseCaseInsensitive()
        .appendValue(ChronoField.YEAR, 4)
        .optionalStart()
            .appendLiteral("-")
            .appendValue(ChronoField.MONTH_OF_YEAR, 2)
            .optionalStart()
                .appendLiteral("-")
                .appendValue(ChronoField.DAY_OF_MONTH, 2)
            .optionalEnd()
        .optionalEnd()
        .parseDefaulting(ChronoField.MONTH_OF_YEAR, 1)
        .parseDefaulting(ChronoField.DAY_OF_MONTH, 1)
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
        dr.setLowBound(dateNode.getAttribute("start"));
        dr.setHighBound(dateNode.getAttribute("end"));

        String solrString = dr.getSOLRString();
        if (solrString != null) {
            return solrString;
        } else {
            String textContent = dateNode.getTextContent();
            textContent = textContent.replace('\u2013', '-');
            if (textContent.contains("-")) {
                String[] dates = textContent.split("-");
                if (dates.length > 0) {
                    dr.setLowBound(dates[0]);
                }
                if (dates.length > 1) {
                    dr.setHighBound(dates[1]);
                }
                return dr.getSOLRString();
            }
            return null;
        }
    }

    /**
     * Parses a mei:date Element and
     * @param meiDate
     * @return
     */
    public static String getSolrDateFieldContentBirth(NodeList meiDate) {
        assert meiDate.getLength() > 0;

        DateRange dr = new DateRange();

        List<String> dates = new ArrayList<>();
        for (int i = 0; i < meiDate.getLength(); i++) {
            Element dateNode = (Element) meiDate.item(i);

            dates.add(dateNode.getAttribute("isodate"));
            dates.add(dateNode.getAttribute("startdate"));
            dates.add(dateNode.getAttribute("notbefore"));
            dates.add(dateNode.getAttribute("start"));
            dates.add(dateNode.getAttribute("enddate"));
            dates.add(dateNode.getAttribute("notafter"));
            dates.add(dateNode.getAttribute("end"));
        }

        Predicate<String> isEmpty = String::isEmpty;
        List<String> list = dates.stream()
            .filter(Objects::nonNull)
            .filter(isEmpty.negate())
            .sorted(sort())
            .collect(Collectors.toList());

        if(list.size()==0){
            return "";
        }

        String s1 = list.stream().findFirst().orElse(null);
        String s2 = list.get(list.size()-1);

        dr.setLowBound(s1);
        dr.setHighBound(s2);

        return dr.getSOLRString();
    }

    private static Comparator<String> sort() {
        return (d1, d2) -> {
            LocalDate ld1 = LocalDate.parse(d1, MEI_FORMATTER);
            if (d1.length() == 4) {
                ld1 = ld1.with(TemporalAdjusters.firstDayOfYear());
            }
            if (d1.length() == 7) {
                ld1 = ld1.with(TemporalAdjusters.firstDayOfMonth());
            }
            LocalDate ld2 = LocalDate.parse(d2, MEI_FORMATTER);
            if (d2.length() == 4) {
                ld2 = ld2.with(TemporalAdjusters.firstDayOfYear());
            }
            if (d2.length() == 7) {
                ld2 = ld2.with(TemporalAdjusters.firstDayOfMonth());
            }
            return ld1.compareTo(ld2);
        };

    }

    public static String currentDateAsString(){
        return new SimpleDateFormat("yyyy-MM-dd").format(new Date());
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
            String lb = this.getLowBound();
            String hb = this.getHighBound();

            if (lb != null && hb != null) {
                if (lb.equals(hb)) {
                    return lb;
                } else {
                    return "[" + lb + " TO " + hb + "]";
                }
            } else if (lb != null) {
                return "[" + lb + " TO *]";
            } else if (hb != null) {
                return "[* TO " + hb + "]";
            } else {
                return null;
            }

        }
    }

}
