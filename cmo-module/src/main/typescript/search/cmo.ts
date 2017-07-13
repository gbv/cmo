import {
    ClassificationSearchField, SearchController, SearchField,

} from 'search/SearchComponent';
import {Utils} from "../other/utils";
import {SearchDisplay, SolrSearcher} from "./SearchDisplay";

let eContainer = document.querySelector("#e_suche");
let kContainer = document.querySelector("#k_suche");

let eSearch = new SearchController(eContainer, "cmo.edition.search", "objectType:mods");
let kSearch = new SearchController(kContainer, "cmo.catalog.search", "-objectType:mods");

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
    expression : [
        new SearchField("title", "editor.label.title"),
        new ClassificationSearchField("cmo_musictype", "cmo_musictype"),
        new ClassificationSearchField("cmo_makamler", "cmo_makamler"),
        new ClassificationSearchField("cmo_usuler", "cmo_usuler"),
        new SearchField("incip", "editor.label.incip")
    ],
    expression_complex : [
        new SearchField("title", "editor.label.title"),
        new SearchField("identifier",  "editor.label.identifier"),
        new ClassificationSearchField("cmo_musictype", "cmo_musictype"),
        new ClassificationSearchField("cmo_makamler", "cmo_makamler"),
        new ClassificationSearchField("cmo_usuler", "cmo_usuler"),
        new SearchField("composer",  "editor.label.composer"),
        new SearchField("lyricist",  "editor.label.lyricist"),
        new SearchField("incip", "editor.label.incip")
    ],
    source : [
        new SearchField("title", "editor.label.title"),
        new SearchField("identifier","editor.label.identifier"),
        new ClassificationSearchField("cmo_sourceType", "cmo_sourceType"),
        new ClassificationSearchField("cmo_notationType", "cmo_notationType"),
        new ClassificationSearchField("cmo_contentType", "cmo_contentType"),
        new ClassificationSearchField("language", "rfc4646"),
        new SearchField("publishingInformation","editor.label.publisher")
    ],
    bibliography : [
        new SearchField("title", "editor.label.title"),
        new SearchField("identifier", "editor.label.identifier"),
        new SearchField("publishingInformation", "editor.label.publisher"),
        new SearchField("series", "editor.label.series")
    ],
    person : [
        new SearchField("identifier", "editor.label.identifier"),
        new SearchField("name", "editor.label.name")
    ],
    lyrics : [
        new SearchField("title", "editor.label.title"),
        new SearchField("identifier", "editor.label.identifier"),
        new SearchField("incip", "editor.label.incip"),
        new ClassificationSearchField("language", "rfc4646"),
        new ClassificationSearchField("cmo_musictype", "cmo_musictype"),
        new ClassificationSearchField("cmo_litform", "cmo_litform"),
        new ClassificationSearchField("cmo_makamler", "cmo_makamler"),
        new ClassificationSearchField("cmo_usuler", "cmo_usuler"),
        new SearchField("lyricist",  "editor.label.lyricist")
    ]
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
let onQueryChanged = (query) => {
    if (currentTimeOut !== null) {
        window.clearTimeout(currentTimeOut);
        currentTimeOut == null;
    }

    currentTimeOut = window.setTimeout(() => search(0), 500);
    let search = (start) => {
        searchDisplay.loading();
        solrSearcher.search([ [ "q", query ], [ "start", start ] ], (result => {
            console.log(result);
            searchDisplay.displayResult(result, (start) => {
                search(start);
            });
        }));
    };

};
kSearch.addQueryChangedHandler(onQueryChanged);
eSearch.addQueryChangedHandler(onQueryChanged);
//kSearch.getSolrQuery()


