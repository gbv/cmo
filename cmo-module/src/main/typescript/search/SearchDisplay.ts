import {Utils} from "../other/utils";
import {I18N} from "../other/I18N";
import {ClassificationResolver} from "../other/Classification";
export class SearchDisplay {
    constructor(private _container: HTMLElement) {

    }

    private preDisplayContent: Array<HTMLElement> = null;
    private static SEARCH_LABEL_KEY = "cmo.search";

    private searchLabel: string = null;

    private fieldLabelMapping = {
        title : "editor.label.title",
        "composer.ref" : "editor.label.composer",
        "author.ref":"editor.label.author",
        publisher : "editor.label.publisher",
        "publisher.place":"editor.label.place",
    };

    public displayResult(result: SolrSearchResult, pageChangeHandler: (newPage: number) => void) {
        this._container.innerHTML = `
    <div class="row">
        <div class="col-md-10 col-md-offset-1">
            <h2 data-i18n="${SearchDisplay.SEARCH_LABEL_KEY}"></h2>
             ${this.renderList(result)}
             ${this.renderNav(result.response)}
        </div>
    </div>`;

        Array.prototype.slice.call(this._container.querySelectorAll("[data-switch-page]")).forEach((node) => {
            let page = parseInt((<HTMLElement>node).getAttribute("data-switch-page"), 10);
            node.addEventListener("click", () => {
                pageChangeHandler(page);
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
                case "bibl":
                    return this.displayBibl(doc, index, result);
                case "person":
                    return this.displayPerson(doc, index, result);
                case "work":
                    return this.displayWork(doc, index, result);
            }
        }).join("<hr/>");
    }

    private displayHitTitle(doc: CMOBaseDocument, currentIndex: number, result: SolrSearchResult) {
        let param = "";

        for (let i in result.responseHeader.params) {
            if (i == "wt" || i == "start" || i == "rows") {
                continue;
            }

            if (result.responseHeader.params[ i ] instanceof Array) {
                param += result.responseHeader.params[ i ].map(param => `${i}=${param}`).join("&") + "&";
            } else {
                param += `${i}=${ result.responseHeader.params[ i ]}&`;
            }
        }

        if (param[ param.length - 1 ] == "&") {
            param = param.substring(0, param.length - 1);
        }

        param += `&start=${currentIndex}&rows=1&origrows=${result.responseHeader.params[ "rows" ] || 10}&XSL.Style=browse`;

        return ` <a href='${Utils.getBaseURL()}servlets/solr/select?${param}'><h4>${("identifier" in doc) ? doc.identifier.join(",") : doc.id}</h4></a>`;

    }

    private renderNav(response: Response) {
        let rows = response.rows || 10;
        let currentPage = Math.floor(response.start / rows);
        let maxPages = Math.ceil(response.numFound / rows);

        let firstBefore = Math.max(currentPage - 5, 0);
        let lastAfter = Math.min(currentPage + 6, maxPages);
        let pagesToRender = [];

        for (let currentRendered = firstBefore; currentRendered < lastAfter; currentRendered++) {
            pagesToRender.push(currentRendered);
        }

        let previousPageAttribute = currentPage !== firstBefore ? "data-switch-page='" + ((currentPage - 1) * rows) + "'" : '';
        let nextPageAttribute = currentPage !== lastAfter ? "data-switch-page='" + ((currentPage + 1) * rows) + "'" : '';

        return `
 <div class="text-center">
    <div class="btn-group" role="group">
        <button type="button" class="btn btn-primary" ${previousPageAttribute}>&lt;</button>
        ${pagesToRender.map(page => `
<button type="button" class="btn ${(page == currentPage) ? 'btn-primary' : 'btn-secondary'}" data-switch-page="${page * rows}">${page + 1}</button>
`).join("")}
         <button type="button" class="btn btn-primary" ${nextPageAttribute}>&gt;</button>
    </div>
</div>
`;
    }


    private displayMultivalued(name: string, doc: CMOBaseDocument) {
        if (name in doc) {
            let displayValue = (value) => `<span class="value">${value}</span>`;
            return `
<div class="metadata multi">
    <label data-i18n="${this.fieldLabelMapping[ name ]}"> </label>
    ${doc[ name ].map(fieldValue => displayValue(fieldValue)).join("")}
</div>`
        }

        return "";
    }

    private displayExpression(doc: CMOBaseDocument, index: number, result: SolrSearchResult) {
        return `
        ${this.displayHitTitle(doc, index, result)}
        ${this.displayMultivalued("title", doc)}
        ${this.displayRefField(doc, "composer.ref")}
        ${this.displayCategory(doc, "cmo_makamler")}
        ${this.displayCategory(doc, "cmo_usuler")}
        ${this.displayCategory(doc, "cmo_musictype")}
        `;
    }

    private displaySource(doc: CMOBaseDocument, index: number, result: SolrSearchResult) {
        return `
        ${this.displayHitTitle(doc, index, result)}
        ${this.displayRefField(doc, "editor.ref")}
        ${this.displayMultivalued("publisher", doc)}
        ${this.displayMultivalued("publisher.place", doc)}
        ${this.displayCategory(doc, "cmo_sourceType")}
        ${this.displayCategory(doc, "cmo_contentType")}
        ${this.displayCategory(doc, "cmo_musictype")}
        
        `
    }

    private displayBibl(doc: CMOBaseDocument, index: number, result: SolrSearchResult) {
        return `
        ${this.displayHitTitle(doc, index, result)}
        `
    }

    private displayPerson(doc: CMOBaseDocument, index: number, result: SolrSearchResult) {
        return `
        ${this.displayHitTitle(doc, index, result)}
        `
    }

    private displayWork(doc: CMOBaseDocument, index: number, result: SolrSearchResult) {
        return `
        ${this.displayHitTitle(doc, index, result)}
        `
    }

    private displayRefField(doc: CMOBaseDocument, field: string) {
        return field in doc ? "<label data-i18n='" + this.fieldLabelMapping[ field ] + "'></label><ul>" + doc[ field ]
                .map(composer => composer.split("|", 2))
                .map(([ value, ref ]) => `<li><a href="${Utils.getBaseURL()}receive/${ref}">${value}</a></li>`)
                .join("") + "</ul>" : "";
    }

    // change this to class translate (i18n like)
    private displayCategory(doc: CMOBaseDocument, clazz: string) {
        let rightCategoryField = this.findRightCategoryField(doc, clazz);


        if (rightCategoryField.length > 0) {
            return `
<div class="metadata">
    <label data-clazz="${clazz}"></label>
    ${rightCategoryField.map(field => `<span data-clazz="${clazz}" data-category="${field.category}" class="value"></span>`).join(", ")}
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
            return kv.slice(1).map(v => `${key}=${v}`).join("&");
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
