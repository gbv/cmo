import {SearchComponent} from 'search/SearchComponent';

let eContainer = document.querySelector("#e_suche");
let kContainer = document.querySelector("#k_suche");

let eSearch = new SearchComponent.SearchController(eContainer, "cmo.edition.search");
let kSearch = new SearchComponent.SearchController(kContainer, "cmo.catalog.search");

eContainer.addEventListener('click', ()=>{
    eContainer.setAttribute("class", "col-xs-8 col-md-8 col-lg-8");
    kContainer.setAttribute("class", "col-xs-4 col-md-4 col-lg-4");
    eSearch.activate();
    kSearch.deactivate();
});


kContainer.addEventListener('click', ()=>{
    kContainer.setAttribute("class", "col-xs-8 col-md-8 col-lg-8");
    eContainer.setAttribute("class", "col-xs-4 col-md-4 col-lg-4");
    kSearch.activate();
    eSearch.deactivate();
});

