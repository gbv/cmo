import {Utils} from "../other/Utils";
import {I18N} from "../other/I18N";
import {ClassificationResolver} from "../other/Classification";
import {CMOBaseDocument, SolrSearcher, SolrSearchResult} from "../other/Solr";
import {BasketUtil} from "./BasketUtil";
import {SolrDocumentHelper} from "./SolrDocumentHelper";
import {BasketStore} from "./BasketStore";

export class SearchDisplay {
    constructor(private _container: HTMLElement) {

    }

    private preDisplayContent: Array<HTMLElement> = null;
    private static SEARCH_LABEL_KEY = "cmo.search.heading";
    private static SORT_LABEL_KEY = "editor.search.sort";
    private static  ROWS_LABEL_KEY = "cmo.search.rows";

    private searchLabel: string = null;

    private fieldLabelMapping = {
        title : "editor.label.title",
        "composer.ref" : "editor.label.composer",
        "author.ref" : "editor.label.author",
        "editor" : "editor.label.editor",
        "editor.ref" : "editor.label.editor",
        publisher : "editor.label.publisher",
        "publisher.place" : "editor.label.pubPlace",
        "birth.date.content" : "editor.label.lifeData.birth",
        "death.date.content" : "editor.label.lifeData.death",
        "name" : "editor.label.name",
        "publish.date.content" : "editor.label.date",
        "series" : "editor.label.series"

    };

    private sortOptions = {
        "editor.search.sort.relevance" : "score",
        "editor.search.sort.title" : "displayTitleSort",
    };

    public displayResult(result: SolrSearchResult, descriptions:Array<{key?:string, value?:string, classValue?:string, i18nvalue?: string}>, pageChangeHandler: (newPage: number, field: string, asc: boolean, rows: number) => void,
                         onResultClickHandler: (doc: CMOBaseDocument, result: SolrSearchResult, hitOnPage) => void, extra: HTMLElement) {
        let getSort = (result: SolrSearchResult) => {
            if ("sort" in result.responseHeader.params) {
                let sortParams = result.responseHeader.params["sort"];
                return (Array.isArray(sortParams) ? sortParams[0] : sortParams).split(" ");
            }
            return ["score", "asc"];
        };
        let sort = getSort(result);
        const divClass = "search-extra";

        this._container.innerHTML = `
    <div class="row searchResultList">
        <div class="col-10 offset-1">
            ${(extra !== null) ? `<div class='row'><div class='col-12 ${divClass}'></div></div>` : ""}
            <div class="row">
                <div class="col-12">
                    ${this.displaySeachDescription(descriptions)}
                </div>
            </div>
            <div class="row header">
                <div class="col-6">
                    <span>${result.response.numFound} <span data-i18n="${SearchDisplay.SEARCH_LABEL_KEY}"></span></span>
                </div>
                <div class="col-6">
                    <a data-i18n="cmo.basket.add.all" data-basket-add-all="true"></a>
                </div>
                </div>
                <div class="row">
                <div class="col-6">
                    <span data-i18n="${SearchDisplay.SORT_LABEL_KEY}"></span>
                    <select data-sort-select="">
                        ${this.getSortOptions(sort[ 0 ])}
                    </select>
                    <span class="ascdesc">
                           ${sort[ 1 ] == "desc" ? "&darr;" : "&uarr;"}             
                    </span>
                </div>
                <div class="col-6">
                    <span data-i18n="${SearchDisplay.ROWS_LABEL_KEY}"></span>
                    <select data-rows-select="">
                        <option value="10">10</option>
                        <option value="25">25</option>
                        <option value="50">50</option>
                        <option value="100">100</option>
                    </select>
                </div>
            </div>
             ${this.renderList(result)}
             ${this.renderNav(result)}
        </div>
    </div>`;

        if (extra !== null) {
            (<HTMLElement>this._container.querySelector("." + divClass)).appendChild(extra);
        }

        (<HTMLSelectElement>this._container.querySelector("[data-sort-select]")).value = sort[ 0 ];
        let sortSelect = <HTMLSelectElement>this._container.querySelector("[data-sort-select]");
        let ascdesc = <HTMLSpanElement>this._container.querySelector(".ascdesc");

        Array.prototype.slice.call(this._container.querySelectorAll("[data-switch-page]")).forEach((node) => {
            let page = parseInt((<HTMLElement>node).getAttribute("data-switch-page"), 10);
            node.addEventListener("click", () => {
                pageChangeHandler(page,sortSelect.value, ascdesc.innerHTML.trim() !== "↓", parseInt(rowsSelect.value));
            });
        });


        Array.prototype.slice.call(this._container.querySelectorAll("[data-sd-onclick]")).forEach((node) => {
            let index = parseInt((<HTMLElement>node).getAttribute("data-sd-onclick"), 10);
            node.addEventListener("click", () => {
                onResultClickHandler(result.response.docs[ index ], result, index);
            });
        });


        let sortChange = () => {
            pageChangeHandler(0,sortSelect.value, ascdesc.innerHTML.trim() !== "↓", parseInt(rowsSelect.value));
        };
        sortSelect.addEventListener("change", sortChange);
        ascdesc.addEventListener("click", () => {
            if (ascdesc.innerHTML.trim() == "↓") {
                ascdesc.innerHTML = "&uarr;";
            } else {
                ascdesc.innerHTML = "&darr;";
            }
            sortChange();
        });

        let rowsSelect = <HTMLSelectElement>this._container.querySelector("[data-rows-select]");
        rowsSelect.value = (result.responseHeader.params["rows"]||10)+"";
        rowsSelect.addEventListener("change", ()=>{
            pageChangeHandler(0,sortSelect.value, ascdesc.innerHTML.trim() !== "↓", parseInt(rowsSelect.value));
        });

        let addAllButton = <HTMLElement>this._container.querySelector("[data-basket-add-all]");

        addAllButton.addEventListener("click", () => {
            let newParams = [];

            let hasRows = false;
            for (let paramKey in result.responseHeader.params) {
                if (result.responseHeader.params.hasOwnProperty(paramKey)) {
                    let paramVal = result.responseHeader.params[ paramKey ];


                    switch (paramKey) {
                        case "rows":
                            hasRows=true;
                            newParams.push([ "rows", "9999999" ]);
                            break;
                        case "start":
                            newParams.push([ "start", "0" ]);
                            break;
                        default:
                            if (Array.isArray(paramVal)) {
                                newParams.push([ paramKey ].concat(paramVal));
                            } else {
                                newParams.push([ paramKey, paramVal ]);
                            }
                    }

                }
            }

            if(!hasRows){
                newParams.push([ "rows", "9999999" ]);
            }


            new SolrSearcher().search(newParams, (resultForBasket) => {
                let basketStore = BasketStore.getInstance();
                let idArr = [];
                for (let doc of resultForBasket.response.docs) {
                    idArr.push(doc.id);
                }
                basketStore.addAll(idArr);
            });

        });

        I18N.translateElements(this._container);
        BasketUtil.activateLinks(this._container);
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
            let index = i;
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
            .join("\n");
    }

    private displayHitTitle(doc: CMOBaseDocument, currentIndex: number, result: SolrSearchResult, fieldResolver = (doc) => {
        let field = ("identifier.type.CMO" in doc) ? doc[ "identifier.type.CMO" ] : ("identifier" in doc) ? doc[ "identifier" ] : doc.id;

        if(field instanceof Array){
            return field.join(",")
        } else {
            return field;
        }
    }) {
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
 <div class="row text-center pages"><div class="col-12">
    <div class="btn-group" role="group">
        <button type="button" class="btn btn-primary" ${previousPageAttribute}>&lt;</button>
        ${pagesToRender.map(page => `
<button type="button" class="btn ${(page == currentPage) ? 'btn-primary' : 'btn-light'}" data-switch-page="${page * rows}">${page + 1}</button>
`).join("")}
         <button type="button" class="btn btn-primary" ${nextPageAttribute}>&gt;</button>
    </div>
    </div>
</div>
` : '';
    }


    private display(name: string, doc: CMOBaseDocument) {
        if (name in doc) {
            let displayValue = (value) => `<span class="value">${Utils.encodeHtmlEntities(value)}</span>`;
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
        let solrDocumentHelper = new SolrDocumentHelper(doc);

        let badges = `
        <span class="col-md-12">
            ${this.displayCategoryBadge(doc, "cmo_makamler", 0, 1)}
            ${this.displayCategoryBadge(doc, "cmo_usuler", 0, 1)}
            ${this.displayCategoryBadge(doc, "cmo_musictype", 1)}
            ${this.displayCategoryBadge(doc, "cmo_litform")}
        </span>
        `;


        return `
        ${badges}
        ${this.displayHitTitle(doc, index, result, (doc)=> {
            return doc[ "displayTitle" ];
        })}
        <span class="col-md-12">${doc["identifier.type.CMO"]}</span>
        <span class="col-md-12">${this.displayCombinedField(doc, 'lyricist')} 
        ${this.displayCombinedField(doc, 'composer')}</span>
        ${solrDocumentHelper.getMultiValue("incip.normalized")
            .map(incip => `<span class="col-md-12">${incip.join(", ")}</span>`)
            .orElse("")}
        ${this.displayBasketButton(doc)}
        `;
    }

    private displayBasketButton(doc: CMOBaseDocument){
        return `<span class="col-md-12 text-right"><a data-basket="${doc.id}"></a></span>`;
    }

    private displayCombinedField(doc: CMOBaseDocument, field: string) {
        let alreadyInRef = [];

        let refEntries = (doc[ `${field}.ref` ] || [])
            .map(composer => composer.split("|", 2))
            .map(([ value, ref ]) => {
                alreadyInRef.push(value);
                return `<span><a href="${Utils.getBaseURL()}receive/${ref}">${Utils.encodeHtmlEntities(value)}</a></span>`
            })
            .concat((doc[ field ] || [])
                .filter((field) => alreadyInRef.indexOf(field) === -1)
                .map(field => `<span>${Utils.encodeHtmlEntities(field)}</span>`))
            .join(", ");


        return refEntries;

    }

    private displaySource(doc: CMOBaseDocument, index: number, result: SolrSearchResult) {
        let print = doc[ "category.top" ].indexOf("cmo_sourceType:Printed_source") === 0;
        let _ = (arr) => arr || [];
        let solrDocumentHelper = new SolrDocumentHelper(doc);

        let badges = `
        <span class="col-md-12">
            ${this.displayCategoryBadge(doc, "cmo_sourceType")}
            ${this.displayCategoryBadge(doc, "cmo_contentType")}
            ${this.displayCategoryBadge(doc, "cmo_notationType")}
        </span>
        `;

        if (print) {
            let line1 = this.displayCombinedField(doc, 'editor');
            let line2 = solrDocumentHelper.getMultiValue("series", "title.type.sub", "biblScope").map(vals => {
                return vals.join(", ");
            }).orElse("");
            let line31 = solrDocumentHelper.getMultiValue("publisher.place").map(vals => vals.join(", ") + ": ").orElse("");
            let line32 = solrDocumentHelper.getMultiValue("publisher").map(vals => vals.join(", ") + ", ").orElse("");
            let line33 = solrDocumentHelper.getMultiValue("publish.date.content").map(vals => vals.join(", ")).orElse("");

            return `
        ${badges}
        ${this.displayHitTitle(doc, index, result, (doc) => doc[ "title.type.main" ])}
        <span class="col-md-12">${doc["identifier.type.CMO"]}</span>
        <span class="col-md-12">${line1}</span>
        <span class="col-md-12">${line2}</span>
        <span class="col-md-12">
            ${line31 + line32 + line33}
        </span>
        ${this.displayBasketButton(doc)}`;
        } else {
            let line = `<div class="col-md-12">${solrDocumentHelper
                .getSingleValues("history.Creation.persName", "history.Creation.geogName", "history.Creation.date.content")
                .join(", ")}</div>`;


            let line2 = solrDocumentHelper.getSingleValue("identifier.type.RISM")
                .map(id => `RISM: ${id}`)
                .map(id => `<span class="col-md-12">${id}</span>`)
                .orElse("");

            let line3 = solrDocumentHelper.getSingleValues("repo.corpName", "repo.identifier.shelfmark").join(", ");

            return `${badges}
                ${this.displayHitTitle(doc, index, result, (doc) => doc[ "displayTitle" ])}
                ${line}
                ${line2}
                <span class="col-md-12">${line3}</span>
                ${this.displayBasketButton(doc)}
            `;
        }
    }

    private displayMods(doc: CMOBaseDocument, index: number, result: SolrSearchResult) {
        let solrDocumentHelper = new SolrDocumentHelper(doc);
        let fieldsLine2 = solrDocumentHelper.getSingleValues("mods.author", "mods.editor.this");

        let first = p => p[ 0 ];
        let publisher = solrDocumentHelper.getSingleValue("mods.publisher.this");
        let place = solrDocumentHelper.getSingleValue("mods.place.this");
        let date = solrDocumentHelper.getSingleValue("mods.dateIssued");

        let leftPart = place.and(publisher, (place, publisher) => place + ": " + publisher)
            .or(place)
            .or(publisher);

        leftPart.and(date, (leftPart, date) => leftPart + ", " + date)
            .or(date, leftPart)
            .ifPresent((complete) => {
                fieldsLine2.push(complete);
            });

        let fieldsLine3 = [];

        let leftPart2 = solrDocumentHelper
            .getSingleValues("mods.title.host", "mods.name.host", "mods.place.host").join(", ");

        if (leftPart2.length > 0) {
            fieldsLine3.push(leftPart2);
        }

        let rightPart2 = solrDocumentHelper
            .getSingleValues("mods.publisher.host", "mods.dateIssued.host", "mods.extent.host").join(", ");
        if (rightPart2.length > 0) {
            fieldsLine3.push(rightPart2);
        }


        return `${doc["cmoType"] == "source-mods" ? `<span class="col-md-12"><span data-i18n="editor.cmo.select.source-mods" class="badge badge-pill"></span></span>`: ``}
               ${this.displayHitTitle(doc, index, result, (doc) => doc[ "displayTitle" ])}   
               ${doc["cmoType"] == "source-mods" && "mods.identifier.CMO" in doc ? `<span class="col-md-12">${doc["mods.identifier.CMO"]}</span>` : ``}
                  ${fieldsLine2.length > 0 ? `<span class="col-md-12">${fieldsLine2.join(" | ")}</span>` : ""}
                  ${fieldsLine3.length > 0 ? `<span class="col-md-12">${fieldsLine3.join(" : ")}</span>` : ""}
                 ${this.displayBasketButton(doc)}`;
    }

    private displayPerson(doc: CMOBaseDocument, index: number, result: SolrSearchResult) {
        let solrDocumentHelper = new SolrDocumentHelper(doc);
        let cmoName = doc[ "displayTitle" ];
        let birth = solrDocumentHelper.getSingleValue("birth.date.content").map(b => "*" + b);
        let death = solrDocumentHelper.getSingleValue("death.date.content").map(d => "†" + d);

        return `
        ${this.displayHitTitle(doc, index, result, (doc) => cmoName)}
        ${solrDocumentHelper.getMultiValue("name")
            .filter(name => name != cmoName)
            .map(arr => `<span class="col-md-12">${arr.join(", ")}
            </span>`)
            .orElse("")}</span>
        <span class="col-md-12">
            ${
            birth
                .and(death, (b, d) => `${b} | ${d}`)
                .or(() => birth, () => death)
                .orElse("")
            } 
        </span>
        ${this.displayBasketButton(doc)}
        `
    }

    private displayWork(doc: CMOBaseDocument, index: number, result: SolrSearchResult) {
        return `
        ${this.displayHitTitle(doc, index, result)}
        ${this.displayBasketButton(doc)}
        `
    }

    private displayRefField(doc: CMOBaseDocument, field: string) {
        return field in doc ? "<div class='metadata'><span class='col-md-4 key' data-i18n='" + this.fieldLabelMapping[ field ] + "'></span>" +
            "<div class='col-md-8 values'>" + doc[ field ]
                .map(composer => composer.split("|", 2))
                .map(([ value, ref ]) => `<span><a href="${Utils.getBaseURL()}receive/${ref}">${Utils.encodeHtmlEntities(value)}</a></span>`)
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


    // change this to class translate (i18n like)
    private displayCategoryBadge(doc: CMOBaseDocument, clazz: string, start = 0, endMinus = 0) {
        let rightCategoryField = this.findRightCategoryField(doc, clazz);


        if (rightCategoryField.length > 0) {
            let realStart = Math.min(start, rightCategoryField.length);
            let realEnd = Math.max(realStart, rightCategoryField.length - endMinus);


            return rightCategoryField
                .slice(realStart, realEnd)
                .map(field => `<span data-clazz="${clazz}" data-category="${field.category}" class="badge badge-pill"></span>`).join("");

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

    private getSortOptions(sort: string) {
        let options = [];
        for (let i18n in this.sortOptions) {
            let field = this.sortOptions[i18n];
            options.push(`<option data-i18n="${i18n}" value="${field}">${i18n}</option>`);
        }
        return options.join();
    }



    private displaySeachDescription(descriptions:Array<{key?:string, value?:string, classValue?:string, i18nvalue?: string}>) {
        return descriptions.map(descr => {
            if("value" in descr && typeof descr.value != "undefined" && descr.value!=null){
                return `<span data-i18n="${descr.key}"></span>:${descr.value}`;
            }
            if("classValue" in descr && typeof descr.classValue != "undefined" && descr.classValue!=null){
                return `<span data-clazz="${descr.classValue.split(":")[0]}"></span>:<span data-clazz="${descr.classValue.split(":")[0]}" data-category="${descr.classValue.split(":")[1]}"></span>`;
            }
            if("i18nvalue" in descr && typeof descr.i18nvalue != "undefined" && descr.i18nvalue!=null){
                return `<span data-i18n="${descr.key}"></span>:<span data-i18n="${descr.i18nvalue}"></span>`;

            }
            if("key" in descr && typeof descr.key != "undefined" && descr.key!=null){
                return `<span data-i18n="${descr.key}"></span>`;

            }

        }).map(html=> `<span class="badge badge-pill badge-secondary">${html}</span>`).join(" ");
    }
}

