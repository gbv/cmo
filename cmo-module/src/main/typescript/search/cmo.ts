import {
    ClassificationSearchField, DateSearchField, SearchController, SearchField,

} from 'search/SearchComponent';
import {Utils} from "../other/utils";
import {SearchDisplay, SolrSearcher} from "./SearchDisplay";
import {SearchFacetController} from "./SearchFacet";
import {StateController} from "./StateController";

let eContainer = <HTMLElement>document.querySelector("#e_suche");
let kContainer = <HTMLElement>document.querySelector("#k_suche");
let sideBar = <HTMLElement>document.querySelector("#sidebar");

let translationMap = {};

let facet = new SearchFacetController(sideBar, translationMap,
    {
        field : "objectType",
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
            new ClassificationSearchField("mods.type", "diniPublType"),
            new SearchField("editor.label.title", [ "mods.title", "mods.title.main", "mods.title.subtitle" ]),
            new SearchField("editor.label.name", [ "mods.nameIdentifier", "mods.name"])

        ]
    },
    mods_complex : {
        type : "mods",
        baseQuery : [ "objectType:mods" ],
        fields : [
            new SearchField("editor.label.title", [ "mods.title", "mods.title.main", "mods.title.subtitle" ]),
            new SearchField("editor.label.name", [ "mods.nameIdentifier", "mods.name"]),
            new SearchField("editor.label.identifier", ["mods.identifier"]),
            new SearchField("editor.label.publisher", ["mods.publisher"]),
            new ClassificationSearchField("mods.ddc", "DDC"),
            new ClassificationSearchField("mods.type", "diniPublType"),
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
            new ClassificationSearchField("cmo_musictype", "cmo_musictype"),
            new ClassificationSearchField("cmo_makamler", "cmo_makamler"),
            new ClassificationSearchField("cmo_usuler", "cmo_usuler"),
            new SearchField("editor.label.incip", [ "incip" ]) ],
    }
    ,
    expression_complex : {
        type : "expression",
        baseQuery : [ "objectType:expression" ],
        fields : [
            new SearchField("editor.label.title", [ "title", "title.lang.en", "title.lang.tr", "title.lang.ota-arab" ]),
            new SearchField("editor.label.identifier", [ "identifier" ]),
            new ClassificationSearchField("cmo_musictype", "cmo_musictype"),
            new ClassificationSearchField("cmo_makamler", "cmo_makamler"),
            new ClassificationSearchField("cmo_usuler", "cmo_usuler"),
            new SearchField("editor.label.composer", [ "composer" ]),
            new SearchField("editor.label.lyricist", [ "lyricist" ]),
            new SearchField("editor.label.incip", [ "incip" ])
        ],
    },
    source : {
        type : "source",
        baseQuery : [ "objectType:source" ],
        fields : [
            new SearchField("editor.label.title", [ "title", "title.lang.en", "title.lang.tr", "title.lang.ota-arab" ]),
            new SearchField("editor.label.identifier", [ "identifier" ]),
            new ClassificationSearchField("cmo_sourceType", "cmo_sourceType"),
            new ClassificationSearchField("cmo_notationType", "cmo_notationType"),
            new ClassificationSearchField("cmo_contentType", "cmo_contentType"),
            new ClassificationSearchField("language", "rfc4646"),
            new DateSearchField("editor.label.publishingDate", [ "publish.date.range" ]),
            new SearchField("editor.label.publisher", [ "publishingInformation" ]) ]
    },
    mods : {
        type : "bibl",
        baseQuery : [ "objectType:mods" ],
        fields : [
            new SearchField("editor.label.title", [ "mods.title", "mods.title.main", "mods.title.subtitle" ]),
            new SearchField("editor.label.name", [ "mods.nameIdentifier", "mods.name"]),
            new SearchField("editor.label.identifier", ["mods.identifier"]),
            new SearchField("editor.label.publisher", ["mods.publisher"]),
            new ClassificationSearchField("mods.ddc", "DDC"),
            new ClassificationSearchField("mods.type", "diniPublType"),
            new DateSearchField("editor.legend.pubDate", [ "mods.dateIssued.range", "mods.dateIssued.host.range" ])
        ]
    },
    person : {
        type : "person",
        baseQuery : [ "objectType:person" ],
        fields : [
            new SearchField("editor.label.identifier", [ "identifier" ]),
            new SearchField("editor.label.name", [ "name" ]),
            new DateSearchField("editor.label.lifeData", [ "birth.date.range", "death.date.range" ]),
        ],

    },
    lyrics : {
        type : "expression",
        baseQuery : [ "objectType:expression", "cmo_musictype:gn-66217054-X" ],
        fields : [
            new SearchField("editor.label.title", [ "title", "title.lang.en", "title.lang.tr", "title.lang.ota-arab" ]),
            new SearchField("editor.label.identifier", [ "identifier" ]),
            new SearchField("editor.label.incip", [ "incip" ]),
            new ClassificationSearchField("language", "rfc4646"),
            new ClassificationSearchField("cmo_musictype", "cmo_musictype"),
            new ClassificationSearchField("cmo_litform", "cmo_litform"),
            new ClassificationSearchField("cmo_makamler", "cmo_makamler"),
            new ClassificationSearchField("cmo_usuler", "cmo_usuler"),
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
let searchDisplayContainer = document.querySelector("#main");
let searchDisplay = new SearchDisplay(<HTMLElement>searchDisplayContainer);
let solrSearcher = new SolrSearcher();

let currentTimeOut = null;
let search;

let onQueryChanged = (searchController: SearchController) => {
    if (currentTimeOut !== null) {
        window.clearTimeout(currentTimeOut);
        currentTimeOut == null;
    }

    currentTimeOut = window.setTimeout(() => search(0, searchController), 500);
};

search = (start, searchController) => {
    let queries = searchController.getSolrQuery();

    let params = queries
        .concat([ [ "start", start ] ]);

    StateController.setState(params);
};


StateController.onStateChange((params, selfChange) => {
    let ctrl: SearchController = null;
    for (let param of params) {
        let [ , v ] = param;

        if (v.indexOf(kSearchBaseQuery) != -1) {
            console.log("kSearch!");
            ctrl = kSearch;
        } else if (v.indexOf(eSearchBaseQuery) != -1) {
            console.log("eSearch!");
            ctrl = eSearch;
        }

    }

    searchDisplay.reset();
    facet.reset();

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
                    search(start, ctrl);
                    window.scrollTo(0, 0);
                });
                facet.displayFacet(result);
            }));
    }
});
kSearch.addQueryChangedHandler(() => onQueryChanged(kSearch));
eSearch.addQueryChangedHandler(() => onQueryChanged(eSearch));
//kSearch.getSolrQuery()


