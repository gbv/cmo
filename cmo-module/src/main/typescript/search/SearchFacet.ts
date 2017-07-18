import {FacetHeader, SolrSearchResult} from "./SearchDisplay";
import {I18N} from "../other/I18N";
import {Classification, ClassificationResolver} from "../other/Classification";
export class SearchFacetController {

    private view: SearchFacetGUI;
    private facetFields: FacetDescription[];
    private changedHandlerList: Array<() => void> = [];

    constructor(facetContainer: HTMLElement, private translationKeys: any, ...facetFields: FacetDescription[]) {
        this.view = new SearchFacetGUI(facetContainer, translationKeys, facetFields, () => {
            this.changedHandlerList.forEach((ch) => ch());
        });
        this.facetFields = facetFields;
    }

    public displayFacet(searchResult: SolrSearchResult) {
        this.view.save();
        this.view.displayFacet(searchResult.facet_counts, this.getLocked(searchResult.responseHeader.params));
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

    public getQuery() {
        return this.view.getQuery();
    }

    private getLocked(params: {}): {} {
        let lockObject = {};
        if ("fq" in params) {
            let fqs = params[ "fq" ];
            if (typeof fqs == "string") {
                fqs = [ fqs ];
            }
            for (let fq of fqs) {
                let [ field, value ] = fq.split(":", 2);
                if (this.facetFields.map(field => field.field).indexOf(field) !== -1) {
                    if (!(field in lockObject)) {
                        lockObject[ field ] = new Array();
                    }
                    lockObject[ field ].push(value);
                }
            }
        }
        return lockObject;
    }
}

export class SearchFacetGUI {
    constructor(private _container: HTMLElement, private translationKeys: any, private facetFields: FacetDescription[], private _queryChanged: () => void) {

    }

    private preDisplayContent: Array<HTMLElement>;

    public save() {
        let children: Array<HTMLElement> = [].slice.call(this._container.children);
        children.forEach(val => this._container.removeChild(val));
        this.preDisplayContent = children;
    }

    public reset() {
        this._container.innerHTML = "";
        this.preDisplayContent.forEach((content) => {
            this._container.appendChild(content);
        });
        this.preDisplayContent = null;
    }

    get facetContainer(): HTMLElement {
        return this._container;
    }

    public displayFacet(header: FacetHeader, lockedList: {}) {
        this._container.innerHTML = this.facetFields
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
<h4 ${field.type == "translate" ? ` data-i18n="${field.translate}${field.field}"` : ""}
${field.type == "class" ? `data-clazz="${field.field}"` : ""} >${field.field}</h4> 
<ul>${facetEntries.map((key, index) => this.displayEntry(field, key, map, field.field in lockedList && lockedList[ field.field ].indexOf(key) != -1, index)).join("")}</ul>
${facetEntries.length > 5 ? `<a data-i18n="cmo.search.facet.showMore" data-facet-show="${field.field}"></a>` : ""}
</div>
` : "";
            }).join("");


        I18N.translateElements(this._container);
        ClassificationResolver.putLabels(this._container);
        Array.prototype.slice.call(this._container.querySelectorAll("[data-facet-show]")).forEach((el: Element) => {
            let facetField = el.getAttribute("data-facet-show");

            el.addEventListener("click", () => {
                el.remove();
                Array.prototype.slice.call(this._container.querySelectorAll(`[data-facet-hidden=${facetField}]`)).forEach((el: Element) =>
                    el.removeAttribute("data-facet-hidden")
                )
            });

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


    public displayEntry(field: FacetDescription, key, map, lock, index) {
        let entry = `<li ${index > 5 ? `data-facet-hidden='${field.field}'` : ""}>`;
        entry += ` <input id="facet_${field.field}${key}" type="checkbox" data-field="${field.field}" data-value="${key}" ${lock ? "checked='checked'" : ""}>`;
        entry += `<label for="#facet_${field.field}${key}"> <span`;
        switch (field.type) {
            case "translate":
                entry += ` data-i18n="${field.translate}${key}" `;
                break;
            case "class":
                entry += ` data-clazz="${field.field}" data-category="${key}"`;
                break;
        }
        entry += `></span> (${map[ key ]})</label>`;
        entry += "</li>";
        return entry;
    }


}


export interface FacetDescription {
    field: string;
    type: string;
    translate?: string;
}
