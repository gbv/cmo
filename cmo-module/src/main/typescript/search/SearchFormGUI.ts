import {Utils} from "../other/utils";
import {I18N} from "../other/I18N";
import {Classification, ClassificationCategory, ClassificationResolver} from "../other/Classification";
export class SearchGUI {
    get extenderIcon(): HTMLImageElement {
        return this._extenderIcon;
    }

    get searchIcon(): HTMLImageElement {
        return this._searchIcon;
    }

    private extenderIconUrl: string;
    private minusIconUrl: string;
    private nameTypeMap: {} = {};


    constructor(private container: HTMLElement, private placeHolderKey: string, private baseQuery: string) {
        this.initGUI();
    }

    // icon urls filled by initGUI()
    private searchIconUrl: string;
    private searchClearIconUrl: string;

    private _searchIcon: HTMLImageElement;
    private _extenderIcon: HTMLImageElement;
    private typeLabel: Element;

    private extendedSearch: HTMLElement;
    private ownContainerElement: Element;
    private mainSearchInputElement: HTMLInputElement;
    private typeSelect: HTMLSelectElement;
    private typeMap = {};
    private currentType: string;
    public _queryChangeHandlerList: Array<() => void> = [];
    private lastQuery: string = null;

    private initGUI() {
        let baseURL = Utils.getBaseURL();
        this.searchIconUrl = `${baseURL}content/images/search.svg`;
        this.searchClearIconUrl = `${baseURL}content/images/search_clear.svg`;
        this.extenderIconUrl = `${baseURL}content/images/more.svg`;
        this.minusIconUrl = `${baseURL}content/images/minus.svg`;
        this.container.innerHTML =
            `
<div class="search">
    <img class="search icon" src="${this.searchIconUrl}">
    <input type="search" class="form-control mainSearch" name="q">
    <img class="extender icon hidden"src="${this.extenderIconUrl}">
    <div class="extendedSearch closed container">
        <div class="row">
            <div class="form-group">
                <label class="typeLabel col-md-3 control-label form-inline"></label>
                <div class="controls col-md-9">
                    <select class="type form-control form-control-inline"></select>            
                </div>
            </div>
        </div>
    </div>
</div>
                `;

        this.ownContainerElement = this.container.querySelector(".search");
        this.mainSearchInputElement = <HTMLInputElement>this.ownContainerElement.querySelector(".mainSearch");
        this.extendedSearch = <HTMLElement>this.ownContainerElement.querySelector(".extendedSearch");
        this.typeSelect = <HTMLSelectElement>this.extendedSearch.querySelector('select.type');
        this.typeLabel = this.extendedSearch.querySelector('label.typeLabel');
        this._searchIcon = <HTMLImageElement>this.container.querySelector(".icon.search");
        this._extenderIcon = <HTMLImageElement>this.container.querySelector(".icon.extender");
        I18N.translate(this.placeHolderKey, translation => this.mainSearchInputElement.setAttribute('placeholder', translation));
        I18N.translate("cmo.search.fields.type", translation => this.typeLabel.innerHTML = translation);

        this.typeSelect.addEventListener("change", () => {
            let newType = this.typeSelect.value;

            for (let inputIndex in this.typeMap[ this.currentType ]) {
                let input = <SearchFieldInput>this.typeMap[ this.currentType ][ inputIndex ];
                input.detach(this.extendedSearch);
                input.removeChangeHandler(this.changed);
            }

            for (let inputIndex in this.typeMap[ newType ]) {
                let input = <SearchFieldInput>this.typeMap[ newType ][ inputIndex ];
                input.attach(this.extendedSearch);
                input.addChangeHandler(this.changed);
            }

            this.currentType = newType;
            this.changed();
        });

        this.getMainSearchInputElement().addEventListener('keyup', this.changed);
    }

    public getMainSearchInputElement() {
        return this.mainSearchInputElement;
    }

    public openExtendedSearch(open: boolean) {
        if (open) {
            this.extendedSearch.classList.remove("closed");
            this.extendedSearch.classList.add("opened");
            this.extenderIcon.src = this.minusIconUrl;
        } else {
            this.extendedSearch.classList.add("closed");
            this.extendedSearch.classList.remove("opened");
            this.extenderIcon.src = this.extenderIconUrl;
        }
    }

    public isExtendedSearchOpen() {
        return this.extendedSearch.classList.contains("opened");
    }

    public createType(name: string, type: string) {
        if (this.currentType == null) {
            this.currentType = name;
        }
        this.nameTypeMap[ name ] = type;
        let extendOption = <HTMLOptionElement>document.createElement('option');

        let langKey = `editor.cmo.select.${name}`;
        extendOption.text = `???${langKey}???`;
        extendOption.value = name;

        I18N.translate(langKey, translation => {
            extendOption.text = translation;
        });

        this.typeSelect.appendChild(extendOption);
    }

    public addExtendedField(name: string, field: SearchFieldInput) {
        if (!(name in this.typeMap)) {
            this.typeMap[ name ] = [];
        }
        let arr = this.typeMap[ name ];
        arr.push(field);

        if (this.currentType == name) {
            field.attach(<HTMLImageElement>this.extendedSearch);
            field.addChangeHandler(this.changed);
        }
    }

    public activateDeleteIcon() {
        this._searchIcon.src = this.searchClearIconUrl;
    }

    public activateSearchIcon() {
        this._searchIcon.src = this.searchIconUrl;
    }

    public activateExtenderIcon() {
        this._extenderIcon.classList.remove("hidden");
    }

    public deactivateExtenderIcon() {
        this._extenderIcon.classList.add("hidden");
    }


    public getSolrQuery() {
        let solrQueryParts = [ this.baseQuery ];

        if (this.mainSearchInputElement.value.trim().length > 0) {
            solrQueryParts.push(`allMeta:"${this.mainSearchInputElement.value}"`);
        }

        if (this.isExtendedSearchOpen()) {
            solrQueryParts.push(`objectType:${this.nameTypeMap[ this.typeSelect.value ]}`);
            for (let inputIndex in this.typeMap[ this.currentType ]) {
                let input = <SearchFieldInput>this.typeMap[ this.currentType ][ inputIndex ];
                let solrQueryPart = input.getSolrQueryPart();
                if (solrQueryPart !== null) {
                    solrQueryParts.push(solrQueryPart);
                }
            }
        }

        return solrQueryParts.join(" AND ");
    }

    changed = () => {
        this._queryChangeHandlerList.forEach(handler => handler());
    }
}

export abstract class SearchFieldInput {


    constructor(searchFields: string[], label: string) {
        this._searchFields = searchFields;
        this._label = label;
    }

    private changeHandlerList: Array<() => void> = [];
    private _searchFields: string[];
    private _label: string;

    get searchFields(): string[] {
        return this._searchFields;
    }

    get label(): string {
        return this._label;
    }

    set label(value: string) {
        this._label = value;
    }

    public abstract attach(to: HTMLElement);

    public abstract detach(from: HTMLElement);

    public abstract getSolrQueryPart(): string;

    public addChangeHandler(handler: () => void) {
        this.changeHandlerList.push(handler);
    }

    public removeChangeHandler(handler: () => void) {
        let handlerIndex = this.changeHandlerList.indexOf(handler);
        if (handlerIndex !== -1) {
            this.changeHandlerList.splice(handlerIndex, 1);
        }
    }

    public changed() {
        for (let handlerIndex in this.changeHandlerList) {
            this.changeHandlerList[ handlerIndex ]();
        }
    }
}

export class TextSearchFieldInput extends SearchFieldInput {


    constructor(searchFields: string[], label: string) {
        super(searchFields, label);
        this.init();
    }

    private root: HTMLElement;
    private _template: string;

    private labelElement: HTMLElement;
    private input: HTMLInputElement;

    private init() {
        this._template = `
<div class="form-group">
    <label class="col-md-3 control-label form-inline"></label>
    <div class="col-md-9">
        <input class="form-control" type="search">
    </div>
</div>
`;

        this.root = <HTMLElement>document.createElement("div");
        this.root.classList.add("row");
        this.root.innerHTML = this._template;
        this.labelElement = <HTMLElement>this.root.querySelector("label");
        this.input = <HTMLInputElement>this.root.querySelector("input");

        I18N.translate(this.label, (translation) => {
            this.labelElement.innerText = translation;
        });

        this.input.addEventListener("keyup", (event) => {
            this.changed();
        });
    }


    public attach(to: HTMLElement) {
        to.appendChild(this.root);
    }

    public detach(from: HTMLElement) {
        from.removeChild(this.root);
    }

    public getSolrQueryPart(): string {
        if (this.input.value.trim().length > 0) {
            if (this.searchFields.length > 1) {
                return `(${this.searchFields.map(sf => `${sf}:"${this.input.value}"`).join(" OR ")})`
            } else {
                return `${this.searchFields}:"${this.input.value}"`
            }
        } else {
            return null;
        }
    }
}


export class ClassificationSearchFieldInput extends SearchFieldInput {

    constructor(searchField: string, private className: string) {
        super([ searchField ], "");
        this.init();
    }

    public init() {
        this._template = `
              <div class="form-group">
                  <label class="col-md-3 control-label form-inline"></label>
                  <div class="controls col-md-9">
                    <select class="form-control form-control-inline">
                        
                    </select>
                  </div>
              </div>
            `;

        this.root = <HTMLElement>document.createElement("div");
        this.root.classList.add("row");
        this.root.innerHTML = this._template;
        this.select = <HTMLSelectElement>this.root.querySelector("select");
        this.labelElement = <HTMLLabelElement>this.root.querySelector("label");


        ClassificationResolver.resolve(this.className, (classification) => {
            this.rootVal = classification.ID;

            let rightLabels = classification.label.filter(possibleLabel => possibleLabel.lang == I18N.getCurrentLanguage());

            if (rightLabels.length == 0) {
                this.labelElement.innerHTML = classification.label[ 0 ].text;
            } else {
                this.labelElement.innerHTML = rightLabels[ 0 ].text;
            }

            this.select.innerHTML = this.getOptionHTML(classification);
            this.select.addEventListener("change", () => {
                this.changed();
            });
        });
    }

    private root: HTMLElement;
    private rootVal: string;
    private _template: string;
    private select: HTMLSelectElement;

    private labelElement: HTMLElement;


    public attach(to: HTMLElement) {
        to.appendChild(this.root);
    }

    public detach(from: HTMLElement) {
        from.removeChild(this.root);
    }

    public getSolrQueryPart(): string {
        let field = `category.top:"${this.searchFields[ 0 ]}:${this.select.value}"`;
        return (this.select.value !== this.rootVal) ? field : null;
    }

    private getOptionHTML(clazz: Classification | ClassificationCategory, level = [ 0 ]): string {
        level.push(0);
        let lang = I18N.getCurrentLanguage();

        let labels = ("label" in clazz ?
            (<Classification>clazz).label : (<ClassificationCategory>clazz).labels);
        let label = (labels.filter(label => label.lang == lang)[ 0 ] || labels[ 0 ]).text;
        let html = `<option ${level.length == 0 ? 'selected="selected" disabled="disabled"' : ''}  value="${clazz.ID}">${level.map(i => "&nbsp;&nbsp;").join("")}${label}</option> 
                    ${("categories" in clazz) ? clazz.categories.map(o => this.getOptionHTML(o, level)).join() : ''}`;
        level.pop();
        return html;
    }
}
