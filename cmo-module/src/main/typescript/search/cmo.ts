import {
    CheckboxSearchField,
    ClassificationSearchField,
    DateSearchField,
    SearchController,
    SearchField,
} from './SearchComponent';
import {Utils} from "../other/Utils";
import {SearchDisplay} from "./SearchDisplay";
import {SearchFacetController} from "./SearchFacet";
import {StateController} from "./StateController";
import {SolrSearcher} from "../other/Solr";
import {BasketDisplay} from "./BasketDisplay";
import {BasketStore} from "./BasketStore";
import {BasketUtil} from "./BasketUtil";
import {I18N} from "../other/I18N";
import {ClassificationResolver} from "../other/Classification";
import {enableKeyboard} from "../keyboard/keyboard";

window.addEventListener('load', () => {

    let eContainer = <HTMLElement>document.querySelector("#e_suche");
    let kContainer = <HTMLElement>document.querySelector("#k_suche");
    let sideBar = <HTMLElement>document.querySelector("#sidebar");


    let translationMap = {};

    let subselectTarget = null;
    let aditionalQuery = [];

    let facet = new SearchFacetController(sideBar, translationMap,
        {
            field: "cmoType",
            type: "translate",
            translate: "editor.cmo.select."
        },
        {
            field: "cmo_makamler",
            type: "class"
        },
        {
            field: "cmo_usuler",
            type: "class"
        },
        {
            field: "cmo_musictype",
            type: "class"
        });

    const eSearchBaseQuery = "category.top:\"cmo_kindOfData:edition\"";
    const kSearchBaseQuery = "(category.top:\"cmo_kindOfData:source\" OR cmoType:person)";

    const eSearch = new SearchController(eContainer, facet, "cmo.edition.search", eSearchBaseQuery);
    const kSearch = new SearchController(kContainer, facet, "cmo.catalog.search", kSearchBaseQuery);

    /* enable/disable search on click */
    eContainer.addEventListener('click', () => {
        eSearch.enable = true;
        kSearch.enable = false;
    });

    const resetHandler = () => {
        aditionalQuery = [];

    };

    kSearch.addResetSearchHandler(resetHandler);
    eSearch.addResetSearchHandler(resetHandler);

    eSearch.addEnabledHandler((enabled) => {
        if (enabled) {
            eContainer.setAttribute("class", "col-12 col-sm-6 col-md-8 col-lg-8");
            kContainer.setAttribute("class", "col-12 col-sm-6 col-md-4 col-lg-4");
        }
    });


    kContainer.addEventListener('click', () => {
        kSearch.enable = true;
        eSearch.enable = false;

    });

    kSearch.addEnabledHandler((enabled) => {

        if (enabled) {
            kContainer.setAttribute("class", "col-12 col-sm-6 col-md-8 col-lg-8");
            eContainer.setAttribute("class", "col-12 col-sm-6 col-md-4 col-lg-4");
        }


    });

    let updateMainContainerSize = () => {
        let normalClass = ["col-md-9", "col-lg-9"];
        let largeClass = ["col-md-12", "col-lg-12"];

        if (kSearch.enable) {
            largeClass.forEach(token => mainContainer.classList.remove(token));
            normalClass.forEach(token => mainContainer.classList.add(token));
            sideBar.style.display = 'block';
        }

        if (eSearch.enable) {
            normalClass.forEach(token => mainContainer.classList.remove(token));
            largeClass.forEach(token => mainContainer.classList.add(token));
            sideBar.style.display = 'none';
        }

    };

    window.document.body.addEventListener("click", (evt: any) => {
        if (eSearch.isExtendedSearchOpen() && evt.path.indexOf(eContainer) == -1) {
            eSearch.openExtendedSearch(false);
        }

        if (kSearch.isExtendedSearchOpen() && evt.path.indexOf(kContainer) == -1) {
            kSearch.openExtendedSearch(false);
        }
    });

    let languageFields = [];
    const ISO15924 = "iso15924";
    const RFC5646 = "rfc5646";

    const langComplete = {};
    langComplete[ISO15924] = false;
    langComplete[RFC5646] = false;

    const onComplete = ()=>{
        const titleFields = ["title"];
        languageFields.map(s=> "title.lang." + s).forEach(f=> titleFields.push(f));

        eSearch.addExtended({
            mods: {
                type: "mods",
                baseQuery: ["objectType:mods", "-complex:*"],
                fields: [
                    new ClassificationSearchField("category.top", "diniPublType"),
                    new SearchField("editor.label.title", ["mods.title", "mods.title.main", "mods.title.subtitle"]),
                    new SearchField("editor.label.name", ["mods.nameIdentifier", "mods.name"])

                ]
            },
            mods_complex: {
                type: "mods",
                baseQuery: ["objectType:mods"],
                fields: [
                    new SearchField("editor.label.title", ["mods.title", "mods.title.main", "mods.title.subtitle"]),
                    new SearchField("editor.label.name", ["mods.nameIdentifier", "mods.name"]),
                    new SearchField("editor.label.publisher", ["mods.publisher"]),
                    new ClassificationSearchField("category.top", "DDC"),
                    new ClassificationSearchField("category.top", "diniPublType"),
                    new DateSearchField("editor.legend.pubDate", ["mods.dateIssued.range", "mods.dateIssued.host.range"]),
                ]
            }
        });

    // Katalog Search field definition
        kSearch.addExtended({
            expression: {
                type: "expression",
                baseQuery: ["objectType:expression", "-complex:*"],
                fields: [new SearchField("editor.label.title", titleFields),
                    new ClassificationSearchField("category.top", "iso15924"),
                    new ClassificationSearchField("category.top", "rfc5646"),
                    new ClassificationSearchField("category.top", "cmo_musictype"),
                    new ClassificationSearchField("category.top", "cmo_makamler", 1),
                    new ClassificationSearchField("category.top", "cmo_usuler", 1),
                    new SearchField("editor.label.incip", ["incip"])],
            }
            ,
            expression_complex: {
                type: "expression",
                baseQuery: ["objectType:expression"],
                fields: [
                    new SearchField("editor.label.title", titleFields),
                    new ClassificationSearchField("category.top", "iso15924"),
                    new ClassificationSearchField("category.top", "rfc5646"),
                    new ClassificationSearchField("category.top", "cmo_musictype"),
                    new ClassificationSearchField("category.top", "cmo_makamler", 1),
                    new ClassificationSearchField("category.top", "cmo_usuler", 1),
                    new ClassificationSearchField("{!join from=reference to=id}category.top", "cmo_sourceType"),
                    new ClassificationSearchField("{!join from=reference to=id}category.top", "cmo_notationType"),
                    new DateSearchField("editor.label.publishingDate", ["{!join from=reference to=id}publish.date.range"]),
                    new SearchField("editor.label.composer", ["{!join from=id to=composer.ref.pure}name"]),
                    new DateSearchField("editor.label.lifeData", ["{!join from=id to=composer.ref.pure}date.range"]),
                    new SearchField("editor.label.lyricist", ["{!join from=id to=lyricist.ref.pure}name"]),
                    new DateSearchField("editor.label.lifeData", ["{!join from=id to=lyricist.ref.pure}date.range"]),
                    new SearchField("editor.label.incip", ["incip"]),
                    new CheckboxSearchField("cmo.hasFiles", "{!join from=reference to=id}hasFiles", "true"),
                    new CheckboxSearchField("cmo.hasReference", "{!join from=mods.relatedItem to=id}*", "*"),
                ],
            },
            source: {
                type: "source",
                baseQuery: ["objectType:source"],
                fields: [
                    new SearchField("editor.label.title", titleFields),
                    new ClassificationSearchField("category.top", "cmo_sourceType"),
                    new ClassificationSearchField("category.top", "cmo_notationType"),
                    new ClassificationSearchField("category.top", "cmo_contentType"),
                    new ClassificationSearchField("category.top", "iso15924"),
                    new ClassificationSearchField("category.top", "rfc5646"),
                    new DateSearchField("editor.label.publishingDate", ["publish.date.range"]),
                    new SearchField("editor.label.contributer", ["editor", "author", "respStmt", "hand.name"]),
                    new SearchField("editor.label.publishingInformation", ["publisher", "publisher.place", "series",
                        "repo.corpName", "repo.identifier", "repo.geogName", "history.event.eventGeogName"]),
                    new CheckboxSearchField("cmo.hasFiles", "hasFiles", "true"),
                    new CheckboxSearchField("cmo.hasReference", "{!join from=mods.relatedItem to=id}*", "*")
                ]
            },
            mods: {
                type: "bibl",
                baseQuery: ["objectType:mods"],
                fields: [
                    new SearchField("editor.label.title", ["mods.title", "mods.title.main", "mods.title.subtitle"]),
                    new SearchField("editor.label.name", ["mods.nameIdentifier", "mods.name"]),
                    new SearchField("editor.label.publishingInformation", ["mods.publisher", "mods.place",
                        "mods.title.de.series", "mods.title.en.series", "mods.title.tr.series",
                        "mods.title.de.host", "mods.title.en.host", "mods.title.tr.host"]),
                    /* new ClassificationSearchField("mods.ddc", "DDC"), */
                    /* new ClassificationSearchField("mods.type", "diniPublType"), */
                    new DateSearchField("editor.legend.pubDate", ["mods.dateIssued.range", "mods.dateIssued.host.range"])
                ]
            },
            person: {
                type: "person",
                baseQuery: ["objectType:person"],
                fields: [
                    new SearchField("editor.label.name", ["name", "name.general"]),
                    new DateSearchField("editor.label.lifeData", ["date.range"]),
                    new CheckboxSearchField("editor.label.composer", "{!join from=composer.ref.pure to=id}composer.ref.pure", "*"),
                    new CheckboxSearchField("editor.label.lyricist", "{!join from=lyricist.ref.pure to=id}lyricist.ref.pure", "*")
                ],

            },
            lyrics: {
                type: "expression",
                baseQuery: ["objectType:expression", "cmo_musictype:gn-66217054-X"],
                fields: [
                    new SearchField("editor.label.title", titleFields),
                    new SearchField("editor.label.incip", ["incip"]),
                    new ClassificationSearchField("category.top", "iso15924"),
                    new ClassificationSearchField("category.top", "rfc5646"),
                    new ClassificationSearchField("category.top", "cmo_musictype"),
                    new ClassificationSearchField("category.top", "cmo_litform"),
                    new ClassificationSearchField("category.top", "cmo_makamler", 1),
                    new ClassificationSearchField("category.top", "cmo_usuler", 1),
                    new SearchField("editor.label.lyricist", ["{!join from=id to=lyricist.ref.pure}name"]),
                    new DateSearchField("editor.label.lifeData", ["{!join from=id to=lyricist.ref.pure}date.range"]),
                    new ClassificationSearchField("{!join from=reference to=id}category.top", "cmo_sourceType"),
                    new CheckboxSearchField("cmo.hasFiles", "{!join from=reference to=id}hasFiles", "true"),
                    new CheckboxSearchField("cmo.hasReference", "{!join from=mods.relatedItem to=id}*", "*")
                ]
            },
            "work": {
                type: "work",
                baseQuery: ["objectType:work"],
                fields: []
            }
        });

        StateController.onStateChange((params, selfChange) => {
            let [, action] = params.filter(([key, value]) => key == "action")[0] || [null, null];

            updateMainContainerSize();
            let extra: HTMLElement = null;

            const getSetParentExtra = function () {
                const parentExtra = document.createElement("div");
                const buttonClass = "cmo-abort-button";
                const textClass = "cmo-replace-parent-description-text";

                parentExtra.classList.add('well');
                parentExtra.innerHTML = `<span class="${textClass}"></span><a class="${buttonClass}"></a>`;

                I18N.translate('cmo.replace.parent.description', (translation) => {
                    const replaceText: HTMLSpanElement = <HTMLSpanElement>parentExtra.querySelector("." + textClass);
                    replaceText.innerText = translation;
                });

                const replaceButton: HTMLElement = <HTMLElement>parentExtra.querySelector("." + buttonClass);
                I18N.translate('cmo.abort', (translation) => {
                    replaceButton.innerText = translation;
                    replaceButton.addEventListener('click', () => {
                        window.location.hash = "";
                    });
                });

                return parentExtra;
            };

            const getSubselect = function () {
                const subSelect = document.createElement("div");
                const buttonClass = "cmo-abort-button";
                const textClass = "cmo-subselect-description-text";

                subSelect.classList.add('well');
                subSelect.innerHTML = `<span class="${textClass}"></span><a class="${buttonClass}"></a>`;

                I18N.translate('cmo.subselect.description', (translation) => {
                    const replaceText: HTMLSpanElement = <HTMLSpanElement>subSelect.querySelector("." + textClass);
                    replaceText.innerText = translation;
                });

                const replaceButton: HTMLElement = <HTMLElement>subSelect.querySelector("." + buttonClass);
                I18N.translate('cmo.abort', (translation) => {
                    replaceButton.innerText = translation;
                    replaceButton.addEventListener('click', () => {
                        window.location.hash = "";
                    });
                });

                return subSelect;
            };

            const getAddChildExtra = () => {
                const childExtra = document.createElement("div");
                const buttonClass = "cmo-abort-button";
                const textClass = "cmo-add-child-description-text";

                childExtra.classList.add('well');
                childExtra.innerHTML = `<span class="${textClass}"></span><a class="${buttonClass}"></a>`;

                I18N.translate('cmo.add.child.description', (translation) => {
                    const replaceText: HTMLSpanElement = <HTMLSpanElement>childExtra.querySelector("." + textClass);
                    replaceText.innerText = translation;
                });

                const replaceButton: HTMLElement = <HTMLElement>childExtra.querySelector("." + buttonClass);
                I18N.translate('cmo.abort', (translation) => {
                    replaceButton.innerText = translation;
                    replaceButton.addEventListener('click', () => {
                        window.location.hash = "";
                    });
                });
                return childExtra;
            };

            const getLinkExtra = (label:string) => {
                const childExtra = document.createElement("div");
                const buttonClass = "cmo-abort-button";
                const textClass = "cmo-add-label-description-text";

                childExtra.classList.add('well');
                childExtra.innerHTML = `<span class="${textClass}"></span><a class="${buttonClass}"></a>`;

                I18N.translate('cmo.link.'+label+'.description', (translation) => {
                    const replaceText: HTMLSpanElement = <HTMLSpanElement>childExtra.querySelector("." + textClass);
                    replaceText.innerText = translation;
                });

                const replaceButton: HTMLElement = <HTMLElement>childExtra.querySelector("." + buttonClass);
                I18N.translate('cmo.abort', (translation) => {
                    replaceButton.innerText = translation;
                    replaceButton.addEventListener('click', () => {
                        window.location.hash = "";
                    });
                });
                return childExtra;
            };

            switch (action) {
                case "add-child":
                case "subselect":
                case "set-parent":
                case "add-expression2work":
                case "subselect-insert":

                    sideBar.classList.remove("d-none");
                    mainContainer.classList.remove("col-md-11");
                    mainContainer.classList.remove("col-lg-11");
                    mainContainer.classList.add("col-md-9");
                    mainContainer.classList.add("col-lg-9");

                    switch (action) {
                        case "add-child":
                            extra = getAddChildExtra();
                            break;
                        case "subselect":
                        case "subselect-insert":
                            extra = getSubselect();
                            break;
                        case"set-parent":
                            extra = getSetParentExtra();
                            break;
                        case "add-expression2work":
                            extra = getLinkExtra("expression2work");
                            break;
                    }
                case "init_search":
                    aditionalQuery = params.filter(([key]) => key !== 'q' && key !== 'action' && key !== "sort" && key !== "rows" && key !== "start");
                    if (action == "init_search") {
                        action = "search";
                    }
                case "search":
                    ctrl = null;
                    for (let param of params) {
                        let [, v] = param;

                        if (v.indexOf(kSearchBaseQuery) != -1) {
                            ctrl = kSearch;
                        } else if (v.indexOf(eSearchBaseQuery) != -1) {
                            ctrl = eSearch;

                        }
                    }

                    resetJS();

                    if (ctrl != null) {
                        ctrl.enable = true;

                        if (!selfChange) {
                            ctrl.setSolrQuery(params);
                        }

                        searchDisplay.save();
                        facet.save();
                        searchDisplay.loading();
                        solrSearcher.search(
                            params
                            , (result => {
                                searchDisplay.displayResult(result, ctrl.getSearchDescription(), (start, sortField, asc, rows) => {
                                    window.scrollTo(0, 0);
                                    search(start, ctrl, action, sortField, asc, rows);
                                }, getResultAction(params), () => {
                                    ctrl.openExtendedSearch(true);
                                    onQueryChanged(ctrl);
                                }, extra);
                                facet.displayFacet(result);
                            }));
                    }
                    break;
                case "basket":
                    resetJS();
                    baskedDisplay.save();
                    baskedDisplay.display();
                    break;

                default:
                    resetJS();
            }
        });
        kSearch.addQueryChangedHandler(() => onQueryChanged(kSearch));
        eSearch.addQueryChangedHandler(() => onQueryChanged(eSearch));


        let basketBadge = document.querySelector("#basked_badge");
        let basket = BasketStore.getInstance();

        let refreshBaskedBadge = () => {
            basketBadge.innerHTML = (basket.count()) + "";
        };

        basket.addListener(refreshBaskedBadge);
        refreshBaskedBadge();

// The Parent Element have to look like this <div data-subselect="(category.top:"cmo_kindOfData:source" OR objectType:person) AND objectType:person">
// The input then just can be <input name='personID' data-subselect-target='id' /> <input name='personName' data-subselect-target='solrField2' />
        Array.prototype.slice.call(document.querySelectorAll("[data-subselect]")).forEach((node) => {
            let element = <HTMLElement>node;
            (<HTMLElement>element.querySelector("[data-subselect-trigger]")).onclick = (e) => {
                e.preventDefault();
                let query = element.getAttribute("data-subselect");
                subselectTarget = Array.prototype.slice.call(element.querySelectorAll("[data-subselect-target]"));


                window.location.hash = `q=${query}&start=0&action=subselect`;
                window.setTimeout(() => {
                    if (ctrl !== null) {
                        ctrl.openExtendedSearch(true);
                        ctrl.focus()
                    }
                }, 1000);


            };
        });
    };

    ClassificationResolver.resolve(ISO15924, (langClazz) => {
        langClazz.categories.forEach(categ => languageFields.push(categ.ID));
        langComplete[ISO15924] = true;
        if(langComplete[ISO15924] && langComplete[RFC5646]){
            onComplete();
        }
    });

    ClassificationResolver.resolve(RFC5646, (langClazz) => {
        langClazz.categories.forEach(categ => languageFields.push(categ.ID));
        langComplete[RFC5646] = true;
        if(langComplete[ISO15924] && langComplete[RFC5646]){
            onComplete();
        }
    });

    /* switch input  */
    let switcher = <Element>document.createElement("div");
    let WebApplicationBaseURL = Utils.getBaseURL();

    eContainer.appendChild(switcher);

    switcher.setAttribute("class", 'switcher');
    switcher.innerHTML = `<img src="${WebApplicationBaseURL}content/images/switcher.svg" />`;

    switcher.addEventListener('click', (event: MouseEvent) => {
        event.cancelBubble = true;
        if (!kSearch.enable && !eSearch.enable) {
            return;
        }

        let enabled = (kSearch.enable) ? kSearch : eSearch;
        let disabled = (!kSearch.enable) ? kSearch : eSearch;

        disabled.setInputValue(enabled.getInputValue());
        enabled.setInputValue('');
        disabled.enable = true;
        enabled.enable = false;
        enabled.focus();
    });


    /* Search Display*/
    let mainContainer = document.querySelector("#main");
    let searchDisplay = new SearchDisplay(<HTMLElement>mainContainer);
    let baskedDisplay = new BasketDisplay(<HTMLElement>mainContainer);
    let solrSearcher = new SolrSearcher();

    let resetJS = () => {
        baskedDisplay.reset();
        facet.reset();
        searchDisplay.reset();
    };

    let currentTimeOut = null;
    let search;

    let onQueryChanged = (searchController: SearchController) => {
        if (currentTimeOut !== null) {
            window.clearTimeout(currentTimeOut);
            currentTimeOut = null;
        }


        currentTimeOut = window.setTimeout(() => {
            let [, action] = StateController.getState().filter(([key, value]) => key == "action")[0] || [undefined, undefined];
            if (action != "search" && action != "subselect" && action != "subselect-insert" && action != "set-parent" && action != "add-child" && action != "add-expression2work") {
                action = "search";
            }

            search(0, searchController, action)
        }, 500);
    };

    search = (start, searchController, action, sortField: string, asc: boolean = false, rows = 10) => {
        let queries = searchController.getSolrQuery();

        let params = queries
            .concat([["start", start]])
            .concat([["action", action]])
            .concat([["sort", (sortField || "score") + " " + (asc ? "asc" : "desc")]])
            .concat([["rows", rows]]);

        if (aditionalQuery.length > 0) {
            params = params.concat(aditionalQuery);
        }

        StateController.setState(params);
    };


    let getResultAction = (params) => {

        let [, action] = params.filter(([key, value]) => key == "action")[0] || [null, null];

        switch (action) {
            case "init_search":
            case "search":
                return (doc, result, hitOnPage, event:MouseEvent) => {
                    let param = "";
                    for (let i in result.responseHeader.params) {
                        if (i == "wt" || i == "start" || i == "rows") {
                            continue;
                        }
                        if (result.responseHeader.params[i] instanceof Array) {
                            param += result.responseHeader.params[i].map(param => `${i}=${encodeURIComponent(param)}`).join("&") + "&";
                        } else {
                            param += `${i}=${encodeURIComponent(result.responseHeader.params[i])}&`;
                        }
                    }
                    if (param[param.length - 1] == "&") {
                        param = param.substring(0, param.length - 1);
                    }
                    param += `&start=${(result.response.start || 0) + hitOnPage}&rows=1&origrows=${result.responseHeader.params["rows"] || 10}&XSL.Style=browse`;
                    window.location.href = `${Utils.getBaseURL()}servlets/solr/select?${param}`;
                };

            case "subselect":
                if (subselectTarget == null) {
                    throw "subselect without set subselectTarget!";
                }


                return (doc, result, hitOnPage) => {
                    aditionalQuery = null;

                    resetJS();
                    ctrl.setInputValue('');
                    ctrl.enable = false;

                    subselectTarget.forEach((sst) => {
                        let field = sst.getAttribute("data-subselect-target");
                        if ("value" in sst) {
                            let fieldValue = doc[field];
                            if (fieldValue instanceof Array) {
                                sst.value = fieldValue[0];
                            } else {
                                sst.value = fieldValue;
                            }
                        }
                    });
                    subselectTarget = null;
                    window.location.hash = "";
                    sideBar.classList.add("d-none");
                    mainContainer.classList.add("col-md-11");
                    mainContainer.classList.add("col-lg-11");
                    mainContainer.classList.remove("col-md-9");
                    mainContainer.classList.remove("col-lg-9");

                };
            case "subselect-insert":

                return (doc, result, hitOnPage) => {
                    aditionalQuery = null;

                    resetJS();
                    ctrl.setInputValue('');
                    ctrl.enable = false;
                    let element = document.querySelector("." + insertClassName);

                    subselectTarget.forEach((sst) => {
                        let fieldValue = doc["id"];
                        let realValue = (fieldValue instanceof Array) ? fieldValue[0] : fieldValue;
                        if (element.innerHTML.length == 0) {
                            if ("mods.identifier.CMO" in doc) {
                                element.innerHTML = doc["mods.identifier.CMO"];
                            } else if ("identifier.type.CMO" in doc) {
                                element.innerHTML = doc["identifier.type.CMO"];
                            } else if ("displayTitle" in doc) {
                                element.innerHTML = doc["displayTitle"];
                            }
                        }
                        element.setAttribute("href", Utils.getBaseURL() + "receive/" + realValue);
                    });
                    window.location.hash = "";
                    sideBar.classList.add("d-none");
                    mainContainer.classList.add("col-md-11");
                    mainContainer.classList.add("col-lg-11");
                    mainContainer.classList.remove("col-md-9");
                    mainContainer.classList.remove("col-lg-9");
                    window.scroll(0, subselectTarget[0].getBoundingClientRect().top - (window.innerHeight / 2));
                    subselectTarget = null;


                };

            case "set-parent":
                return (doc) => {
                    const child = params.filter(([key, value]) => key == "of")[0][1];
                    const newParent = doc.id;
                    I18N.translate("cmo.replace.parent.confirm", (translation) => {
                        const message = translation.replace("{0}", child).replace("{1}", newParent);
                        const replace = confirm(message);

                        if (replace) {
                            const url = `${Utils.getBaseURL()}rsc/cmo/object/move/${child}?to=${newParent}`;
                            let xhttp = new XMLHttpRequest();
                            xhttp.onreadystatechange = () => {
                                if (xhttp.readyState === XMLHttpRequest.DONE) {
                                    if (xhttp.status == 200) {
                                        I18N.translate("cmo.replace.parent.success", (translation) => {
                                            alert(translation);
                                            aditionalQuery = null;
                                            window.location.hash = "";
                                            window.location.reload(true);
                                        });
                                    } else {
                                        I18N.translate("cmo.replace.parent.failed", (translation) => {
                                            alert(translation + "\n" + JSON.parse(xhttp.response)["message"]);
                                            console.error(xhttp.response);
                                        });
                                    }
                                }
                            };
                            xhttp.open('GET', url, true);
                            xhttp.send();
                        }
                    });

                };
            case "add-child":
                return (doc) => {
                    const parent = params.filter(([key, value]) => key == "to")[0][1];
                    const childToAdd = doc.id;
                    I18N.translate("cmo.add.child.confirm", (translation) => {
                        const message = translation.replace("{0}", parent).replace("{1}", childToAdd);
                        const replace = confirm(message);

                        if (replace) {
                            const url = `${Utils.getBaseURL()}rsc/cmo/object/move/${childToAdd}?to=${parent}`;
                            let xhttp = new XMLHttpRequest();
                            xhttp.onreadystatechange = () => {
                                if (xhttp.readyState === XMLHttpRequest.DONE) {
                                    if (xhttp.status == 200) {
                                        I18N.translate("cmo.add.child.success", (translation) => {
                                            alert(translation);
                                            aditionalQuery = null;
                                            window.location.hash = "";
                                            window.location.reload(true);
                                        });
                                    } else {
                                        I18N.translate("cmo.add.child.failed", (translation) => {
                                            alert(translation + "\n" + JSON.parse(xhttp.response)["message"]);
                                            console.error(xhttp.response);
                                        });
                                    }
                                }
                            };
                            xhttp.open('GET', url, true);
                            xhttp.send();
                        }
                    });
                };
            case "add-expression2work":
                return (doc) => {
                    const work = params.filter(([key, value]) => key == "work")[0][1];
                    const expressionTitle = doc.displayTitle;
                    const expression = doc.id;
                    if(doc["objectType"] == "expression"){
                        I18N.translate("cmo.link.expression2work.confirm", async (translation) => {
                            const message = translation.replace("{0}", expressionTitle);
                            const replace = confirm(message);

                            if(replace){
                                const url = `${Utils.getBaseURL()}rsc/cmo/object/link/${work}/${expression}`;
                                const resp = await fetch(url,{
                                    method: "POST"
                                });
                                if(resp.status == 200){
                                    I18N.translate("cmo.link.expression2work.success", (translation) => {
                                        alert(translation);
                                        aditionalQuery = null;
                                        window.location.hash = "";
                                        window.location.reload(true);
                                    });
                                }
                            }

                        });
                    } else {
                        I18N.translate("cmo.link.expression2work.error.wrong.Type", (translation) => {
                            alert(translation);
                        });
                    }

                }
        }
    };

    let ctrl: SearchController = null;


    let insertClassName = null;

    Array.prototype.slice.call(document.querySelectorAll("[data-insert-subselect]")).forEach((node) => {
        let element = <HTMLElement>node;
        let trigger = (<HTMLElement>element.querySelector("[data-subselect-trigger]"));
        let _subselectTarget = <HTMLInputElement>element.querySelector("[data-subselect-target]");
        const contentEditable = document.createElement("div");


        contentEditable.setAttribute("contentEditable", "true");
        contentEditable.style.width = "100%";
        contentEditable.style.minHeight = "3em";
        contentEditable.style.display = "inline-block";
        contentEditable.classList.add("form-control");
        _subselectTarget.parentElement.insertBefore(contentEditable, _subselectTarget);
        contentEditable.innerHTML = _subselectTarget.value;
        _subselectTarget.style.display = "none";
        Array.prototype.slice.call(contentEditable.querySelectorAll(".inserted")).forEach((linkElement) => {
            linkElement.addEventListener("click", () => {
                window.open(linkElement.getAttribute("href"), '_blank');
            });
        });

        const config = {
            subtree: true,
            attributes: true,
            childList: true,
            characterData: true,
            characterDataOldValue: true
        };

        let observer: MutationObserver;
        observer = new MutationObserver(function (mutations) {
            mutations.forEach(function (mutation) {
                if (mutation.type == "childList") {
                    let action = [];

                    Array.prototype.slice.call(contentEditable.children)
                        .filter((child) => {
                            return !((<HTMLElement>child).classList.contains("inserted")) && child.nodeName.toLocaleLowerCase() !== "br";
                        })
                        .forEach((child) => {
                            action.push(() => {
                                contentEditable.replaceChild(document.createTextNode(child.innerText), child);
                            });
                        });


                    observer.disconnect();
                    action.forEach(a => a());
                    observer.observe(contentEditable, config);
                }

                _subselectTarget.value = contentEditable.innerHTML;
            });
        });


        observer.observe(contentEditable, config);


        const isInTargetNode = function (node) {
            if (node === contentEditable) {
                return true;
            }

            if ("parentNode" in node && node.parentNode != null) {
                return isInTargetNode(node.parentNode);
            }
        };

        trigger.onclick = (e) => {
            e.preventDefault();
            const rng = Math.random().toString().replace(".", "");
            const className = insertClassName = "inserted" + rng;

            let selection = window.getSelection();
            let aElement = `<a class='inserted ${className}'>${window.getSelection()}</a>`;

            if ((selection.type === "Range" || selection.type === "Caret") && isInTargetNode(selection.anchorNode)) {
                document.execCommand("insertHTML", false, aElement);
            } else {
                contentEditable.innerHTML += aElement;
            }

            let query = element.getAttribute("data-insert-subselect");
            subselectTarget = [contentEditable];

            let linkElement = document.querySelector("." + className);
            linkElement.addEventListener("click", () => {
                window.open(linkElement.getAttribute("href"), '_blank');
            });

            window.location.hash = `q=${query}&start=0&action=subselect-insert`;
            window.setTimeout(() => {
                if (ctrl !== null) {
                    ctrl.openExtendedSearch(true);
                    ctrl.focus()
                }
            }, 1000);
        };
    });


    Array.prototype.slice.call(document.querySelectorAll("[data-search-catalogue]")).forEach((node) => {
        const fq = node.getAttribute("data-search-query");
        node.addEventListener('click', () => {
            const url = `q=${kSearchBaseQuery}&fq=${encodeURIComponent(fq)}&start=0&action=init_search&sort=score%20desc&rows=10`;
            window.location.hash = url;
        });

    });

    BasketUtil.activateLinks(window.document.body);

    const linkActionAttribute = "data-link-action";
    const linkFromAttribute = "data-link-from";
    const linkToAttribute = "data-link-to";

    Array.from(document.querySelectorAll(`[${linkActionAttribute}]`)).forEach(element => {
       const action = element.getAttribute(linkActionAttribute);
       const from = element.getAttribute(linkFromAttribute);
       const to = element.getAttribute(linkToAttribute);
       if(action == 'remove' && from && to){
           element.addEventListener('click', async () => {
                const confirmDeleteMessage = await I18N.translatePromise("editor.label.expression.list.confirm.remove");
                const confirmDelete = confirm(confirmDeleteMessage);
                if(confirmDelete){
                    const url = `${Utils.getBaseURL()}rsc/cmo/object/unlink/${from}/${to}`;
                    const resp = await fetch(url,{
                        method: "DELETE"
                    });
                    if(resp.status == 200){
                        alert(await I18N.translatePromise("editor.label.expression.list.remove.success"));
                        window.location.reload(true);
                    }
                }
           });
       }

    });

    const autoCompleteAttr = "data-autocomplete-field";
    Array.prototype.slice.call(document.querySelectorAll(`[${autoCompleteAttr}]`)).forEach((node) => {
        const field = node.getAttribute(autoCompleteAttr);
        const solrSearcher1 = new SolrSearcher();
        const autocompletionList = document.createElement('ul');

        autocompletionList.classList.add('autocomplete-list');
        autocompletionList.classList.add('inactive');
        node.parentElement.insertBefore(autocompletionList, node.nextSibling);

        const show = (show = true) => {
            const classes = autocompletionList.classList;
            (show ? classes.remove : classes.add).call(classes, 'inactive');
        };

        const search = () => {
            const searchString = node.value.trim();
            if (searchString.length < 2) {
                show(false);
            } else {
                solrSearcher1.search([
                    ['q', `${field}:"${searchString}"`],
                    ['fl', field],
                    ['hl', 'on'],
                    ['hl.fl', field],
                    ['rows', '1000'],
                    ['hl.preserveMulti', 'on']
                ], result => {
                    const allValues = new Set();
                    for (const objID in result.highlighting) {
                        if (result.highlighting.hasOwnProperty(objID)) {
                            const fieldValue = result.highlighting[objID][field];
                            (fieldValue instanceof Array ? fieldValue : [fieldValue]).forEach(v => {
                                if (v !== null && typeof v != "undefined") {
                                    allValues.add(v);
                                }
                            });
                        }
                    }
                    if (allValues.size > 0) {
                        show(true);
                        const valuesArr = [];
                        allValues.forEach(v => valuesArr.push(v));
                        autocompletionList.innerHTML = valuesArr.map(v => `<li>${v}</li>`).join("\n");
                        Array.prototype.forEach.call(autocompletionList.children, (child, index) => {
                            const content = child.textContent;
                            child.onclick = () => {
                                node.value = content;
                                show(false);
                            };
                        });
                    }
                });
            }
        };

        node.onkeydown = (ke) => {
            switch (ke.code) {
                case "Escape":
                    show(false);
                    break;
                case "Enter":
                    ke.preventDefault();
                    node.value = autocompletionList.querySelector(".current").textContent;
                    show(false);
                    break;
                case "ArrowDown":
                case "ArrowUp":
                    let current = autocompletionList.querySelector(".current");
                    let next: Element;

                    if (current !== null && typeof current !== "undefined") {
                        next = ke.code === "ArrowDown" ? current.nextElementSibling : current.previousElementSibling;

                        if (next === null || typeof next === "undefined") {
                            next = ke.code === "ArrowDown" ? autocompletionList.firstElementChild : autocompletionList.lastElementChild;
                        }

                        if (next != null && typeof next !== "undefined") {
                            current.classList.remove("current");
                        } else {
                            show(false);
                        }
                    } else {
                        next = ke.code === "ArrowDown" ? autocompletionList.firstElementChild : autocompletionList.lastElementChild;
                    }

                    if (next !== null) {
                        next.classList.add("current");
                    }
                    break;
                default:
                    search();
            }
        };

        node.onblur = () => {
            window.setTimeout(() => {
                show(false);
            }, 100);
        };

        node.onfocus = () => {
            search();
        };
    });


    const nodeList = document.querySelectorAll('div[data-on-screen-keyboard]');
    Array.from(nodeList).forEach((inputGroup) => {
        const input = inputGroup.querySelector('input[data-on-screen-keyboard-input], textarea[data-on-screen-keyboard-input]') as HTMLInputElement | HTMLTextAreaElement;
        const toggle = inputGroup.querySelector('button[data-on-screen-keyboard-toggle]') as HTMLButtonElement;
        enableKeyboard(input, toggle);
    });
});
