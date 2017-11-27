import {
    CheckboxSearchField,
    ClassificationSearchField, DateSearchField, SearchController, SearchField,

} from 'search/SearchComponent';
import {Utils} from "../other/Utils";
import {SearchDisplay} from "./SearchDisplay";
import {SearchFacetController} from "./SearchFacet";
import {StateController} from "./StateController";
import {SolrSearcher} from "../other/Solr";
import {BasketDisplay} from "./BasketDisplay";
import {BasketStore} from "./BasketStore";

let eContainer = <HTMLElement>document.querySelector("#e_suche");
let kContainer = <HTMLElement>document.querySelector("#k_suche");
let sideBar = <HTMLElement>document.querySelector("#sidebar");



let translationMap = {};

let subselectTarget = null;
let aditionalQuery = [];

let facet = new SearchFacetController(sideBar, translationMap,
    {
        field : "cmoType",
        type : "translate",
        translate : "editor.cmo.select."
    },
    {
        field : "cmo_makamler",
        type : "class"
    },
    {
        field : "cmo_usuler",
        type : "class"
    },
    {
        field : "cmo_musictype",
        type : "class"
    });

const eSearchBaseQuery = "category.top:\"cmo_kindOfData:edition\"";
const kSearchBaseQuery = "(category.top:\"cmo_kindOfData:source\" OR objectType:person)";

let eSearch = new SearchController(eContainer, facet, "cmo.edition.search", eSearchBaseQuery);
let kSearch = new SearchController(kContainer, facet, "cmo.catalog.search", kSearchBaseQuery);

/* enable/disable search on click */
eContainer.addEventListener('click', () => {
    eSearch.enable = true;
    kSearch.enable = false;
});

eSearch.addEnabledHandler((enabled) => {
    if (enabled) {
        eContainer.setAttribute("class", "col-xs-8 col-md-8 col-lg-8");
        kContainer.setAttribute("class", "col-xs-4 col-md-4 col-lg-4");
    }
});


kContainer.addEventListener('click', () => {
    kSearch.enable = true;
    eSearch.enable = false;

});

kSearch.addEnabledHandler((enabled) => {

    if (enabled) {
        kContainer.setAttribute("class", "col-xs-8 col-md-8 col-lg-8");
        eContainer.setAttribute("class", "col-xs-4 col-md-4 col-lg-4");
    }


});

let updateMainContainerSize = ()=>{
    let normalClass = [ "col-md-9", "col-lg-9" ];
    let largeClass = [ "col-md-12", "col-lg-12" ];

    if(kSearch.enable){
        largeClass.forEach(token=>mainContainer.classList.remove(token));
        normalClass.forEach(token=>mainContainer.classList.add(token));
        sideBar.style.display='block';
    }

    if(eSearch.enable){
        normalClass.forEach(token=>mainContainer.classList.remove(token));
        largeClass.forEach(token=>mainContainer.classList.add(token));
        sideBar.style.display='none';
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

eSearch.addExtended({
    mods : {
        type : "mods",
        baseQuery : [ "objectType:mods", "-complex:*" ],
        fields : [
            new ClassificationSearchField("category.top", "diniPublType"),
            new SearchField("editor.label.title", [ "mods.title", "mods.title.main", "mods.title.subtitle" ]),
            new SearchField("editor.label.name", [ "mods.nameIdentifier", "mods.name" ])

        ]
    },
    mods_complex : {
        type : "mods",
        baseQuery : [ "objectType:mods" ],
        fields : [
            new SearchField("editor.label.title", [ "mods.title", "mods.title.main", "mods.title.subtitle" ]),
            new SearchField("editor.label.name", [ "mods.nameIdentifier", "mods.name" ]),
            new SearchField("editor.label.publisher", [ "mods.publisher" ]),
            new ClassificationSearchField("category.top", "DDC"),
            new ClassificationSearchField("category.top", "diniPublType"),
            new DateSearchField("editor.legend.pubDate", [ "mods.dateIssued.range", "mods.dateIssued.host.range" ]),
        ]
    }
});

// Katalog Search field definition
kSearch.addExtended({
    expression : {
        type : "expression",
        baseQuery : [ "objectType:expression", "-complex:*" ],
        fields : [ new SearchField("editor.label.title", [ "title", "title.lang.en", "title.lang.tr", "title.lang.ota-arab" ]),
            new ClassificationSearchField("category.top", "iso15924"),
            new ClassificationSearchField("category.top", "rfc4646"),
            new ClassificationSearchField("category.top", "cmo_musictype"),
            new ClassificationSearchField("category.top", "cmo_makamler", 1),
            new ClassificationSearchField("category.top", "cmo_usuler", 1),
            new SearchField("editor.label.incip", [ "incip" ]) ],
    }
    ,
    expression_complex : {
        type : "expression",
        baseQuery : [ "objectType:expression" ],
        fields : [
            new SearchField("editor.label.title", [ "title", "title.lang.en", "title.lang.tr", "title.lang.ota-arab" ]),
            new ClassificationSearchField("category.top", "iso15924"),
            new ClassificationSearchField("category.top", "rfc4646"),
            new ClassificationSearchField("category.top", "cmo_musictype"),
            new ClassificationSearchField("category.top", "cmo_makamler", 1),
            new ClassificationSearchField("category.top", "cmo_usuler", 1),
            new ClassificationSearchField("{!join from=reference to=id}category.top", "cmo_sourceType"),
            new ClassificationSearchField("{!join from=reference to=id}category.top", "cmo_notationType"),
            new DateSearchField("editor.label.publishingDate", [ "{!join from=reference to=id}publish.date.range" ]),
            new SearchField("editor.label.composer", [ "{!join from=id to=composer.ref.pure}name" ]),
            new DateSearchField("editor.label.lifeData", [ "{!join from=id to=composer.ref.pure}birth.date.range" ]),
            new SearchField("editor.label.lyricist", [ "{!join from=id to=lyricist.ref.pure}name" ]),
            new DateSearchField("editor.label.lifeData", [ "{!join from=id to=lyricist.ref.pure}death.date.range" ]),
            new SearchField("editor.label.incip", [ "incip" ]),
            new CheckboxSearchField("cmo.hasFiles", "{!join from=reference to=id}hasFiles", "true"),
            new CheckboxSearchField("cmo.hasReference", "{!join from=mods.relatedItem to=id}*", "*"),
        ],
    },
    source : {
        type : "source",
        baseQuery : [ "objectType:source" ],
        fields : [
            new SearchField("editor.label.title", [ "title", "title.lang.en", "title.lang.tr", "title.lang.ota-arab" ]),
            new ClassificationSearchField("category.top", "cmo_sourceType"),
            new ClassificationSearchField("category.top", "cmo_notationType"),
            new ClassificationSearchField("category.top", "cmo_contentType"),
            new ClassificationSearchField("category.top", "iso15924"),
            new ClassificationSearchField("category.top", "rfc4646"),
            new DateSearchField("editor.label.publishingDate", [ "publish.date.range" ]),
            new SearchField("editor.label.contributer", [ "editor", "author", "respStmt", "hand.name" ]),
            new SearchField("editor.label.publishingInformation", [ "publisher", "publisher.place", "series",
                "repo.corpName", "repo.identifier", "repo.geogName", "history.event.eventGeogName" ]) ]
    },
    mods : {
        type : "bibl",
        baseQuery : [ "objectType:mods" ],
        fields : [
            new SearchField("editor.label.title", [ "mods.title", "mods.title.main", "mods.title.subtitle" ]),
            new SearchField("editor.label.name", [ "mods.nameIdentifier", "mods.name" ]),
            new SearchField("editor.label.publishingInformation", [ "mods.publisher", "mods.place",
                "mods.title.de.series", "mods.title.en.series", "mods.title.tr.series",
                "mods.title.de.host", "mods.title.en.host", "mods.title.tr.host" ]),
            /* new ClassificationSearchField("mods.ddc", "DDC"), */
            /* new ClassificationSearchField("mods.type", "diniPublType"), */
            new DateSearchField("editor.legend.pubDate", [ "mods.dateIssued.range", "mods.dateIssued.host.range" ])
        ]
    },
    person : {
        type : "person",
        baseQuery : [ "objectType:person" ],
        fields : [
            new SearchField("editor.label.name", [ "name", "name.general" ]),
            new DateSearchField("editor.label.lifeData", [ "date.range" ]),
            new CheckboxSearchField("editor.label.composer", "{!join from=composer.ref.pure to=id}composer.ref.pure", "*"),
            new CheckboxSearchField("editor.label.lyricist", "{!join from=lyricist.ref.pure to=id}lyricist.ref.pure", "*")
        ],

    },
    lyrics : {
        type : "expression",
        baseQuery : [ "objectType:expression", "cmo_musictype:gn-66217054-X" ],
        fields : [
            new SearchField("editor.label.title", [ "title", "title.lang.en", "title.lang.tr", "title.lang.ota-arab" ]),
            new SearchField("editor.label.identifier", [ "identifier" ]),
            new SearchField("editor.label.incip", [ "incip" ]),
            new ClassificationSearchField("category.top", "iso15924"),
            new ClassificationSearchField("category.top", "rfc4646"),
            new ClassificationSearchField("category.top", "cmo_musictype"),
            new ClassificationSearchField("category.top", "cmo_litform"),
            new ClassificationSearchField("category.top", "cmo_makamler", 1),
            new ClassificationSearchField("category.top", "cmo_usuler", 1),
            new SearchField("editor.label.lyricist", [ "lyricist" ]) ]
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

let resetJS= ()=>{
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
        let [ , action ] = StateController.getState().filter(([ key, value ]) => key == "action")[ 0 ] || [ undefined, undefined ];
        if (action != "search" && action != "subselect") {
            action = "search";
        }

        search(0, searchController, action)
    }, 500);
};

search = (start, searchController, action = "search", sortField: string = "score", asc: boolean = false) => {
    let queries = searchController.getSolrQuery();


    let params = queries
        .concat([ [ "start", start ] ])
        .concat([ [ "action", action ] ])
        .concat([ [ "sort", sortField + " " + (asc ? "asc" : "desc") ] ]);

    if (aditionalQuery.length > 0) {
        params = params.concat(aditionalQuery);
    }

    StateController.setState(params);
};


let getResultAction = (params) => {

    let [ , action ] = params.filter(([ key, value ]) => key == "action")[ 0 ] || [ null, null ];

    switch (action) {
        case "search":
            return (doc, result, hitOnPage) => {
                let param = "";
                for (let i in result.responseHeader.params) {
                    if (i == "wt" || i == "start" || i == "rows") {
                        continue;
                    }
                    if (result.responseHeader.params[ i ] instanceof Array) {
                        param += result.responseHeader.params[ i ].map(param => `${i}=${encodeURIComponent(param)}`).join("&") + "&";
                    } else {
                        param += `${i}=${ encodeURIComponent(result.responseHeader.params[ i ])}&`;
                    }
                }
                if (param[ param.length - 1 ] == "&") {
                    param = param.substring(0, param.length - 1);
                }
                param += `&start=${hitOnPage}&rows=1&origrows=${result.responseHeader.params[ "rows" ] || 10}&XSL.Style=browse`;
                window.location.href = `${Utils.getBaseURL()}servlets/solr/select?${param}`;
            };

        case "subselect":
            if (subselectTarget == null) {
                throw "subselect without set subselectTarget!";
            }


            return (doc, result, hitOnPage) => {
                resetJS();
                ctrl.setInputValue('');
                ctrl.enable = false;

                subselectTarget.forEach((sst) => {
                    let field = sst.getAttribute("data-subselect-target");
                    if ("value" in sst) {
                        let fieldValue = doc[ field ];
                        if (fieldValue instanceof Array) {
                            sst.value = fieldValue[ 0 ];
                        } else {
                            sst.value = fieldValue;
                        }
                    }
                });
                subselectTarget = null;
                window.location.hash = '';
            }
    }
};

let ctrl: SearchController = null;


StateController.onStateChange((params, selfChange) => {
    let [ , action ] = params.filter(([ key, value ]) => key == "action")[ 0 ] || [ null, null ];

    updateMainContainerSize();

    switch (action) {
        case "init_search":
            aditionalQuery = params.filter(([ key ]) => key !== 'q' && key !== 'action' && key !== "sort");
        case "search":
        case "subselect":
            ctrl = null;
            for (let param of params) {
                let [ , v ] = param;

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
                        searchDisplay.displayResult(result, (start) => {
                            search(start, ctrl, action);
                            window.scrollTo(0, 0);
                        }, getResultAction(params), (sortField, asc) => {
                            search(0, ctrl, action, sortField, asc);
                        });
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
    (<HTMLElement>element.querySelector("[data-subselect-trigger]")).onclick = () => {
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
//kSearch.getSolrQuery()


