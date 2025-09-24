import {BasketStore} from "./BasketStore";
import {CMOBaseDocument} from "../other/Solr";
import {Utils} from "../other/Utils";
import {I18N} from "../other/I18N";
import {ClassificationResolver} from "../other/Classification";
import {BasketUtil} from "./BasketUtil";

export class BasketDisplay {
    private basket = BasketStore.getInstance();
    private preDisplayContent: Array<HTMLElement> = null;

    constructor(private _container: HTMLElement) {

    }

    private static exportLimit = 3000;

    private static mergeLinkFields = (...arr: string[][]) => {
        let namesLinkMap = {};
        arr.forEach((namesRefsArray: string[]) => {
            (namesRefsArray || []).forEach(nameAndRef => {
                if (typeof nameAndRef != "undefined") {
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
        "expression": {
            "editor.label.identifier": (doc: CMOBaseDocument) => doc["identifier.type.CMO"][0],
            "editor.label.title": (doc: CMOBaseDocument) =>
                `<a href="${Utils.getBaseURL()}receive/${doc["id"]}">${Utils.encodeHtmlEntities(doc["displayTitle"] + "")}</a>`,
            "editor.label.alt.title": (doc: CMOBaseDocument) => (doc["title.type.alt"]||[]).join("<br/>"),
            "editor.label.composer": (doc: CMOBaseDocument) => {
                let composerMap = BasketDisplay.mergeLinkFields(doc["composer.display.ref"]);
                let html = [];
                for (const composer in composerMap) {
                    if (typeof composerMap[composer] != "undefined") {
                        html.push(`<a href="${Utils.getBaseURL()}receive/${composerMap[composer]}">${composer}</a>`)
                    } else {
                        html.push(composer);
                    }
                }
                return html.join("; ")
            },
            "cmo.genre": (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_musictype"),
            "cmo.makam": (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_makamler"),
            "cmo.usul": (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_usuler"),
            "editor.label.incip": (doc: CMOBaseDocument) => (doc["incip.normalized"] || []).join(", "),
            "cmo.worknumber": (doc: CMOBaseDocument) => (doc["expression.work.number"] || []).join(", "),
            "cmo.notationType": (doc: CMOBaseDocument) =>  (doc["expression.source.notationType"] || []).map((field) => `<span data-clazz="cmo_notationType" data-category="${field}" class="value"></span>`).join(", "),
            "cmo.hasFiles": (doc: CMOBaseDocument) => doc["hasFiles"] ? `<span data-i18n="cmo.yes"></span>` : `<span data-i18n="cmo.no"></span>`,
        },
        "person": {
            "editor.label.name": (doc: CMOBaseDocument) => ((doc["name"] instanceof Array) ? doc["name"] : [doc["name"]]).map((name) => `<a href="${Utils.getBaseURL()}receive/${doc["id"]}">${name || ""}</a>`).join("<br/>"),
            "editor.label.lifeData.birth": (doc: CMOBaseDocument) => (doc["birth.date.content"] || [""])[0] || "",
            "editor.label.lifeData.death": (doc: CMOBaseDocument) => (doc["death.date.content"] || [""])[0] || ""
        },
        "source": {
            "editor.label.identifier": (doc: CMOBaseDocument) => `<a href="${Utils.getBaseURL()}receive/${doc["id"]}">${doc["identifier.type.CMO"][0]}</a>`,
            "editor.label.identifier.shelfmark": (doc) => doc["repo.identifier.shelfmark"] || "",
            "editor.label.corpName": (doc) => doc["repo.corpName.library"] || "",
            "editor.label.title": (doc: CMOBaseDocument) =>
                `<a href="${Utils.getBaseURL()}receive/${doc["id"]}">${Utils.encodeHtmlEntities((doc["displayTitle"] || "") + "")}</a>`,
            "editor.label.alt.title": (doc: CMOBaseDocument) => (doc["title.type.alt"]||[]).join("<br/>"),
            "editor.label.publisher": (doc: CMOBaseDocument) => doc["publisher"] || "",
            "editor.label.creation.date": (doc: CMOBaseDocument) => doc["creation.date.content"] || "",
            "editor.label.editorAndAuthor": (doc: CMOBaseDocument) => {
                let authorMap = BasketDisplay.mergeLinkFields(doc["author.display.ref"]);
                let editorMap = BasketDisplay.mergeLinkFields(doc["editor.display.ref"]);
                let html = [];
                for (const author in authorMap) {
                    if (typeof authorMap[author] != "undefined") {
                        html.push(`<a href="${Utils.getBaseURL()}receive/${authorMap[author]}">${author}</a>`)
                    } else {
                        html.push(author);
                    }
                }
                for (const editor in editorMap) {
                    if (typeof editorMap[editor] != "undefined") {
                        html.push(`<a href="${Utils.getBaseURL()}receive/${editorMap[editor]}">${editor}</a>`)
                    } else {
                        html.push(editor);
                    }
                }
                return html.join("; ");
            },
            "editor.label.pubPlace": (doc: CMOBaseDocument) => doc["publisher.place"] || "",
            "editor.label.publishingDate": (doc: CMOBaseDocument) => doc["publish.date.content"] || "",
            "editor.label.series": (doc: CMOBaseDocument) => (doc["series"] || []).join(", "),
            "cmo.sourceType": (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_sourceType"),
            "cmo.contentType": (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_contentType"),
            "cmo.notationType": (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_notationType"),
            "cmo.hasFiles": (doc: CMOBaseDocument) => doc["hasFiles"] ? `<span data-i18n="cmo.yes"></span>` : `<span data-i18n="cmo.no"></span>`,
        },
        "source-mods": {
            "editor.label.identifier": (doc) => (doc["mods.identifier"] || [])
                .map(identifier => `<a href="${Utils.getBaseURL()}receive/${doc["id"]}">${identifier}</a>`).join("<br/>"),
            "editor.label.title": (doc: CMOBaseDocument) =>
                `<a href="${Utils.getBaseURL()}receive/${doc["id"]}">${Utils.encodeHtmlEntities(doc["displayTitle"] + "")}</a>`,
            "editor.label.pubPlace": (doc: CMOBaseDocument) => doc["mods.place"] || "",
            "editor.label.publishingDate": (doc: CMOBaseDocument) => doc["mods.dateIssued"] || "",

        },
        "edition-mods": {
            "editor.label.identifier": (doc) => (doc["mods.identifier"] || [])
                .map(identifier => `<a href="${Utils.getBaseURL()}receive/${doc["id"]}">${identifier}</a>`).join("<br/>"),
            "editor.label.title": (doc: CMOBaseDocument) =>
                `<a href="${Utils.getBaseURL()}receive/${doc["id"]}">${Utils.encodeHtmlEntities(doc["displayTitle"] + "")}</a>`,
            "editor.label.pubPlace": (doc: CMOBaseDocument) => doc["mods.place"] || "",
            "editor.label.publishingDate": (doc: CMOBaseDocument) => doc["mods.yearIssued"] || "",

        },
        "work": {
            "editor.label.identifier": (doc: CMOBaseDocument) => `<a href="${Utils.getBaseURL()}receive/${doc["id"]}">${doc["identifier.type.CMO"][0]}</a>`,
            "cmo.genre": (doc: CMOBaseDocument) => BasketDisplay.getCategorySpan(doc, "cmo_musictype")
        }


    };

    private static DOWNLOAD_MODAL = `
    <div class="modal show" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" data-i18n="cmo.basket.modal.download.title"></h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            <p data-i18n="cmo.basket.modal.download"></p>
            <span data-id="status-line"></span>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-dismiss="modal" data-i18n="cmo.basket.modal.download.close"></button>
          </div>
        </div>
      </div>
    </div>
    `;

    private static getCategorySpan(doc: CMOBaseDocument, clazz: string): string {
        let rightCategoryField = BasketDisplay.findRightCategoryField(doc, clazz);
        return `${rightCategoryField.map(field => `<span data-clazz="${clazz}" data-category="${field.category}" class="value"></span>`).join(", ")}`
    }

    private static findRightCategoryField(doc: CMOBaseDocument, clazz: string): Array<{ clazz: string; category: string }> {
        return ("category" in doc) ? doc.category
            .map(cat => cat.split(":", 4))
            .filter(([Clazz, category]) => clazz == Clazz)
            .map(([Clazz, category, , language, label]) => {
                return {
                    clazz: Clazz,
                    category: category
                }
            }) : [];
    }

    public display(type?: string) {
        let basketDisplay = this;
        let callback = (objects, sort) => {
            if (type !== undefined) {
                this._container.innerHTML = "<div id='basket'>" + this.displayControls(objects, type) + this.displayObjects(type, objects[type], sort) + "</div>";
            } else {
                let objectTypes = [];
                for (let type in objects) {
                    if (objects.hasOwnProperty(type)) {
                        objectTypes.push(type);
                    }
                }

                let content = objectTypes.sort().map(t => {
                    let table = basketDisplay.displayObjects(t, objects[t], sort);
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
                textSorter: function (a, b) {
                    return a.localeCompare(b, 'tr', {sensitivity: "base"});
                }
            });
            this._container.querySelector("[data-basket-empty]").addEventListener("click", () => {
                this.basket.removeAll();
                this.display(type);
            });

            Array.prototype.slice.call(this._container.querySelectorAll("[data-export-ids]")).forEach(function (el) {
                const idListString = el.getAttribute("data-export-ids");
                const transformer = el.getAttribute("data-export-transformer");

                el.addEventListener("click", (e) => {
                    let idList = idListString.split(",");
                    if (idList.length > BasketDisplay.exportLimit) {
                        I18N.translate("cmo.basket.export.limit", (translation)=> {
                            alert(translation.replace("{0}", BasketDisplay.exportLimit.toString()));
                        });
                        return false;
                    }
                    if (idList.length > 0) {
                        const modalWrapper = document.createElement("div");
                        document.body.appendChild(modalWrapper);
                        modalWrapper.innerHTML = BasketDisplay.DOWNLOAD_MODAL;
                        I18N.translateElements(modalWrapper);

                        let modalElement = (window as any).$(modalWrapper.firstElementChild).modal({
                            keyboard: true,
                            focus: true,
                            show: true
                        });

                        try {
                            const responsePromise = fetch(`${Utils.getBaseURL()}rsc/cmo/object/export/${transformer}`, {
                                method: "POST",
                                body: idList.join(",")
                            });

                            responsePromise.then(async response => {
                                const contentDisposition = response.headers.get("Content-disposition");
                                const regexp = /filename="([^"]*)"/;
                                const filename = regexp.exec(contentDisposition)[1];
                                const blob = await response.blob();

                                if((window as any).showSaveFilePicker) {
                                    try {
                                        const fileHandle = await (window as any).showSaveFilePicker(
                                            {
                                                startIn: "downloads",
                                                suggestedName: filename,
                                            }
                                        );
                                        const writableStream = await fileHandle.createWritable();
                                        await writableStream.write(blob);
                                        await writableStream.close();
                                    } catch (e) {
                                        modalElement.modal("hide");
                                    }
                                } else {
                                    const url = window.URL.createObjectURL(blob);
                                    const a = document.createElement("a");
                                    a.style.display = "none";
                                    a.href = url;
                                    a.download = filename;
                                    document.body.appendChild(a);
                                    a.click();
                                    window.URL.revokeObjectURL(url);
                                    a.remove();
                                }

                                modalElement.modal("hide");
                            });
                        } catch (e) {
                            I18N.translate("cmo.basket.export.error", (translation) => {
                                (modalWrapper.querySelector("[data-id='status-line']") as HTMLSpanElement).innerText = translation + "\n " + e.message;
                            });
                            modalElement.modal("hide");
                        }
                    }
                    e.preventDefault();
                    e.stopPropagation();
                    return false;
                });
            })
        };

        basketDisplay.basket.getDocumentsGrouped("cmoType", callback);

    }

    public displayObjects(type: string, objs: Array<CMOBaseDocument>, sort: string) {
        let table = BasketDisplay.TABLE[type];

        let cols = [];

        for (let col in table) {
            if (table.hasOwnProperty(col)) {
                cols.push(col);
            }
        }

        let [field, direction] = sort.split(" ");

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
                          ${cols.map((col) => `<td>${table[col](obj)}</td>`).join("")}
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
        <div class="btn-group" role="group">
            <button class="btn btn-danger" data-basket-empty data-i18n="cmo.basket.remove.all"></button>
            <div class="btn-group">
                <button class="btn btn-secondary btn-sm dropdown-toggle" data-toggle="dropdown" data-i18n="cmo.basket.export.all"></button>
                <div class="dropdown-menu">
                    <a class="dropdown-item" href="#" data-i18n="cmo.basket.export.pdf" data-export-transformer="nodeps-pdf"
                       data-export-ids="${idListString}"></a>
                    <a class="dropdown-item" href="#" data-i18n="cmo.basket.export.csv"
                       data-export-transformer="nodeps-csv" data-export-ids="${idListString}"></a>
                    <a class="dropdown-item" href="#" data-i18n="cmo.basket.export.meimods"
                       data-export-transformer="nodeps-meimods" data-export-ids="${idListString}"></a>
                </div>
            </div>
            <div class="btn-group">
                <button class="btn btn-secondary btn-sm dropdown-toggle" data-toggle="dropdown" data-i18n="cmo.basket.export.all.dependency">
                </button>
                <div class="dropdown-menu">
                    <a class="dropdown-item" href="#" data-i18n="cmo.basket.export.pdf"
                       data-export-transformer="deps-pdf" data-export-ids="${idListString}"></a>
                    <a class="dropdown-item" href="#" data-i18n="cmo.basket.export.csv"
                       data-export-transformer="deps-csv" data-export-ids="${idListString}"></a>
                    <a class="dropdown-item" href="#" data-i18n="cmo.basket.export.meimods"
                       data-export-transformer="deps-meimods" data-export-ids="${idListString}"></a>
                 </div>
            </div>
        </div>
    </div>
</div>`;
    }
}
