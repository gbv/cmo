import {SolrSearcher, SolrSearchResult} from "../other/Solr";
import {UserInputParser, Utils} from "../other/Utils";

/**
 * Drop down which suggests the values of a solr field while the user types, so that a search field can be
 * filled with a value which really stands in the index. The corpus holds transcriptions of Ottoman names and
 * codes of sources, "Hâfız-ı Şîrâzî" or "TMKlii", and nobody types those correctly by heart.
 * <p>
 * The suggestions come from an {@link AutoCompleteSource}, which knows where the values are and marks the part
 * of them the user has typed.
 */
export class AutoComplete {

    /** number of entries the drop down shows */
    public static DEFAULT_LIMIT = 10;

    /** number of characters needed before solr is asked, a single one would match half of the corpus */
    private static MIN_LENGTH = 2;

    /** milliseconds the typing rests before solr is asked */
    private static DELAY = 250;

    /** marks the entry the keyboard stands on */
    private static CURRENT_CLASS = "current";

    /** hides the drop down, the class is styled with the list itself */
    private static INACTIVE_CLASS = "inactive";

    /** counts the drop downs of the page, so that every list can be named in an aria attribute */
    private static count = 0;

    private list: HTMLUListElement;
    private listId: string;
    private values: Array<string> = [];
    private timeout: number = null;

    /** number of the last request, so that an answer which arrives late does not overwrite a newer one */
    private requestCount = 0;

    /**
     * @param input the field which is completed, the drop down is put right behind it
     * @param source where the suggestions come from
     * @param taken called when the user chooses an entry, so that the search can be repeated
     */
    constructor(private input: HTMLInputElement, private source: AutoCompleteSource,
                private taken: () => void = null) {
        this.listId = "autocomplete_" + (++AutoComplete.count);
        this.list = <HTMLUListElement>document.createElement("ul");
        this.list.classList.add("autocomplete-list");
        this.list.classList.add(AutoComplete.INACTIVE_CLASS);
        this.list.id = this.listId;
        this.list.setAttribute("role", "listbox");
        this.input.parentElement.insertBefore(this.list, this.input.nextSibling);

        // the drop down of the browser would cover ours
        this.input.setAttribute("autocomplete", "off");
        this.input.setAttribute("role", "combobox");
        this.input.setAttribute("aria-autocomplete", "list");
        this.input.setAttribute("aria-controls", this.listId);
        this.input.setAttribute("aria-expanded", "false");

        this.input.addEventListener("keydown", (event: KeyboardEvent) => this.keyDown(event));
        this.input.addEventListener("input", () => this.request());
        this.input.addEventListener("focus", () => this.request());
        this.input.addEventListener("blur", () => window.setTimeout(() => this.show(false), 200));
    }

    /**
     * Handles the keys which belong to the drop down: the arrows walk through the entries, enter takes the one
     * the keyboard stands on and escape closes the list. Everything else is left to the field itself.
     */
    private keyDown(event: KeyboardEvent) {
        if (!this.isOpen()) {
            return;
        }
        switch (event.key) {
            case "Escape":
                event.preventDefault();
                this.show(false);
                break;
            case "Enter":
                let current = this.getCurrent();
                if (current != null) {
                    event.preventDefault();
                    this.take(current.textContent);
                } else {
                    this.show(false);
                }
                break;
            case "ArrowDown":
                event.preventDefault();
                this.moveCurrent(1);
                break;
            case "ArrowUp":
                event.preventDefault();
                this.moveCurrent(-1);
                break;
        }
    }

    /** Asks solr for the suggestions of what stands in the field, once the typing rests. */
    private request() {
        if (this.timeout !== null) {
            window.clearTimeout(this.timeout);
            this.timeout = null;
        }
        let text = this.input.value.trim();
        if (text.length < AutoComplete.MIN_LENGTH) {
            this.show(false);
            return;
        }
        this.timeout = window.setTimeout(() => {
            this.timeout = null;
            let request = ++this.requestCount;
            this.source.suggest(text, (suggestions) => {
                if (request == this.requestCount) {
                    this.display(suggestions);
                }
            });
        }, AutoComplete.DELAY);
    }

    private display(suggestions: Array<AutoCompleteSuggestion>) {
        this.values = suggestions.map(suggestion => suggestion.value);
        if (this.values.length == 0) {
            this.show(false);
            return;
        }

        this.list.innerHTML = suggestions.map((suggestion, index) =>
            `<li id="${this.listId}_${index}" role="option">${suggestion.html}</li>`).join("");
        let entries: Array<HTMLElement> = [].slice.call(this.list.children);
        entries.forEach((entry, index) => {
            /* the value is taken from the array, the entry itself carries the marks of the match */
            entry.addEventListener("click", () => this.take(this.values[ index ]));
        });
        this.show(true);
    }

    private take(value: string) {
        this.input.value = value;
        this.show(false);
        if (this.taken != null) {
            this.taken();
        }
    }

    private moveCurrent(step: number) {
        let entries: Array<HTMLElement> = [].slice.call(this.list.children);
        if (entries.length == 0) {
            return;
        }
        let current = this.getCurrent();
        let next = current == null
            ? (step > 0 ? 0 : entries.length - 1)
            : (entries.indexOf(current) + step + entries.length) % entries.length;
        if (current != null) {
            this.setCurrent(current, false);
        }
        this.setCurrent(entries[ next ], true);
    }

    private setCurrent(entry: HTMLElement, current: boolean) {
        if (current) {
            entry.classList.add(AutoComplete.CURRENT_CLASS);
            entry.setAttribute("aria-selected", "true");
            this.input.setAttribute("aria-activedescendant", entry.id);
        } else {
            entry.classList.remove(AutoComplete.CURRENT_CLASS);
            entry.removeAttribute("aria-selected");
            this.input.removeAttribute("aria-activedescendant");
        }
    }

    private getCurrent(): HTMLElement {
        return <HTMLElement>this.list.querySelector("." + AutoComplete.CURRENT_CLASS);
    }

    private isOpen(): boolean {
        return !this.list.classList.contains(AutoComplete.INACTIVE_CLASS);
    }

    private show(show: boolean) {
        this.input.setAttribute("aria-expanded", show + "");
        if (show) {
            this.list.classList.remove(AutoComplete.INACTIVE_CLASS);
        } else {
            this.list.classList.add(AutoComplete.INACTIVE_CLASS);
            let current = this.getCurrent();
            if (current != null) {
                this.setCurrent(current, false);
            }
        }
    }
}

/** One entry of the drop down. */
export interface AutoCompleteSuggestion {
    /** value which is written into the field when the entry is chosen */
    value: string;
    /** html of the entry, the part the user has typed marked, everything else escaped */
    html: string;
}

export interface AutoCompleteSource {
    /** Looks for the values which match the given text and hands them to the callback. */
    suggest(text: string, callback: (suggestions: Array<AutoCompleteSuggestion>) => void): void;
}

/**
 * Base of the sources which read their suggestions out of solr. The mark of the match is the em element solr
 * uses for a highlight, so both sources can be shown the same way.
 */
export abstract class SolrSuggestSource implements AutoCompleteSource {

    protected static MARK_START = "<em>";

    protected static MARK_END = "</em>";

    protected searcher = new SolrSearcher();

    /**
     * @param fields fields the values are read from, without the joins of the search field they belong to
     * @param filter narrows the documents the values are taken from, "objectType:person" for example
     * @param limit number of suggestions
     */
    constructor(protected fields: Array<string>, protected filter: string = null,
                protected limit: number = AutoComplete.DEFAULT_LIMIT) {
    }

    public abstract suggest(text: string, callback: (suggestions: Array<AutoCompleteSuggestion>) => void): void;

    /** Returns the value of a marked snippet, so the text without the marks solr has put around the match. */
    protected static getValue(snippet: string): string {
        return snippet.split(SolrSuggestSource.MARK_START).join("")
            .split(SolrSuggestSource.MARK_END).join("");
    }

    /**
     * Escapes a marked snippet for the drop down: everything is escaped first and the marks are put back
     * afterwards, so that a value which holds an angle bracket cannot bring markup of its own into the list.
     */
    protected static getHtml(snippet: string): string {
        let escaped = Utils.encodeHtmlEntities(snippet);
        return escaped.split(Utils.encodeHtmlEntities(SolrSuggestSource.MARK_START))
            .join(SolrSuggestSource.MARK_START)
            .split(Utils.encodeHtmlEntities(SolrSuggestSource.MARK_END))
            .join(SolrSuggestSource.MARK_END);
    }

    /** Marks the part of the given value which the typed text stands for, ignoring the case as solr does. */
    protected static mark(value: string, text: string): string {
        let at = value.toLowerCase().indexOf(text.toLowerCase());
        if (at == -1) {
            return Utils.encodeHtmlEntities(value);
        }
        let end = at + text.length;
        return Utils.encodeHtmlEntities(value.substring(0, at))
            + SolrSuggestSource.MARK_START + Utils.encodeHtmlEntities(value.substring(at, end))
            + SolrSuggestSource.MARK_END + Utils.encodeHtmlEntities(value.substring(end));
    }

    protected static getTokens(text: string): Array<string> {
        return text.split(" ").filter(token => token.trim().length > 0);
    }

    /**
     * Puts the white space of a value into one blank per gap. Some records of the corpus hold a name over
     * several lines, which the drop down would show with the indentation of the metadata file.
     */
    protected static collapse(text: string): string {
        return text.replace(/\s+/g, " ").trim();
    }
}

/**
 * Suggests the values of stored text fields, "tei.author.lyricist" or "name" for example. The values are read
 * out of the highlighting of solr, which returns exactly the values of a document which match and leaves the
 * other ones of a multi valued field out. Matching is therefore done by the analyzer of the field, so a value
 * of the corpus is found although the user types it without its diacritics: "hafiz" finds "Hâfız-ı Şîrâzî".
 */
export class SolrHighlightSuggestSource extends SolrSuggestSource {

    /** documents solr looks at, one of them may hold several of the values */
    private static ROWS = 200;

    /** values solr returns per field of a document */
    private static SNIPPETS = 10;

    public suggest(text: string, callback: (suggestions: Array<AutoCompleteSuggestion>) => void) {
        let params = [
            [ "q", this.getQuery(text) ],
            [ "fl", "id" ],
            [ "rows", SolrHighlightSuggestSource.ROWS + "" ],
            [ "hl", "on" ],
            [ "hl.fl", this.fields.join(",") ],
            [ "hl.snippets", SolrHighlightSuggestSource.SNIPPETS + "" ],
            /* the facets of the solrconfig would only cost time, the drop down shows none */
            [ "facet", "false" ]
        ];
        if (this.filter != null) {
            params.push([ "fq", this.filter ]);
        }
        this.searcher.search(params, result => callback(this.read(result, text)));
    }

    /**
     * Builds the query which looks for the typed text in all fields of this source. Every word has to be met,
     * the last one is the word the user is still typing, so it counts as the beginning of a word as well.
     * <p>
     * Both are asked for, the word and the beginning of it, because the text fields of the corpus are stemmed
     * while a query for the beginning of a word is not analyzed at all: only "dede" finds the term of "Dede",
     * only "dede*" finds "Dedeler".
     */
    private getQuery(text: string): string {
        let tokens = SolrSuggestSource.getTokens(text);
        return tokens.map((token, index) => {
            let value = UserInputParser.escapeSpecialCharacters(token);
            let alternatives = [];
            this.fields.forEach(field => {
                alternatives.push(`${field}:${value}`);
                if (index == tokens.length - 1) {
                    alternatives.push(`${field}:${value}*`);
                }
            });
            return `(${alternatives.join(" OR ")})`;
        }).join(" AND ");
    }

    private read(result: SolrSearchResult, text: string): Array<AutoCompleteSuggestion> {
        let highlighting = result.highlighting || {};
        let suggestions: Array<AutoCompleteSuggestion> = [];
        let taken = {};

        for (let id in highlighting) {
            if (!highlighting.hasOwnProperty(id)) {
                continue;
            }
            let fields = highlighting[ id ];
            for (let field in fields) {
                if (!fields.hasOwnProperty(field)) {
                    continue;
                }
                let snippets = fields[ field ];
                (snippets instanceof Array ? snippets : [ snippets ]).forEach(marked => {
                    if (marked == null || typeof marked == "undefined") {
                        return;
                    }
                    /* the white space of a text field means nothing to its analyzer, and less in a list */
                    let snippet = SolrSuggestSource.collapse(marked);
                    let value = SolrSuggestSource.getValue(snippet);
                    if (value.trim().length == 0 || taken[ value ] === true) {
                        return;
                    }
                    taken[ value ] = true;
                    suggestions.push({value : value, html : SolrSuggestSource.getHtml(snippet)});
                });
            }
        }

        return SolrHighlightSuggestSource.sort(suggestions, text).slice(0, this.limit);
    }

    /**
     * Sorts the suggestions the way a reader looks for them: what the user has typed comes first, and of two
     * values the shorter one is the one they are more likely after. Solr sorts its documents by score, which
     * says nothing about the single value of a multi valued field.
     */
    private static sort(suggestions: Array<AutoCompleteSuggestion>, text: string): Array<AutoCompleteSuggestion> {
        let start = text.toLowerCase();
        let rank = (suggestion: AutoCompleteSuggestion) =>
            suggestion.value.toLowerCase().indexOf(start) == 0 ? 0 : 1;
        return suggestions.sort((suggestion1, suggestion2) => {
            let byStart = rank(suggestion1) - rank(suggestion2);
            if (byStart != 0) {
                return byStart;
            }
            let byLength = suggestion1.value.length - suggestion2.value.length;
            return byLength != 0 ? byLength : suggestion1.value.localeCompare(suggestion2.value);
        });
    }
}

/**
 * Suggests the values of a string field, "tei.witness" or "tei.rdg.type" for example. Those hold their value
 * untouched and as a whole, so the values themselves are searched instead of the documents: solr counts them
 * as a facet and only keeps the ones which contain the typed text, the case ignored. The values are codes and
 * english words, which a reader types as they stand, so no analyzer is needed for them.
 */
export class SolrFacetSuggestSource extends SolrSuggestSource {

    public suggest(text: string, callback: (suggestions: Array<AutoCompleteSuggestion>) => void) {
        let params = [
            [ "q", "*:*" ],
            [ "rows", "0" ],
            [ "facet", "true" ],
            [ "facet.contains", text ],
            [ "facet.contains.ignoreCase", "true" ],
            [ "facet.limit", this.limit + "" ],
            [ "facet.mincount", "1" ]
        ];
        this.fields.forEach(field => params.push([ "facet.field", field ]));
        if (this.filter != null) {
            params.push([ "fq", this.filter ]);
        }
        this.searcher.search(params, result => callback(this.read(result, text)));
    }

    /**
     * Reads the values out of the facet counts, which come in the flat format [value1, count1, value2, ...]
     * and are sorted by their count, so the value which brings the most hits stands at the top of the list.
     */
    private read(result: SolrSearchResult, text: string): Array<AutoCompleteSuggestion> {
        let facetFields = (result.facet_counts != null && result.facet_counts.facet_fields != null)
            ? result.facet_counts.facet_fields : {};
        let suggestions: Array<AutoCompleteSuggestion> = [];
        let taken = {};

        for (let field in facetFields) {
            if (!facetFields.hasOwnProperty(field)) {
                continue;
            }
            let counts = facetFields[ field ];
            for (let index = 0; index < counts.length; index = index + 2) {
                let value = counts[ index ];
                if (value == null || value.trim().length == 0 || taken[ value ] === true) {
                    continue;
                }
                taken[ value ] = true;
                suggestions.push({value : value, html : SolrSuggestSource.mark(value, text)});
            }
        }
        return suggestions.slice(0, this.limit);
    }
}
