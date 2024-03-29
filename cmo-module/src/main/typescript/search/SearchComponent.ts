import {I18N} from 'other/I18N'
import {Classification, ClassificationResolver} from 'other/Classification'
import {
    CheckboxSearchFieldInput, ClassificationSearchFieldInput, DateSearchFieldInput, SearchGUI,
    TextSearchFieldInput
} from "./SearchFormGUI";
import {Utils} from "../other/Utils";
import {SearchFacetController} from "./SearchFacet";
import {SearchDescription} from "./SearchDescription";


export class SearchController {
    private view: SearchGUI;
    private _enabled: boolean = false;
    private _enabledHandlerList: Array<(enabled: boolean) => void> = [];
    private _resetSearchhandlerList: Array<() => void> = [];

    constructor(container: HTMLElement, private facetController: SearchFacetController, placeHolderKey: string, private baseQuery: string) {
        this.view = new SearchGUI(container, placeHolderKey, baseQuery);

        this.view.extenderIcon.addEventListener("click", () => {
            this.view.openExtendedSearch(!this.view.isExtendedSearchOpen());
        });

        this.view.searchIcon.addEventListener("click", () => {
            this._resetSearchhandlerList.forEach(e => e());
            this.setInputValue("");
            this.view.reset();
            this.facetController.reset();
        });

        facetController.addChangeHandler(() => {
            if (this.enable) {
                this.view.changed();
            }
        });

    }

    public getSearchDescription():Array<SearchDescription> {
        return this.view.getSearchDescription();
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

    public addResetSearchHandler(handler: () => void) {
        this._resetSearchhandlerList.push(handler);
    }

    public removeResetSearchHandler(handler: () => void) {
        let handlerIndex = this._resetSearchhandlerList.indexOf(handler);
        if (handlerIndex !== -1) {
            this._resetSearchhandlerList.splice(handlerIndex, 1);
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
            //this.view.getMainSearchInputElement().blur();
        }

        this._enabledHandlerList.forEach((handler) => handler(value));
    }

    public getSolrQuery(): Array<Array<string>> {
        let fqs = this.facetController.getQuery();
        let qps = this.view.getSolrQuery();
        let filterQueries = [ "fq" ];

        qps = qps.filter(qp => {
           if(qp.indexOf("{!join")!==-1){
               filterQueries.push(qp);
               return false;
           }
           return true;
        });

        let queries = [ "q", qps.join(" AND ") ];
        fqs.map(fq => `${fq.field}:${fq.value}`).forEach(fq => filterQueries.push(fq));
        let allQueries = [ queries, filterQueries ];

        return allQueries;
    }

    public setSolrQuery(queries: Array<Array<string>>) {
        let qps = [];
        for (let param of queries) {
            let [ paramName ] = param;
            if (paramName == "q" || paramName == "fq") {
                let values = param.slice(1);
                for (let value of values) {
                    qps.push(value);
                }
            }
        }
        this.view.setSolrQuery(qps);
    }


    public focus() {
        (<HTMLInputElement>this.view.getMainSearchInputElement()).focus();
    }

    private processDescription(name: string, description: any) {
        for (let index in description.fields) {
            let input = description.fields[ index ];

            if (input instanceof ClassificationSearchField) {
                let classField = <ClassificationSearchField> input;
                this.view.addExtendedField(name, new ClassificationSearchFieldInput(classField.solrSearchFields[ 0 ], classField.className, classField.level));
            } else if (input instanceof DateSearchField) {
                let dateField = <DateSearchField> input;
                this.view.addExtendedField(name, new DateSearchFieldInput(dateField.solrSearchFields, input.label))
            } else if (input instanceof CheckboxSearchField) {
                let osf = <CheckboxSearchField>input;
                this.view.addExtendedField(name, new CheckboxSearchFieldInput(osf.solrSearchFields, input.label, osf.value))
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
            this.view.createType(name, description.type, description.baseQuery);
            this.processDescription(name, description);
        }
    }

    public isExtendedSearchOpen() {
        return this.view.isExtendedSearchOpen();
    }

    public openExtendedSearch(open: boolean) {
        this.view.openExtendedSearch(open);
    }
}

export class SearchField {


    constructor(label: string, solrSearchFields: string[]) {
        this._solrSearchFields = solrSearchFields;
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

export class DateSearchField extends SearchField {
    constructor(label: string, solrSearchFields: string[]) {
        super(label, solrSearchFields);
    }
}

export class ClassificationSearchField extends SearchField {
    get level(): number {
        return this._level;
    }

    constructor(solrSearchField: string, className: string, level: number = -1) {
        super(className, [ solrSearchField ]);
        this._className = className;
        this._level = level;
    }

    private _className: string;
    private _level: number;


    get className(): string {
        return this._className;
    }
}


export class CheckboxSearchField extends SearchField {
    constructor(label: string, searchfield: string, private _value: string) {
        super(label, [ searchfield ]);
    }


    get value(): string {
        return this._value;
    }

}


