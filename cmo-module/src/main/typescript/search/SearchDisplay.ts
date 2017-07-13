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
        composer : "editor.label.composer"
    };

    public displayResult(result: SolrSearchResult, pageChangeHandler: (newPage: number) => void) {
        let children: Array<HTMLElement> = [].slice.call(this._container.children);
        children.forEach(val => this._container.removeChild(val));
        this.preDisplayContent = children;

        this._container.innerHTML = `
            <h2 data-i18n="${SearchDisplay.SEARCH_LABEL_KEY}"></h2>
             ${this.renderList(result.response.docs)}
             ${this.renderNav(result.response)}
            `;

        Array.prototype.slice.call(this._container.querySelectorAll("[data-switch-page]")).forEach((node) => {
            let page = parseInt((<HTMLElement>node).getAttribute("data-switch-page"), 10);
            node.addEventListener("click", () => {
                pageChangeHandler(page);
            });
        });

        I18N.translateElements(this._container);
        ClassificationResolver.putLabels(this._container);
    }

    public loading() {
        this._container.innerHTML = "<div>Loading...</div>";
    }

    public reset() {
        this._container.innerHTML = "";
        this.preDisplayContent.forEach((content) => {
            this._container.appendChild(content);
        });
        this.preDisplayContent = null;
    }

    private renderList(docs: Array<CMOBaseDocument>): string {
        return docs.map(doc => {
            switch (doc.objectType) {
                case "expression":
                    return this.displayExpression(doc);
                case "source":
                    return this.displaySource(doc);
                case "bibl":
                    return this.displayBibl(doc);
                case "person":
                    return this.displayPerson(doc);
                case "work":
                    return this.displayWork(doc);
            }
        }).join("<hr/>");
    }

    private displayHitTitle(doc: CMOBaseDocument) {
        return ("identifier" in doc) ? ` <a href="${Utils.getBaseURL()}receive/${doc.id}"><h4>${doc.identifier.join(",")}</h4></a>` : "";

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

    private displayExpression(doc: CMOBaseDocument) {
        return `
        ${this.displayHitTitle(doc)}
        ${this.displayMultivalued("title", doc)}
        ${this.displayComposer(doc)}
        ${this.displayCategory(doc, "cmo_makamler")}
        ${this.displayCategory(doc, "cmo_usuler")}
        ${this.displayCategory(doc, "cmo_musictype")}
        `;
    }

    private displaySource(doc: CMOBaseDocument) {
        return `
        ${this.displayHitTitle(doc)}
        `
    }

    private displayBibl(doc: CMOBaseDocument) {
        return `
        ${this.displayHitTitle(doc)}
        `
    }

    private displayPerson(doc: CMOBaseDocument) {
        return `
        ${this.displayHitTitle(doc)}
        `
    }

    private displayWork(doc: CMOBaseDocument) {
        return `
        ${this.displayHitTitle(doc)}
        `
    }

    private displayComposer(doc: CMOBaseDocument) {
        return "composer.ref" in doc ? "<label data-i18n='" + this.fieldLabelMapping[ "composer" ] + "'></label><ul>" + doc[ "composer.ref" ]
                .map(composer => composer.split("|", 2))
                .map(([ composer, ref ]) => `<li><a href="${Utils.getBaseURL()}receive/${ref}">${composer}</a></li>`)
                .join("") + "</ul>" : "";
    }

    // change this to class translate (i18n like)
    private displayCategory(doc: CMOBaseDocument, clazz: string) {
        let rightCategoryField = this.findRightCategoryField(doc, clazz);


        if (typeof rightCategoryField !== "undefined" && rightCategoryField != null) {
            return `
<div class="metadata">
    <label data-clazz="${rightCategoryField.clazz}"></label>
    <span data-clazz="${rightCategoryField.clazz}" data-category="${rightCategoryField.category}" class="value"></span>
</div>
`
        } else {
            return "";
        }
    }

    private findRightCategoryField(doc: CMOBaseDocument, clazz: string) {
        return ("category" in doc ) ? doc.category
            .map(cat => cat.split(":", 4))
            .filter(([ Clazz, category ]) => clazz == Clazz)
            .map(([ Clazz, category, , language, label ]) => {
                return {
                    clazz : Clazz,
                    category : category
                }
            })[ 0 ] : null;
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
