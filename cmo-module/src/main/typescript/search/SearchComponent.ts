import {I18N} from 'other/I18N'
import {Classification, ClassificationResolver} from 'other/Classification'
import {ClassificationSearchFieldInput, SearchGUI, TextSearchFieldInput} from "./SearchFormGUI";
import {Utils} from "../other/utils";
import {SearchFacetController} from "./SearchFacet";


export class SearchController {
    private view: SearchGUI;
    private _enabled: boolean = false;
    private _enabledHandlerList: Array<(enabled: boolean) => void> = [];

    constructor(container: HTMLElement, private facetController: SearchFacetController, placeHolderKey: string, private baseQuery: string) {
        this.view = new SearchGUI(container, placeHolderKey, baseQuery);

        this.view.extenderIcon.addEventListener("click", () => {
            this.view.openExtendedSearch(!this.view.isExtendedSearchOpen());
        });

        this.view.searchIcon.addEventListener("click", () => {
            this.setInputValue("");
        });

        facetController.addChangeHandler(()=>{
            if(this.enable){
                this.view.changed();
            }
        });

    }


    public addEnabledHandler(handler: (enabled: boolean) => void) {
        this._enabledHandlerList.push(handler);
    }

    public removeEnabledHandler(handler: (enabled: boolean) => void) {
        let handlerIndex = this._enabledHandlerList.indexOf(handler);
        if (handlerIndex !== -1) {
            this._enabledHandlerList.splice(handlerIndex, 1);
        }
    }

    public addQueryChangedHandler(handler: () => void) {
        this.view._queryChangeHandlerList.push(handler);
    }

    public removeQueryChangedHandler(handler: () => void) {
        let handlerIndex = this.view._queryChangeHandlerList.indexOf(handler);
        if (handlerIndex !== -1) {
            this.view._queryChangeHandlerList.splice(handlerIndex, 1);
        }
    }

    get enable(): boolean {
        return this._enabled;
    }

    set enable(value: boolean) {
        this._enabled = value;

        if (value) {
            this.view.activateDeleteIcon();
            this.view.activateExtenderIcon();
        } else {
            this.view.activateSearchIcon();
            this.view.deactivateExtenderIcon();
            if (this.view.isExtendedSearchOpen()) {
                this.view.openExtendedSearch(false);
            }
            this.view.getMainSearchInputElement().blur();
        }

        this._enabledHandlerList.forEach((handler) => handler(value));
    }

    public getSolrQuery(): Array<Array<string>> {
        let fqs = this.facetController.getQuery();
        let queries = [ "q", this.view.getSolrQuery() ];
        let filterQueries = [ "fq" ];
        fqs.map(fq => `${fq.field}:${fq.value}`).forEach(fq => filterQueries.push(fq));
        let allQueries = [ queries, filterQueries ];

        return allQueries;
    }


    public focus() {
        (<HTMLInputElement>this.view.getMainSearchInputElement()).blur();
    }

    private processDescription(name: string, description: any) {
        for (let index in description.fields) {
            let input = description.fields[ index ];

            if (input instanceof ClassificationSearchField) {
                let classField = <ClassificationSearchField> input;
                this.view.addExtendedField(name, new ClassificationSearchFieldInput(classField.solrSearchFields[ 0 ], classField.className));
            } else if (input instanceof SearchField) {
                let textField = <SearchField> input;
                this.view.addExtendedField(name, new TextSearchFieldInput(textField.solrSearchFields, input.label));
            }
        }
    }

    public getInputValue(): string {
        return (<HTMLInputElement>this.view.getMainSearchInputElement()).value;
    }

    public setInputValue(value: string) {
        (<HTMLInputElement>this.view.getMainSearchInputElement()).value = value;
    }

    public addExtended(extendedDescription: any) {
        for (let name in extendedDescription) {
            let description = extendedDescription[ name ];
            this.view.createType(name, description.type);
            this.processDescription(name, description);
        }
    }
}

export class SearchField {


    constructor(label: string, ...solrSearchField: string[]) {
        this._solrSearchFields = solrSearchField;
        this._label = label;
    }

    private _solrSearchFields: string[];
    private _label: string;


    get solrSearchFields(): string[] {
        return this._solrSearchFields;
    }

    get label(): string {
        return this._label;
    }

}

export class ClassificationSearchField extends SearchField {

    constructor(solrSearchField: string, className: string) {
        super(className, solrSearchField);
        this._className = className;
    }

    private _className: string;


    get className(): string {
        return this._className;
    }
}


