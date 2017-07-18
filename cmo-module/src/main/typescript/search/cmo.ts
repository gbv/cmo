import {
    ClassificationSearchField, SearchController, SearchField,

} from 'search/SearchComponent';
import {Utils} from "../other/utils";
import {SearchDisplay, SolrSearcher} from "./SearchDisplay";
import {SearchFacetController} from "./SearchFacet";

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
let eSearch = new SearchController(eContainer, facet, "cmo.edition.search", "objectType:mods");
let kSearch = new SearchController(kContainer, facet, "cmo.catalog.search", "-objectType:mods");

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

// Katalog Search field definition
kSearch.addExtended({
    expression : {
        type : "expression",
        fields : [ new SearchField("editor.label.title", "title", "title.lang.en", "title.lang.tr", "title.lang.ota-arab"),
            new ClassificationSearchField("cmo_musictype", "cmo_musictype"),
            new ClassificationSearchField("cmo_makamler", "cmo_makamler"),
            new ClassificationSearchField("cmo_usuler", "cmo_usuler"),
            new SearchField("editor.label.incip", "incip") ],
    }
    ,
    expression_complex : {
        type : "expression",
        fields : [
            new SearchField("editor.label.title", "title", "title.lang.en", "title.lang.tr", "title.lang.ota-arab"),
            new SearchField("editor.label.identifier", "identifier"),
            new ClassificationSearchField("cmo_musictype", "cmo_musictype"),
            new ClassificationSearchField("cmo_makamler", "cmo_makamler"),
            new ClassificationSearchField("cmo_usuler", "cmo_usuler"),
            new SearchField("editor.label.composer", "composer"),
            new SearchField("editor.label.lyricist", "lyricist"),
            new SearchField("editor.label.incip", "incip")
        ],
    },
    source : {
        type : "source",
        fields : [
            new SearchField("editor.label.title", "title", "title.lang.en", "title.lang.tr", "title.lang.ota-arab"),
            new SearchField("editor.label.identifier", "identifier"),
            new ClassificationSearchField("cmo_sourceType", "cmo_sourceType"),
            new ClassificationSearchField("cmo_notationType", "cmo_notationType"),
            new ClassificationSearchField("cmo_contentType", "cmo_contentType"),
            new ClassificationSearchField("language", "rfc4646"),
            new SearchField("editor.label.publisher", "publishingInformation") ]
    },
    bibliography : {
        type : "bibl",
        fields : [
            new SearchField("editor.label.title", "title", "title.lang.en", "title.lang.tr", "title.lang.ota-arab"),
            new SearchField("editor.label.identifier", "identifier"),
            new SearchField("editor.label.publisher", "publishingInformation"),
            new SearchField("editor.label.series", "series") ]
    },
    person : {
        type : "person",
        fields : [
            new SearchField("editor.label.identifier", "identifier"),
            new SearchField("editor.label.name", "name") ]
    },
    lyrics : {
        type : "lyrics",
        fields : [
            new SearchField("editor.label.title", "title", "title.lang.en", "title.lang.tr", "title.lang.ota-arab"),
            new SearchField("editor.label.identifier", "identifier"),
            new SearchField("editor.label.incip", "incip"),
            new ClassificationSearchField("language", "rfc4646"),
            new ClassificationSearchField("cmo_musictype", "cmo_musictype"),
            new ClassificationSearchField("cmo_litform", "cmo_litform"),
            new ClassificationSearchField("cmo_makamler", "cmo_makamler"),
            new ClassificationSearchField("cmo_usuler", "cmo_usuler"),
            new SearchField("editor.label.lyricist", "lyricist") ]
    }
})
; // çekemez


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
let onQueryChanged = (searchController: SearchController) => {
    if (currentTimeOut !== null) {
        window.clearTimeout(currentTimeOut);
        currentTimeOut == null;
    }

    currentTimeOut = window.setTimeout(() => search(0), 500);

    let search = (start) => {
        searchDisplay.save();
        searchDisplay.loading();

        let queries = searchController.getSolrQuery();

        let params = queries
            .concat([ [ "facet.field" ].concat(facet.getFacetFields()) ])
            .concat([ [ "start", start ] ])
            .concat([ [ "facet", "true" ] ]);
        solrSearcher.search(
            params
            , (result => {
                searchDisplay.displayResult(result, (start) => {
                    search(start);
                    window.scrollTo(0, 0);
                });
                facet.displayFacet(result);
            }));
    };


};
kSearch.addQueryChangedHandler(() => onQueryChanged(kSearch));
eSearch.addQueryChangedHandler(() => onQueryChanged(eSearch));
//kSearch.getSolrQuery()


