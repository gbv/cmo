import {I18N} from 'other/I18N'
import {Classification, ClassificationResolver} from 'other/Classification'

import {ClassificationSearchFieldInput, SearchGUI, TextSearchFieldInput} from "./SearchFormGUI";
import {Utils} from "../other/utils";


export class SearchController {
    private view: SearchGUI;
    private _enabled: boolean = false;
    private _enabledHandlerList: Array<(enabled: boolean) => void> = [];

    constructor(container: Element, placeHolderKey: string, private baseQuery: string) {
        this.view = new SearchGUI(container, placeHolderKey, baseQuery);

        this.view.extenderIcon.addEventListener("click", () => {
            this.view.openExtendedSearch(!this.view.isExtendedSearchOpen());
        });

        this.view.searchIcon.addEventListener("click", () => {
            this.setInputValue("");
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

    public addQueryChangedHandler(handler: (newQuery: string) => void) {
        this.view._queryChangeHandlerList.push(handler);
    }

    public removeQueryChangedHandler(handler: (newQuery: string) => void) {
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

    public getSolrQuery(): string {
        return this.view.getSolrQuery();
    }


    public focus() {
        (<HTMLInputElement>this.view.getMainSearchInputElement()).blur();
    }

    private processDescription(type: string, description: any) {
        for (let index in description) {
            let field = description[ index ];


            if (field instanceof ClassificationSearchField) {
                let classField = <ClassificationSearchField> field;

                this.view.addExtendedField(type, new ClassificationSearchFieldInput(classField.solrSearchField, classField.className));

            } else if (field instanceof SearchField) {
                let textField = <SearchField> field;
                this.view.addExtendedField(type, new TextSearchFieldInput(textField.solrSearchField, field.label));
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
        for (let type in extendedDescription) {
            let description = extendedDescription[ type ];
            this.view.createType(type);
            this.processDescription(type, description);
        }
    }
}

export class SearchField {


    constructor(solrSearchField: string, label: string) {
        this._solrSearchField = solrSearchField;
        this._label = label;
    }

    private _solrSearchField: string;
    private _label: string;


    get solrSearchField(): string {
        return this._solrSearchField;
    }

    get label(): string {
        return this._label;
    }

}

export class ClassificationSearchField extends SearchField {

    constructor(solrSearchField: string, className: string) {
        super(solrSearchField, className);
        this._className = className;
    }

    private _className: string;


    get className(): string {
        return this._className;
    }
}


