import {Utils} from "../other/utils";
import {I18N} from "../other/I18N";
import {ClassificationResolver} from "../other/Classification";

export class SearchDisplay {
    constructor(private _container: HTMLElement) {

    }

    private preDisplayContent: Array<HTMLElement> = null;
    private static SEARCH_LABEL_KEY = "cmo.search.heading";

    private searchLabel: string = null;

    private fieldLabelMapping = {
        title : "editor.label.title",
        "composer.ref" : "editor.label.composer",
        "author.ref" : "editor.label.author",
        publisher : "editor.label.publisher",
        "publisher.place" : "editor.label.pubPlace",
        "birth.date.content" : "editor.label.lifeData.birth",
        "death.date.content" : "editor.label.lifeData.death",
        "name" : "editor.label.name",
        "publish.date.content" : "editor.label.date",
        "series" : "editor.label.series"

    };

    public displayResult(result: SolrSearchResult, pageChangeHandler: (newPage: number) => void,
                         onResultClickHandler: (doc: CMOBaseDocument, result: SolrSearchResult, hitOnPage) => void) {
        this._container.innerHTML = `
    <div class="row searchResultList">
        <div class="col-md-10 col-md-offset-1">
            <div class="row">
                <div class="col-md-12">
                    <h2>${result.response.numFound} <span data-i18n="${SearchDisplay.SEARCH_LABEL_KEY}"></span></h2>
                </div>
            </div>
             ${this.renderList(result)}
             ${this.renderNav(result)}
        </div>
    </div>`;

        Array.prototype.slice.call(this._container.querySelectorAll("[data-switch-page]")).forEach((node) => {
            let page = parseInt((<HTMLElement>node).getAttribute("data-switch-page"), 10);
            node.addEventListener("click", () => {
                pageChangeHandler(page);
            });
        });


        Array.prototype.slice.call(this._container.querySelectorAll("[data-sd-onclick]")).forEach((node) => {
            let index = parseInt((<HTMLElement>node).getAttribute("data-sd-onclick"), 10);
            node.addEventListener("click", () => {
                onResultClickHandler(result.response.docs[ index ], result, index);
            });
        });

        I18N.translateElements(this._container);
        ClassificationResolver.putLabels(this._container);
    }

    public save() {
        let children: Array<HTMLElement> = [].slice.call(this._container.children);
        children.forEach(val => this._container.removeChild(val));
        this.preDisplayContent = children;
    }

    public loading() {
        this._container.innerHTML = "<div>Loading...</div>";
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

    private renderList(result: SolrSearchResult): string {
        let docs = result.response.docs;
        return docs.map((doc, i) => {
            let index = result.response.start + i;
            switch (doc.objectType) {
                case "expression":
                    return this.displayExpression(doc, index, result);
                case "source":
                    return this.displaySource(doc, index, result);
                case "mods":
                    return this.displayMods(doc, index, result);
                case "person":
                    return this.displayPerson(doc, index, result);
                case "work":
                    return this.displayWork(doc, index, result);
            }
        }).map(innerHTML => `<div class="hit row">${innerHTML}</div>`)
            .join("<hr/>");
    }

    private displayHitTitle(doc: CMOBaseDocument, currentIndex: number, result: SolrSearchResult, fieldResolver = (doc) => ("identifier.type.CMO" in doc) ? doc[ "identifier.type.CMO" ] : ("identifier" in doc) ? doc[ "identifier" ] : doc.id) {
        let field = fieldResolver(doc);
        return `
<div class="col-md-12">
    <a class="hitTitle" data-sd-onclick="${currentIndex}"><span>${field}</span></a>
</div>`;

    }

    private renderNav(response: SolrSearchResult) {
        let rowsParam = response.responseHeader.params[ "rows" ] || 10;
        let rows = Math.min(rowsParam, response.response.numFound);
        let currentPage = Math.floor(response.response.start / rows);
        let maxPages = Math.ceil(response.response.numFound / rows) - 1;

        let firstBefore = Math.max(currentPage - 5, 0);
        let lastAfter = Math.min(currentPage + 6, maxPages);
        let pagesToRender = [];

        for (let currentRendered = firstBefore; currentRendered <= lastAfter; currentRendered++) {
            pagesToRender.push(currentRendered);
        }

        let previousPageAttribute = currentPage !== firstBefore ? "data-switch-page='" + ((currentPage - 1) * rows) + "'" : '';
        let nextPageAttribute = currentPage >= lastAfter ? '' : "data-switch-page='" + ((currentPage + 1) * rows) + "'";

        return pagesToRender.length > 0 ? `
 <div class="row text-center pages"><div class="col-md-12">
    <div class="btn-group" role="group">
        <button type="button" class="btn btn-primary" ${previousPageAttribute}>&lt;</button>
        ${pagesToRender.map(page => `
<button type="button" class="btn ${(page == currentPage) ? 'btn-primary' : 'btn-secondary'}" data-switch-page="${page * rows}">${page + 1}</button>
`).join("")}
         <button type="button" class="btn btn-primary" ${nextPageAttribute}>&gt;</button>
    </div>
    </div>
</div>
` : '';
    }


    private display(name: string, doc: CMOBaseDocument) {
        if (name in doc) {
            let displayValue = (value) => `<span class="value">${value}</span>`;
            return `
<div class="metadata multi">
    <span class="col-md-4 key" data-i18n="${this.fieldLabelMapping[ name ]}"> </span>
    <div class="col-md-8 values">
    ${doc[ name ].map(fieldValue => displayValue(fieldValue)).join("")}
</div></div>`
        }

        return "";
    }

    private displayExpression(doc: CMOBaseDocument, index: number, result: SolrSearchResult) {
        return `
        ${this.displayHitTitle(doc, index, result)}
        ${this.display("title", doc)}
        ${this.displayRefField(doc, "composer.ref")}
        ${this.displayCategory(doc, "cmo_makamler")}
        ${this.displayCategory(doc, "cmo_usuler")}
        ${this.displayCategory(doc, "cmo_musictype")}
        `;
    }

    private displaySource(doc: CMOBaseDocument, index: number, result: SolrSearchResult) {
        return `
        ${this.displayHitTitle(doc, index, result)}
        ${this.display("title", doc)}
        ${this.displayRefField(doc, "editor.ref")}
        ${this.display("publisher", doc)}
        ${this.display("publisher.place", doc)}
        ${this.display("publish.date.content", doc)}
        ${this.display("series", doc)}
        ${this.displayCategory(doc, "cmo_sourceType")}
        ${this.displayCategory(doc, "cmo_contentType")}
        ${this.displayCategory(doc, "cmo_musictype")}
        `
    }

    private displayMods(doc: CMOBaseDocument, index: number, result: SolrSearchResult) {
        return `${this.displayHitTitle(doc, index, result, (doc) => doc[ "mods.title" ])} `
    }

    private displayPerson(doc: CMOBaseDocument, index: number, result: SolrSearchResult) {
        return `
        ${this.displayHitTitle(doc, index, result)}
        ${this.display("name", doc)}
        ${this.display("birth.date.content", doc)}
        ${this.display("death.date.content", doc)}
        `
    }

    private displayWork(doc: CMOBaseDocument, index: number, result: SolrSearchResult) {
        return `
        ${this.displayHitTitle(doc, index, result)}
        `
    }

    private displayRefField(doc: CMOBaseDocument, field: string) {
        return field in doc ? "<div class='metadata'><span class='col-md-4 key' data-i18n='" + this.fieldLabelMapping[ field ] + "'></span>" +
            "<div class='col-md-8 values'>" + doc[ field ]
                .map(composer => composer.split("|", 2))
                .map(([ value, ref ]) => `<span><a href="${Utils.getBaseURL()}receive/${ref}">${value}</a></span>`)
                .join("") + "</div></div>" : "";
    }

    // change this to class translate (i18n like)
    private displayCategory(doc: CMOBaseDocument, clazz: string) {
        let rightCategoryField = this.findRightCategoryField(doc, clazz);


        if (rightCategoryField.length > 0) {
            return `
<div class="metadata">
    <span class="col-md-4 key" data-clazz="${clazz}"></span>
    <div class="col-md-8 values">
     ${rightCategoryField.map(field => `<span data-clazz="${clazz}" data-category="${field.category}" class="value"></span>`).join("")}
    </div>
</div>`;
        } else {
            return "";
        }
    }

    private findRightCategoryField(doc: CMOBaseDocument, clazz: string): Array<{ clazz: string; category: string }> {
        return ("category" in doc ) ? doc.category
            .map(cat => cat.split(":", 4))
            .filter(([ Clazz, category ]) => clazz == Clazz)
            .map(([ Clazz, category, , language, label ]) => {
                return {
                    clazz : Clazz,
                    category : category
                }
            }) : [];
    }
}

export class SolrSearcher {
    constructor() {

    }

    public search(params: Array<Array<string>>, callback: (result: SolrSearchResult) => void) {
        let baseUrl: string = Utils.getBaseURL();
        let xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = () => {
            if (xhttp.readyState === XMLHttpRequest.DONE && xhttp.status == 200) {
                let jsonData = JSON.parse(xhttp.response);
                callback(jsonData);
            }
        };

        let paramPart = params.map((kv) => {
            let [ key ] = kv;
            return kv.slice(1).map(v => `${key}=${encodeURIComponent(v)}`).join("&");
        }).join("&");

        xhttp.open('GET', baseUrl + "servlets/solr/select?" + paramPart + "&wt=json", true);
        xhttp.send();
    }
}

export interface SolrSearchResult {
    responseHeader: ResponseHeader;
    response: Response;
    facet_counts: FacetHeader;
}

export interface FacetHeader {
    /**
     * Contains the type as key and as value a array [name1,count1, name2,count2]
     */
    facet_fields: any;
}

export interface ResponseHeader {
    status: number;
    QTime: number;
    params: {};
}

export interface Response {
    rows?: number;
    numFound: number;
    start: number;
    docs: Array<CMOBaseDocument>;
}

export interface CMOBaseDocument {
    objectKind: "mycoreobject";
    id: string;
    returnId?: string;
    objectProject: string;
    objectType: string
    modified: string;
    created: string;
    parent?: string;
    derCount: number;
    hasFiles: boolean;
    identifier?: Array<string>;
    "composer.ref"?: Array<string>;
    lyricist: Array<string>;
    incip: Array<string>;
    category: Array<string>;
}
