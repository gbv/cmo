import {BasketStore} from "./BasketStore";
import {CMOBaseDocument} from "../other/Solr";
import {Utils} from "../other/Utils";
import {I18N} from "../other/I18N";
import {Classification, ClassificationResolver} from "../other/Classification";
import {BasketUtil} from "./BasketUtil";

export class BasketDisplay {
    constructor(private _container: HTMLElement) {

    }

    private basket = BasketStore.getInstance();
    private preDisplayContent: Array<HTMLElement> = null;


    private static TABLE = {
        "expression" : {
            "editor.label.identifier" : (doc: CMOBaseDocument) => doc[ "identifier.type.CMO" ][ 0 ],
            "editor.label.title" : (doc: CMOBaseDocument) =>
                `<a href="${Utils.getBaseURL()}receive/${doc[ "id" ]}">${Utils.encodeHtmlEntities(doc[ "displayTitle" ] + "")}</a>`,
            "editor.label.composer" : (doc: CMOBaseDocument) => {
                return "composer.ref" in doc ? doc[ "composer.ref" ].map((composer) => {
                    let [ name, id ] = composer.split("|");
                    return `<a href="${Utils.getBaseURL()}receive/${id}">${Utils.encodeHtmlEntities(name)}</a>`;
                }) : "";
            },
            "cmo.genre" : (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_musictype"),
            "cmo.makam" : (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_makamler"),
            "cmo.usul" : (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_usuler")
        },
        "person" : {
            "editor.label.name" : (doc: CMOBaseDocument) => doc[ "name" ].map((name) => `<a href="${Utils.getBaseURL()}receive/${doc[ "id" ]}">${name}`).join("<br/>"),
            "editor.label.lifeData.birth" : (doc: CMOBaseDocument) => (doc[ "birth.date.content" ] || [ "" ])[ 0 ] || "",
            "editor.label.lifeData.death" : (doc: CMOBaseDocument) => (doc[ "death.date.content" ] || [ "" ])[ 0 ] || ""
        },
        "source" : {
            "editor.label.identifier" : (doc: CMOBaseDocument) => doc[ "identifier.type.CMO" ][ 0 ],
            "editor.label.identifier.shelfmark" : (doc)=> doc[ "repo.identifier.shelfmark" ] || "",
            "editor.label.corpName": (doc)=> doc["repo.corpName.library"] || "",
            "editor.label.title" : (doc: CMOBaseDocument) =>
                `<a href="${Utils.getBaseURL()}receive/${doc[ "id" ]}">${Utils.encodeHtmlEntities((doc[ "title.type.main" ] || "") + "")}</a>`,

            "editor.label.publisher" : (doc: CMOBaseDocument) => doc[ "publisher" ] || "",
            "editor.label.editor" : (doc: CMOBaseDocument) => (doc[ "editor" ] || []).join("; "),
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
                `<a href="${Utils.getBaseURL()}receive/${doc[ "id" ]}">${Utils.encodeHtmlEntities(doc[ "mods.title.main" ] + "")}</a>`,
            "editor.label.pubPlace": (doc: CMOBaseDocument) => doc[ "mods.place" ] || "",
            "editor.label.publishingDate": (doc: CMOBaseDocument) => doc[ "mods.yearIssued" ] || "",

        },
        "edition-mods" : {
            "editor.label.identifier" : (doc) => (doc[ "mods.identifier" ] || [])
                .map(identifier=> `<a href="${Utils.getBaseURL()}receive/${doc["id"]}">${identifier}</a>`).join("<br/>"),
            "editor.label.title" : (doc: CMOBaseDocument) =>
                `<a href="${Utils.getBaseURL()}receive/${doc[ "id" ]}">${Utils.encodeHtmlEntities(doc[ "mods.title.main" ] + "")}</a>`,
            "editor.label.pubPlace": (doc: CMOBaseDocument) => doc[ "mods.place" ] || "",
            "editor.label.publishingDate": (doc: CMOBaseDocument) => doc[ "mods.yearIssued" ] || "",

        },
        "work": {
            "editor.label.identifier" : (doc: CMOBaseDocument) => `<a href="${Utils.getBaseURL()}receive/${doc["id"]}">${doc[ "identifier.type.CMO" ][ 0 ]}</a>`,
            "cmo.genre" : (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_musictype"),
            "cmo.kindOfData" : (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_kindOfData")
        }


    };

    private static getCategorySpan(doc: CMOBaseDocument, clazz: string): string {
        let rightCategoryField = BasketDisplay.findRightCategoryField(doc, clazz);
        return `${rightCategoryField.map(field => `<span data-clazz="${clazz}" data-category="${field.category}" class="value"></span>`).join("")}`
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
        this.basket.getDocumentsGrouped("cmoType", (objects) => {
            if (type !== undefined) {
                this._container.innerHTML = "<div id='basket'>" + this.displayObjects(type, objects[ type ]) + "</div>";
            } else {
                let objectTypes = [];
                for (let type in objects) {
                    if (objects.hasOwnProperty(type)) {
                        objectTypes.push(type);
                    }
                }

                let content = objectTypes.map(t => {
                    let table = this.displayObjects(t, objects[ t ]);
                    return table;
                });

                this._container.innerHTML = "<div id='basket'>" + content.join(" ") + "</div>";
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
            this._container.style.width = "100%";
        });


    }

    public displayObjects(type: string, objs: Array<CMOBaseDocument>) {
        let table = BasketDisplay.TABLE[ type ];

        let cols = [];

        for (let col in table) {
            if (table.hasOwnProperty(col)) {
                cols.push(col);
            }
        }


        let header = `
                      <thead>
                        <tr>
                            ${cols.map((col) => `<th data-i18n="${col}">${col}</th>`).join("")}
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
            this._container.style.width = "";
        }
    }

    public save() {
        let children: Array<HTMLElement> = [].slice.call(this._container.children);
        children.forEach(val => this._container.removeChild(val));
        this.preDisplayContent = children;
    }
}