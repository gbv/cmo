import {I18N} from 'other/I18N'

export module SearchComponent {
    export class SearchGUI {

        constructor(private container: Element, private placeHolderKey: string) {
            this.initGUI();
        }

        private extendedSearch: Element;
        private ownContainerElement: Element;
        private mainSearchInputElement: Element;

        private initGUI() {
            this.container.innerHTML =
                `
<div class="search">
    <input type="search" class="form-control mainSearch" name="q">
    <div class="extendedSearch closed">

    </div>
</div>
                `;

            this.ownContainerElement = this.container.querySelector(".search");
            this.mainSearchInputElement = this.ownContainerElement.querySelector(".mainSearch");
            this.extendedSearch = this.ownContainerElement.querySelector(".extendedSearch");

            I18N.I18N.translate(this.placeHolderKey, translation => this.mainSearchInputElement.setAttribute('placeholder', translation));
        }

        public getMainSearchInputElement() {
            return this.mainSearchInputElement;
        }

        public openExtendedSearch(open: boolean) {
            if (open) {
                this.extendedSearch.classList.remove("closed");
                this.extendedSearch.classList.add("opened");
            } else {
                this.extendedSearch.classList.add("closed");
                this.extendedSearch.classList.remove("opened");
            }
        }
    }


    export class SearchController {
        private view: SearchComponent.SearchGUI;

        constructor(container: Element, placeHolderKey: string) {
            this.view = new SearchGUI(container, placeHolderKey);
        }

        public getSolrQuery(): string {
            return `query`;
        }

        public activate() {
           // TODO: show only if extended search is selected
           // this.view.openExtendedSearch(true);
        }

        public deactivate() {
           // TODO: show only if extended search is selected
           // this.view.openExtendedSearch(false);
        }


    }

    export class SearchField {


        constructor(solrSearchField: string) {
            this._solrSearchField = solrSearchField;
        }

        private _solrSearchField: string;


        get solrSearchField(): string {
            return this._solrSearchField;
        }

        buildQueryPart() {

        }
    }

    export class ClassificationSearchField extends SearchField {

        constructor(solrSearchField: string, className: string) {
            super(solrSearchField);
            this._className = className;
        }

        private _className: string;


        get className(): string {
            return this._className;
        }
    }

}
