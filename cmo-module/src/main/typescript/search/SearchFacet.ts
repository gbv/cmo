import {FacetHeader, SolrSearchResult} from "../other/Solr";
import {I18N} from "../other/I18N";
import {Classification, ClassificationResolver} from "../other/Classification";
import {Utils} from "../other/Utils";

export class SearchFacetController {

    /** number of buckets solr returns per json facet, the gui shows the first five and hides the rest */
    private static DEFAULT_LIMIT = 30;

    /** name of the nested json facet which leads to the buckets, one is needed per join but the last */
    private static SUB_FACET = "sub";

    /** name of the nested json facet which counts the hits of a bucket, one is needed per join */
    private static HIT_FACET = "hits";

    /** marks the filter queries which belong to a facet, so that they can be told from the ones of the mask */
    private static TAG_PREFIX = "facet_";

    /**
     * Prefix of the parameters which hold the filters of the search. Every counter of every facet needs them,
     * and repeating them there would blow up the length of the url, so each filter is sent once as its own
     * parameter and the facets point at it as {"param": "ff0"}, which is the reference of the json request api.
     * A local parameter reference, {!v=$ff0}, must not be used here: it is a textual substitution inside the
     * local parameters, where a value ends at the first blank, so a filter for "Hezec 5" would be cut in half.
     */
    private static FILTER_PARAM_PREFIX = "ff";

    private view: SearchFacetGUI;
    private facetFields: FacetDescription[];
    private changedHandlerList: Array<() => void> = [];
    private enabled = true;

    constructor(facetContainer: HTMLElement, private translationKeys: any, ...facetFields: FacetDescription[]) {
        if (facetContainer == null || typeof facetContainer == "undefined") {
            this.enabled = false;
            return;
        }
        this.view = new SearchFacetGUI(facetContainer, translationKeys, facetFields, () => {
            this.changedHandlerList.forEach((ch) => ch());
        });
        this.facetFields = facetFields;
    }

    public displayFacet(searchResult: SolrSearchResult) {
        if (this.enabled) {
            this.view.save();
            this.view.displayFacet(this.getFacetHeader(searchResult),
                this.getLocked(searchResult.responseHeader.params));
        }
    }

    public getFacetFields(): Array<string> {
        return this.facetFields.map(description => description.field);
    }

    public addChangeHandler(handler: () => void) {
        this.changedHandlerList.push(handler);
    }

    public removeChangeHandler(handler: () => void) {
        let handlerIndex = this.changedHandlerList.indexOf(handler);
        if (handlerIndex !== -1) {
            this.changedHandlerList.splice(handlerIndex, 1);
        }
    }

    public save() {
        if (this.enabled) {
            this.view.save();
        }
    }

    public reset() {
        if (this.enabled) {
            this.view.reset();
        }
    }

    public getQuery() {
        if (this.enabled) {
            return this.view.getQuery();
        } else {
            return []
        }
    }

    /**
     * Returns the filter query of every selected facet entry. Every entry becomes a filter of its own, so all
     * of them have to be met, as everywhere else in the project. A facet which needs a join states it, so the
     * filter runs against the documents which hold the facet field and not against the hit documents.
     */
    public getFilterQueries(): Array<string> {
        return this.getQuery().map(entry => this.getFilterQuery(entry.field, entry.value));
    }

    /**
     * Returns the additional solr parameters which the json facet api needs, computed from the parameters of
     * the search itself: the query and all of its filter queries, the ones of the facets included, make up the
     * domain the hits of a bucket are counted in. A facet is therefore narrowed by its own selection as well,
     * so the number of an entry is the number of hits the search delivers once it is selected.
     * <p>
     * The result is empty as long as no facet is configured for the json facet api, then the classic facets of
     * the solrconfig are used and nothing has to be sent.
     */
    public getFacetParams(params: Array<Array<string>>): Array<Array<string>> {
        if (!this.enabled || !this.hasJsonFacets()) {
            return [];
        }

        let sentFilters: Array<string> = [];
        for (let param of params) {
            let [ name ] = param;
            if (name != "q" && name != "fq") {
                continue;
            }
            for (let value of param.slice(1)) {
                if (value.trim().length > 0 && sentFilters.indexOf(value) == -1) {
                    sentFilters.push(value);
                }
            }
        }

        // every filter travels once as its own parameter, the facets only point at it
        let filters = sentFilters.map((filter, index) =>
            ({param : SearchFacetController.FILTER_PARAM_PREFIX + index}));

        let jsonFacet = {};
        for (let index = 0; index < this.facetFields.length; index++) {
            let description = this.facetFields[ index ];
            if (description.json == null) {
                continue;
            }
            jsonFacet[ SearchFacetController.getFacetName(index) ] =
                SearchFacetController.buildJsonFacet(description, filters);
        }

        let facetParams = [ [ "json.facet", JSON.stringify(jsonFacet) ] ];
        sentFilters.forEach((filter, index) =>
            facetParams.push([ SearchFacetController.FILTER_PARAM_PREFIX + index, filter ]));
        if (this.facetFields.filter(description => description.json == null).length == 0) {
            // no classic facet left to compute, the ones of the solrconfig would only cost time
            facetParams.push([ "facet", "false" ]);
        }
        return facetParams;
    }

    private hasJsonFacets(): boolean {
        return this.facetFields.filter(description => description.json != null).length > 0;
    }

    /**
     * Builds the json facet of the given description. The buckets are counted in the domain the joins lead to,
     * which is the wrong number for the search: several hits may share one of those documents, and one hit may
     * hold several of them. The real number of hits per bucket is therefore counted by a nested facet which
     * joins back to the hit documents and applies the filters of the search there.
     */
    private static buildJsonFacet(description: FacetDescription, filters: Array<any>): any {
        let json = description.json;
        let joins = json.joins || [];

        let facet: any = {
            type : "terms",
            field : json.facetField,
            limit : json.limit || SearchFacetController.DEFAULT_LIMIT
        };
        if (json.classification != null) {
            facet.prefix = json.classification + ":";
        }

        if (joins.length == 0) {
            return facet;
        }

        facet.domain = {join : joins[ joins.length - 1 ]};
        facet.facet = {};
        facet.facet[ SearchFacetController.HIT_FACET ] =
            SearchFacetController.buildHitCounter(joins, filters);

        // one wrapper per join but the last, each one switching the domain a single step further
        for (let index = joins.length - 2; index >= 0; index--) {
            let wrapper: any = {type : "query", q : "*:*", domain : {join : joins[ index ]}, facet : {}};
            wrapper.facet[ SearchFacetController.SUB_FACET ] = facet;
            facet = wrapper;
        }
        return facet;
    }

    /**
     * Builds the nested facet which counts the hits of a bucket: it walks the joins back, from the documents
     * which hold the facet field to the hit documents, and filters those by the search.
     */
    private static buildHitCounter(joins: Array<SolrJoin>, filters: Array<any>): any {
        let counter = null;
        // built from the inside out: the first join is the last step back, it lands on the hit documents
        for (let index = 0; index < joins.length; index++) {
            let domain: any = {join : {from : joins[ index ].to, to : joins[ index ].from}};
            if (counter == null) {
                // only at the hit documents do the filters of the search make sense
                domain.filter = filters;
            }
            let level: any = {type : "query", q : "*:*", domain : domain};
            if (counter != null) {
                level.facet = {};
                level.facet[ SearchFacetController.HIT_FACET ] = counter;
            }
            counter = level;
        }
        return counter;
    }

    /**
     * Reads the counts of all facets from the search result and returns them in the flat format of the classic
     * facets, [name1, count1, name2, count2], which the gui expects. Facets which are computed by the json
     * facet api are taken from its buckets, the others from the classic facet counts.
     */
    private getFacetHeader(searchResult: SolrSearchResult): FacetHeader {
        let classicFields = (searchResult.facet_counts != null && searchResult.facet_counts.facet_fields != null)
            ? searchResult.facet_counts.facet_fields : {};

        if (!this.hasJsonFacets()) {
            return {facet_fields : classicFields};
        }

        let facetFields = {};
        for (let index = 0; index < this.facetFields.length; index++) {
            let description = this.facetFields[ index ];
            if (description.json == null) {
                if (description.field in classicFields) {
                    facetFields[ description.field ] = classicFields[ description.field ];
                }
                continue;
            }
            let counts = SearchFacetController.readJsonFacet(searchResult.facets, index, description);
            if (counts != null) {
                facetFields[ description.field ] = counts;
            }
        }
        return {facet_fields : facetFields};
    }

    private static readJsonFacet(facets: any, index: number, description: FacetDescription): Array<any> {
        if (facets == null) {
            return null;
        }
        let joins = description.json.joins || [];
        let current = facets[ SearchFacetController.getFacetName(index) ];
        for (let level = 1; level < joins.length && current != null; level++) {
            current = current[ SearchFacetController.SUB_FACET ];
        }
        if (current == null || !("buckets" in current)) {
            return null;
        }

        let entries: Array<{ value: string; count: number }> = [];
        for (let bucket of current.buckets) {
            let value = SearchFacetController.getBucketValue(bucket, description);
            if (value == null) {
                continue;
            }
            entries.push({value : value, count : SearchFacetController.getBucketCount(bucket, joins.length)});
        }
        // the buckets are sorted by the count of the joined documents, the gui shows the count of the hits
        entries.sort((entry1, entry2) => entry2.count - entry1.count);

        let counts = [];
        entries.forEach(entry => {
            counts.push(entry.value);
            counts.push(entry.count);
        });
        return counts;
    }

    private static getBucketValue(bucket: any, description: FacetDescription): string {
        let value = bucket.val;
        let classification = description.json.classification;
        if (classification == null) {
            return value;
        }
        let prefix = classification + ":";
        return value.indexOf(prefix) == 0 ? value.substring(prefix.length) : null;
    }

    private static getBucketCount(bucket: any, joinCount: number): number {
        let current = bucket;
        for (let level = 0; level < joinCount && current != null; level++) {
            current = current[ SearchFacetController.HIT_FACET ];
        }
        return current != null ? current.count : 0;
    }

    private static getFacetName(index: number): string {
        return "f" + index;
    }

    private getDescription(field: string): FacetDescription {
        let matching = this.facetFields.filter(description => description.field == field);
        return matching.length > 0 ? matching[ 0 ] : null;
    }

    /**
     * Returns the filter query for the given entry of a facet. The joins of the facet are stated as local
     * parameters and the outermost one is tagged, so that the filter can be told from the one of a search field
     * of the mask, which looks the same otherwise.
     */
    private getFilterQuery(field: string, value: string): string {
        let description = this.getDescription(field);
        if (description == null || description.json == null) {
            return `${field}:${value}`;
        }
        let json = description.json;
        let facetValue = json.classification != null ? `${json.classification}:${value}` : value;
        return `${SearchFacetController.getJoinPrefix(description)}${json.facetField}:"${facetValue}"`;
    }

    private static getTag(description: FacetDescription): string {
        return SearchFacetController.TAG_PREFIX + description.field;
    }

    private static getJoinPrefix(description: FacetDescription): string {
        let joins = description.json.joins || [];
        let tag = `tag=${SearchFacetController.getTag(description)}`;
        if (joins.length == 0) {
            return `{!${tag}}`;
        }
        // the query parser joins the other way round than the domain of a json facet does
        let prefix = "";
        for (let index = 0; index < joins.length; index++) {
            let localParams = `join from=${joins[ index ].to} to=${joins[ index ].from}`;
            prefix += `{!${localParams}${index == 0 ? " " + tag : ""}}`;
        }
        return prefix;
    }

    /**
     * Splits the given filter query into the facet it belongs to and the selected value, or returns null if it
     * belongs to no facet. Leading local parameters, the joins of a facet for example, are cut off first.
     */
    private getFilterQueryEntry(filterQuery: string): { field: string; value: string } {
        let rest = Utils.splitLocalParams(filterQuery).rest;
        let colonIndex = rest.indexOf(":");
        if (colonIndex == -1) {
            return null;
        }
        let field = rest.substring(0, colonIndex).trim();
        let value = Utils.stripSurrounding(rest.substring(colonIndex + 1, rest.length).trim(), "\"");

        for (let description of this.facetFields) {
            if (description.json == null) {
                if (field == description.field) {
                    return {field : field, value : value};
                }
                // the mask states the same filter as category.top:"<classification>:<category>"
                if (field == "category.top" && value.indexOf(description.field + ":") == 0) {
                    return {
                        field : description.field,
                        value : value.substring(description.field.length + 1)
                    };
                }
                continue;
            }
            if (field != description.json.facetField) {
                continue;
            }
            let classification = description.json.classification;
            if (classification == null) {
                return {field : description.field, value : value};
            }
            if (value.indexOf(classification + ":") == 0) {
                return {field : description.field, value : value.substring(classification.length + 1)};
            }
        }
        return null;
    }

    private getLocked(params: {}): {} {
        let lockObject = {};
        if ("fq" in params) {
            let fqs = params[ "fq" ];
            if (typeof fqs == "string") {
                fqs = [ fqs ];
            }
            for (let fq of fqs) {
                let entry = this.getFilterQueryEntry(fq);
                if (entry == null) {
                    continue;
                }
                if (!(entry.field in lockObject)) {
                    lockObject[ entry.field ] = new Array();
                }
                lockObject[ entry.field ].push(entry.value);
            }
        }
        return lockObject;
    }
}

export class SearchFacetGUI {
    constructor(private _container: HTMLElement, private translationKeys: any, private facetFields: FacetDescription[], private _queryChanged: () => void) {

    }

    private preDisplayContent: Array<HTMLElement> = null;

    public save() {
        let children: Array<HTMLElement> = [].slice.call(this._container.children);
        children.forEach(val => this._container.removeChild(val));
        this.preDisplayContent = children;
    }

    public reset() {
        if (this.preDisplayContent != null) {
            this._container.innerHTML = "";
            this.preDisplayContent.forEach((content) => {
                this._container.appendChild(content);
            });
            this.preDisplayContent = null;
        }
    }

    get facetContainer(): HTMLElement {
        return this._container;
    }

    public displayFacet(header: FacetHeader, lockedList: {}) {
        this._container.innerHTML =
            `<div class="searchFacet"><div data-i18n="cmo.search.facet.filter" class="facetHeader"></div>` +
            this.facetFields
            .map(field => {
                return [ field, header.facet_fields[ field.field ] ];
            })
            .filter(([ field, header ]) => typeof header !== "undefined" && header != null)
            .map(([ field, header ]) => {
                let map = {};
                let keys = [];
                for (let i = 0; i < header.length; i = i + 2) {
                    if (i % 2 == 0) {
                        let key = header[ i ];
                        let value = header[ i + 1 ];
                        map[ key ] = value;
                        keys.push(key);
                    }
                }

                let facetEntries = keys.filter(key => map[ key ] > 0);
                return facetEntries.length > 0 ? `
<div class="facet">
<h4 ${SearchFacetGUI.getHeaderI18N(field)}
${field.type == "class" ? `data-clazz="${field.field}"` : ""} >${field.field}</h4>
<ul>${facetEntries.map((key, index) => this.displayEntry(field, key, map, field.field in lockedList && lockedList[ field.field ].indexOf(key) != -1, index)).join("")}</ul>
${facetEntries.length > 5 ? `<a data-i18n="cmo.search.facet.showMore" data-facet-show="${field.field}"></a>` : ""}
</div>
` : "";
            }).join("")
        + `</div>`;


        I18N.translateElements(this._container);
        ClassificationResolver.putLabels(this._container);
        Array.prototype.slice.call(this._container.querySelectorAll("[data-facet-show]")).forEach((el: Element) => {
            let facetField = el.getAttribute("data-facet-show");

            let show = () => {
                I18N.translate('cmo.search.facet.showLess', (translation) => {
                    el.innerHTML = translation;
                });

                Array.prototype.slice.call(this._container.querySelectorAll(`[data-facet-hidden=${facetField}]`))
                    .sort((el1: Element, el2: Element) => el1.textContent.localeCompare(el2.textContent))
                    .forEach((el: Element) => {
                        el.removeAttribute("data-facet-hidden");
                        el.setAttribute("data-facet-was-hidden", facetField);

                    });

                el.removeEventListener("click", show);
                el.addEventListener("click", hide);
                sort();
            };

            let hide = () => {
                I18N.translate('cmo.search.facet.showMore', (translation) => {
                    el.innerHTML = translation;
                });

                Array.prototype.slice.call(this._container.querySelectorAll(`[data-facet-was-hidden=${facetField}]`)).forEach((el: Element) => {
                    el.removeAttribute("data-facet-was-hidden");
                    el.setAttribute("data-facet-hidden", facetField);
                });
                el.removeEventListener("click", hide);
                el.addEventListener("click", show);
            };

            let sort = () => {
                Array.prototype.slice.call(this._container.querySelectorAll(`[data-facet-entry=${facetField}]`))
                    .sort((el1: Element, el2: Element) => el1.textContent.localeCompare(el2.textContent))
                    .forEach((el) => {
                        let parentElement = el.parentElement;
                        el.remove();
                        parentElement.appendChild(el);
                    })
            };

            el.addEventListener("click", show);

        });

        Array.prototype.slice.call(this._container.querySelectorAll("[data-field]")).forEach((el: Element) => {
            let field = el.getAttribute("data-field");
            let value = el.getAttribute("data-value");

            el.addEventListener("change", () => {
                this._queryChanged();
            });
        });

    }

    public getQuery(): Array<{ field: string; value: string }> {
        return Array.prototype.slice.call(this._container.querySelectorAll("[data-field]:checked")).map(el => {
            let field = el.getAttribute("data-field");
            let value = el.getAttribute("data-value");
            return {field : field, value : value};
        });
    }

    /**
     * Returns the i18n attribute for the heading of a facet: the label of the description if it states one,
     * else the key which a facet of the type translate builds from its field.
     */
    private static getHeaderI18N(field: FacetDescription): string {
        if (field.label != null) {
            return `data-i18n="${field.label}"`;
        }
        return field.type == "translate" ? `data-i18n="${field.translate}${field.field}"` : "";
    }

    public displayEntry(field: FacetDescription, key, map, lock, index) {
        let entry = `<li data-facet-entry="${field.field}" ${index > 5 ? `data-facet-hidden='${field.field}'` : ""}>`;
        entry += ` <input id="facet_${field.field}${key}" type="checkbox" data-field="${field.field}" data-value="${key}" ${lock ? "checked='checked'" : ""}>`;
        entry += `<label for="#facet_${field.field}${key}"> <span`;
        let text = "";
        switch (field.type) {
            case "translate":
                entry += ` data-i18n="${field.translate}${key}" `;
                break;
            case "class":
                entry += ` data-clazz="${field.field}" data-category="${key}"`;
                break;
            case "plain":
                // the value has no label anywhere, it is shown as it stands in the index
                text = Utils.encodeHtmlEntities(key);
                break;
        }
        entry += `>${text}</span> [${map[ key ]}]</label>`;
        entry += "</li>";
        return entry;
    }


}


export interface FacetDescription {
    /**
     * Identifies the facet in the gui and, for a facet of the type class, states the classification whose
     * categories it lists. It has to be usable in a css selector, so it must not hold a dot.
     */
    field: string;
    /** translate, class or plain, decides where the label of an entry comes from */
    type: string;
    /** prefix of the i18n key of an entry, used by the type translate */
    translate?: string;
    /** i18n key of the heading of the facet, needed by the type plain */
    label?: string;
    /** set if solr has to compute the facet with the json facet api, because it needs a join for example */
    json?: JsonFacetDescription;
}

export interface JsonFacetDescription {
    /** field the buckets are built from, for example category.top or tei.facet.rhyme */
    facetField: string;
    /** joins which lead from the hit documents to the documents holding the facet field, in that order */
    joins: Array<SolrJoin>;
    /** classification of the categories, set if the facet field holds them as <classification>:<category> */
    classification?: string;
    /** number of buckets solr returns, the gui shows the first five and hides the rest */
    limit?: number;
}

export interface SolrJoin {
    /** field of the documents the join starts at */
    from: string;
    /** field of the documents the join leads to */
    to: string;
}
