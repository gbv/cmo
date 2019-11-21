import {BasketStore} from "./BasketStore";
import {CMOBaseDocument} from "../other/Solr";
import {Utils} from "../other/Utils";
import {I18N} from "../other/I18N";
import {ClassificationResolver} from "../other/Classification";
import {BasketUtil} from "./BasketUtil";

export class BasketDisplay {
    constructor(private _container: HTMLElement) {

    }

    private basket = BasketStore.getInstance();
    private preDisplayContent: Array<HTMLElement> = null;

    private static mergeLinkFields = (...arr:string[][])=> {
        let namesLinkMap = {};
        arr.forEach((namesRefsArray:string[])=>{
            (namesRefsArray||[]).forEach(nameAndRef=>{
                if(typeof nameAndRef!="undefined"){
                    let [name, ref] = nameAndRef.split("|");
                    if (!(name in namesLinkMap) || typeof namesLinkMap[name] == 'undefined') {
                        namesLinkMap[name] = ref;
                    }
                }
            })
        });
        return namesLinkMap;
    };

    private static TABLE = {
        "expression" : {
            "editor.label.identifier" : (doc: CMOBaseDocument) => doc[ "identifier.type.CMO" ][ 0 ],
            "editor.label.title" : (doc: CMOBaseDocument) =>
                `<a href="${Utils.getBaseURL()}receive/${doc[ "id" ]}">${Utils.encodeHtmlEntities(doc[ "displayTitle" ] + "")}</a>`,
            "editor.label.composer" : (doc: CMOBaseDocument) => {
                let composerMap = BasketDisplay.mergeLinkFields(doc["composer.display.ref"]);
                let html = [];
                for(const composer in composerMap){
                    if(typeof composerMap[composer] != "undefined"){
                        html.push(`<a href="${Utils.getBaseURL()}receive/${composerMap[composer]}">${composer}</a>`)
                    } else {
                        html.push(composer);
                    }
                }
                return html.join("; ")
            },
            "cmo.genre" : (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_musictype"),
            "cmo.makam" : (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_makamler"),
            "cmo.usul" : (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_usuler"),
            "editor.label.incip" : (doc:CMOBaseDocument) => (doc["incip.normalized"]||[]).join(", ")
        },
        "person" : {
            "editor.label.name": (doc: CMOBaseDocument) => ((doc["name"] instanceof Array) ? doc["name"] : [doc["name"]]).map((name) => `<a href="${Utils.getBaseURL()}receive/${doc["id"]}">${name || ""}</a>`).join("<br/>"),
            "editor.label.lifeData.birth" : (doc: CMOBaseDocument) => (doc[ "birth.date.content" ] || [ "" ])[ 0 ] || "",
            "editor.label.lifeData.death" : (doc: CMOBaseDocument) => (doc[ "death.date.content" ] || [ "" ])[ 0 ] || ""
        },
        "source" : {
            "editor.label.identifier" : (doc: CMOBaseDocument) => `<a href="${Utils.getBaseURL()}receive/${doc[ "id" ]}">${doc[ "identifier.type.CMO" ][ 0 ]}</a>`,
            "editor.label.identifier.shelfmark" : (doc)=> doc[ "repo.identifier.shelfmark" ] || "",
            "editor.label.corpName": (doc)=> doc["repo.corpName.library"] || "",
            "editor.label.title" : (doc: CMOBaseDocument) =>
                `<a href="${Utils.getBaseURL()}receive/${doc[ "id" ]}">${Utils.encodeHtmlEntities((doc[ "displayTitle" ] || "") + "")}</a>`,

            "editor.label.publisher" : (doc: CMOBaseDocument) => doc[ "publisher" ] || "",
            "editor.label.editorAndAuthor": (doc: CMOBaseDocument) =>{
                let authorMap = BasketDisplay.mergeLinkFields(doc["author.display.ref"]);
                let editorMap = BasketDisplay.mergeLinkFields(doc["editor.display.ref"]);
                let html = [];
                for(const author in authorMap){
                    if(typeof authorMap[author] != "undefined"){
                        html.push(`<a href="${Utils.getBaseURL()}receive/${authorMap[author]}">${author}</a>`)
                    } else {
                        html.push(author);
                    }
                }
                for(const editor in editorMap){
                    if(typeof editorMap[editor] != "undefined"){
                        html.push(`<a href="${Utils.getBaseURL()}receive/${editorMap[editor]}">${editor}</a>`)
                    } else {
                        html.push(editor);
                    }
                }
                return html.join("; ");
            },
            "editor.label.pubPlace" : (doc: CMOBaseDocument) => doc[ "publisher.place" ] || "",
            "editor.label.publishingDate" : (doc: CMOBaseDocument) => doc[ "publish.date.content" ] || "",
            "editor.label.series" : (doc: CMOBaseDocument) => (doc[ "series" ] || []).join(", "),
            "cmo.sourceType" : (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_sourceType"),
            "cmo.contentType" : (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_contentType"),
            "cmo.notationType" : (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_notationType")
        },
        "source-mods" : {
            "editor.label.identifier" : (doc) => (doc[ "mods.identifier" ] || [])
                .map(identifier=> `<a href="${Utils.getBaseURL()}receive/${doc["id"]}">${identifier}</a>`).join("<br/>"),
            "editor.label.title" : (doc: CMOBaseDocument) =>
                `<a href="${Utils.getBaseURL()}receive/${doc[ "id" ]}">${Utils.encodeHtmlEntities(doc[ "displayTitle" ] + "")}</a>`,
            "editor.label.pubPlace": (doc: CMOBaseDocument) => doc[ "mods.place" ] || "",
            "editor.label.publishingDate": (doc: CMOBaseDocument) => doc[ "mods.dateIssued" ] || "",

        },
        "edition-mods" : {
            "editor.label.identifier" : (doc) => (doc[ "mods.identifier" ] || [])
                .map(identifier=> `<a href="${Utils.getBaseURL()}receive/${doc["id"]}">${identifier}</a>`).join("<br/>"),
            "editor.label.title" : (doc: CMOBaseDocument) =>
                `<a href="${Utils.getBaseURL()}receive/${doc[ "id" ]}">${Utils.encodeHtmlEntities(doc[ "displayTitle" ] + "")}</a>`,
            "editor.label.pubPlace": (doc: CMOBaseDocument) => doc[ "mods.place" ] || "",
            "editor.label.publishingDate": (doc: CMOBaseDocument) => doc[ "mods.yearIssued" ] || "",

        },
        "work": {
            "editor.label.identifier" : (doc: CMOBaseDocument) => `<a href="${Utils.getBaseURL()}receive/${doc["id"]}">${doc[ "identifier.type.CMO" ][ 0 ]}</a>`,
            "cmo.genre" : (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_musictype")
        }


    };

    private static getCategorySpan(doc: CMOBaseDocument, clazz: string): string {
        let rightCategoryField = BasketDisplay.findRightCategoryField(doc, clazz);
        return `${rightCategoryField.map(field => `<span data-clazz="${clazz}" data-category="${field.category}" class="value"></span>`).join(", ")}`
    }

    private static findRightCategoryField(doc: CMOBaseDocument, clazz: string): Array<{ clazz: string; category: string }> {
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

    public display(type?: string) {
        let basketDisplay = this;
        let callback = (objects, sort) => {
            if (type !== undefined) {
                this._container.innerHTML = "<div id='basket'>" + this.displayControls(objects, type) + this.displayObjects(type, objects[ type ], sort) + "</div>";
            } else {
                let objectTypes = [];
                for (let type in objects) {
                    if (objects.hasOwnProperty(type)) {
                        objectTypes.push(type);
                    }
                }

                let content = objectTypes.sort().map(t => {
                    let table = basketDisplay.displayObjects(t, objects[ t ], sort);
                    return table;
                });

                this._container.innerHTML = "<div id='basket'>" + this.displayControls(objects) + content.join(" ") + "</div>";
            }
            I18N.translateElements(this._container);
            ClassificationResolver.putLabels(this._container);
            BasketUtil.activateLinks(this._container);
            Array.prototype.slice.call(document.querySelectorAll("[data-onclick-col-remove]"))
                .forEach(function (el) {
                    el.addEventListener("click", function () {
                        el.parentElement.parentElement.remove();
                    });
                });
            this._container.classList.add("main--basket");

            let jQuery = window["jQuery"];
            jQuery(this._container).find("table").tablesorter({
                textSorter : function (a, b) {
                    return a.localeCompare(b, 'tr', {sensitivity : "base"});
                }
            });
            this._container.querySelector("[data-basket-empty]").addEventListener("click", ()=>{
               this.basket.removeAll();
               this.display(type);
            });

            Array.prototype.slice.call(this._container.querySelectorAll("[data-export-ids]")).forEach(function (el) {
                const idList = el.getAttribute("data-export-ids");
                const transformer = el.getAttribute("data-export-transformer");

                el.addEventListener("click", ()=>{
                    if(idList.length>0){
                        window.location.href=`${Utils.getBaseURL()}rsc/cmo/object/export/${transformer}/${idList}`;
                    }
                });
            })
        };

        basketDisplay.basket.getDocumentsGrouped("cmoType", callback);

    }

    public displayObjects(type: string, objs: Array<CMOBaseDocument>, sort: string) {
        let table = BasketDisplay.TABLE[ type ];

        let cols = [];

        for (let col in table) {
            if (table.hasOwnProperty(col)) {
                cols.push(col);
            }
        }

        let [ field, direction ] = sort.split(" ");

        let header = `
                      <thead>
                        <tr>
        ${cols.map((col) => {
            return `<th data-i18n="${col}">${col}</th>`
        }).join("")}
        <th></th>
                        </tr>
                      </thead>
                      `;

        let body = `
                    <tbody>
                     ${objs.map(obj =>
            `<tr>
                          ${cols.map((col) => `<td>${table[ col ](obj)}</td>`).join("")}
                          <td>
                            <a data-basket="${obj.id}" data-onclick-col-remove="true"></a>
                          </td>
                        </tr>`).join("")}
                    </tbody>
                    `;

        return `<h2 data-i18n="editor.cmo.select.${type}"></h2><div class='table-responsive'><table class="table table-condensed table-bordered table-hover">${header}${body}</table></div>`;
    }


    public reset() {
        if (this.preDisplayContent != null) {
            this._container.innerHTML = "";
            this.preDisplayContent.forEach((content) => {
                this._container.appendChild(content);
            });
            this.preDisplayContent = null;
            this._container.classList.remove("main--basket");
        }
    }

    public save() {
        let children: Array<HTMLElement> = [].slice.call(this._container.children);
        children.forEach(val => this._container.removeChild(val));
        this.preDisplayContent = children;
    }

    private displayControls(objects: any, type?: string) {
        const exportIds = [];
        if (typeof type == "undefined") {
            for (const type in objects) {
                if (objects.hasOwnProperty(type)) {
                    (<Array<CMOBaseDocument>>objects[type]).map(doc => doc.id).forEach((id) => exportIds.push(id));
                }
            }
        } else {
            (<Array<CMOBaseDocument>>objects[type]).map(doc => doc.id).forEach((id) => exportIds.push(id));
        }
        const idListString = exportIds.join(",");

        return `<div class="row">
<div class="col-md-12">
<button class="btn btn-secondary" data-basket-empty data-i18n="cmo.basket.remove.all"></button>
<button class="btn btn-secondary" data-i18n="cmo.basket.export.all" data-export-transformer="resolve-content-meimods" data-export-ids="${idListString}"></button>
<button class="btn btn-secondary" data-i18n="cmo.basket.export.all.dependency" data-export-transformer="resolve-dependencies-meimods" data-export-ids="${idListString}"></button>
</div>
</div>`;
    }
}
