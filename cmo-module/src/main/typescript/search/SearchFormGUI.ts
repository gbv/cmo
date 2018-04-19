import {UserInputParser, Utils} from "../other/Utils";
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
    private nameBaseQueryMap: any = {};


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
    private fieldSFIMap = {};
    private lastQuery: string = null;
    private _wasExtendedSearchOpen: boolean = false;


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
                <label class="typeLabel col-md-4 control-label form-inline"></label>
                <div class="controls col-md-8">
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
            this.typeChanged();
        });

        this.getMainSearchInputElement().addEventListener('keyup', this.changed);
    }

    public reset() {
        this._wasExtendedSearchOpen = false;
        this.openExtendedSearch(false);
        for (let formsIndex in this.typeMap) {
            if (this.typeMap.hasOwnProperty(formsIndex)) {
                let forms = this.typeMap[ formsIndex ];
                for (let form of forms) {
                    form.reset();
                }
            }

        }
        this.changed()
    }

    private typeChanged(userCause = true) {
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
        if (userCause) {
            this.changed();
        }
    }

    public getMainSearchInputElement() {
        return this.mainSearchInputElement;
    }

    public openExtendedSearch(open: boolean) {
        if (open) {
            this._wasExtendedSearchOpen = true;
            this.extendedSearch.classList.remove("closed");
            this.extendedSearch.classList.add("opened");
            this.extenderIcon.src = this.minusIconUrl;
            this.extendedSearch.style.maxHeight = (window.innerHeight - this.mainSearchInputElement.clientHeight) + "px";
        } else {
            this.extendedSearch.classList.add("closed");
            this.extendedSearch.classList.remove("opened");
            this.extenderIcon.src = this.extenderIconUrl;
        }
    }

    public isExtendedSearchOpen() {
        return this.extendedSearch.classList.contains("opened");
    }

    public createType(name: string, type: string, baseQuery: Array<string>) {
        if (this.currentType == null) {
            this.currentType = name;
        }
        this.nameTypeMap[ name ] = type;
        this.nameBaseQueryMap[ name ] = baseQuery;
        let extendOption = <HTMLOptionElement>document.createElement('option');

        let langKey;
        if (name == 'mods' && type == 'bibl') {
            langKey = `editor.cmo.select.bibliography`;
        }
        else {
            langKey = `editor.cmo.select.${name}`;
        }
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

        for (let searchField of field.searchFields) {
            if (!(searchField in this.fieldSFIMap)) {
                this.fieldSFIMap[ searchField ] = [];
            }
            this.fieldSFIMap[ searchField ].push(field);
        }

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


    public getSolrQuery():string[] {
        let solrQueryParts = [ this.baseQuery ];

        if (this.mainSearchInputElement.value.trim().length > 0) {
            let iter = UserInputParser.parseUserInput(this.mainSearchInputElement.value);
            let next: IteratorResult<string>;
            while (!(next = iter.next()).done) {
                solrQueryParts.push(`allMeta:${next.value}`);
            }
        }

        if (this.isExtendedSearchOpen() || this.wasExtendedSearchOpen()) {
            this.nameBaseQueryMap[ this.typeSelect.value ].forEach(bq => solrQueryParts.push(bq));

            for (let inputIndex in this.typeMap[ this.currentType ]) {
                let input = <SearchFieldInput>this.typeMap[ this.currentType ][ inputIndex ];
                let solrQueryPart = input.getSolrQueryPart();
                if (solrQueryPart !== null) {
                    solrQueryParts.push(solrQueryPart);
                }
            }
        }


        return solrQueryParts;
    }

    public setSolrQuery(query: string[]) {
        let kvMap = {};

        let bqMap = this.nameBaseQueryMap;

        let process = (queryParts) => {
            for (let queryPart of queryParts) {
                if (queryPart.indexOf("(") != 0) {
                    let [ field ] = queryPart.split(":", 1);
                    let value = field != "allMeta" ?
                        Utils.stripSurrounding(queryPart.substring(queryPart.indexOf(":") + 1, queryPart.length), '"')
                        : queryPart.substring(queryPart.indexOf(":") + 1, queryPart.length);
                    kvMap[ field ] = value;
                } else {
                    let clean = Utils.stripSurrounding(Utils.stripSurrounding(queryPart, "("), ")");
                    process(clean.split(" OR "));
                }
            }
        };
        query.map(s=>s.split(" AND ")).forEach(process);
        let sortedByComplexity = [];

        for (let name in bqMap) {
            if (!bqMap.hasOwnProperty(name)) {
                continue;
            }
            let baseQuery = bqMap[ name ];
            sortedByComplexity.push([ name, baseQuery ]);
        }

        let kvSet = [];

        for (let k in kvMap) {
            if (!kvMap.hasOwnProperty(k)) {
                continue;
            }

            let v = kvMap[ k ];
            kvSet.push(`${k}:${v}`);
        }
        sortedByComplexity = sortedByComplexity.sort(([ , bq1 ], [ , bq2 ]) => bq2.length - bq1.length);

        for (let entry of sortedByComplexity) {
            let [ name, baseQuery ] = entry;
            let isMatching = true;
            for (let bq of baseQuery) {
                isMatching = isMatching && kvSet.indexOf(bq) != -1;
                if (!isMatching) {
                    break;
                }
            }

            if (isMatching) {
                if (this.typeSelect.value !== name) {
                    this._wasExtendedSearchOpen=true;
                    this.typeSelect.value = name;
                    this.typeChanged(false);
                }
                break;
            }
        }

        this.mainSearchInputElement.value = "";
        for (let key in kvMap) {
            let value = kvMap[ key ];

            if (key == "allMeta") {
                this.mainSearchInputElement.value += value;
            }

            /*if (key == "objectType" && value in this.typeMap) {
                if (this.typeSelect.value !== value) {
                    this.typeSelect.value = value;
                    this.typeChanged(false);
                }
            }*/

            if (key in this.fieldSFIMap) {
                let searchFieldGUIs = this.fieldSFIMap[ key ];
                for (let gui of searchFieldGUIs) {
                    gui.setValue(value);
                }
            }
        }
    }

    changed = () => {
        this._queryChangeHandlerList.forEach(handler => handler());
    };


    public wasExtendedSearchOpen() {
        return this._wasExtendedSearchOpen;
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

    public abstract setValue(value: any);

    public abstract reset();

}

export class TextSearchFieldInput extends SearchFieldInput {


    constructor(searchFields: string[], label: string) {
        super(searchFields, label);
        this.init();
    }

    public root: HTMLElement;
    public _template: string;

    public labelElement: HTMLElement;
    public input: HTMLInputElement;

    public init() {
        this._template = this.getTemplate();

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

    public getTemplate() {
        return `
<div class="form-group">
    <label class="col-md-4 control-label form-inline"></label>
    <div class="col-md-8">
        <input class="form-control" type="search">
    </div>
</div>
`;
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
                return `(${this.searchFields.map(sf => `${sf}:${this.input.value.indexOf(" ")==-1 ? this.input.value:'"'+this.input.value + '"'}`).join(" OR ")})`
            } else {
                return `${this.searchFields}:${this.input.value.indexOf(" ")==-1 ? this.input.value:'"'+this.input.value + '"'}`
            }
        } else {
            return null;
        }
    }

    setValue(value: any) {
        this.input.value = UserInputParser.unescapeSpecialCharacters(value);
    }

    reset() {
        this.setValue("");
    }
}

export class CheckboxSearchFieldInput extends SearchFieldInput {
    constructor(searchfields: string[], label: string, private value: string) {
        super(searchfields, label);
        this.init();
    }

    private root: HTMLElement;
    private labelElement: HTMLElement;
    private _template: string;
    private input: HTMLInputElement;

    public init() {
        this._template = `
              <div class="form-group">
                  <div class="col-md-4 control-label form-inline"></div>
                  <div class="controls col-md-8">
                      <div class="checkbox">
                        <label>
                            <input type="checkbox"/>
                            <span class="slabel"></span>
                        </label>
                      </div>
                  </div>
              </div>
            `;
        this.root = <HTMLElement>document.createElement("div");
        this.root.classList.add("row");
        this.root.innerHTML = this._template;
        this.labelElement = <HTMLElement>this.root.querySelector(".slabel");
        this.input = <HTMLInputElement>this.root.querySelector("input");

        this.input.addEventListener("change", () => {
            this.changed()
        });

        I18N.translate(this.label, (translation) => {
            this.labelElement.innerText = translation;
        });
    }

    public attach(to: HTMLElement) {
        to.appendChild(this.root);
    }

    public detach(from: HTMLElement) {
        from.removeChild(this.root);
    }

    getSolrQueryPart(): string {
        return this.input.checked ? this.searchFields[ 0 ] + ":" + this.value : null;
    }

    setValue(value: any) {
        if (value == this.value) {
            this.input.checked = true;
        }
    }

    reset() {

    }

}

export class ClassificationSearchFieldInput extends SearchFieldInput {

    constructor(searchField: string, private className: string, private level) {
        super([ searchField ], "");
        this.init();
    }

    public init() {
        this._template = `
              <div class="form-group">
                  <label class="col-md-4 control-label form-inline"></label>
                  <div class="controls col-md-8">
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

            let labels = classification.label
                .filter(clazzLabel => clazzLabel.lang.indexOf("x-") != 0);

            let rightLabels = labels.filter(possibleLabel => possibleLabel.lang == I18N.getCurrentLanguage());

            if (rightLabels.length == 0) {
                this.labelElement.innerHTML = labels[ 0 ].text;
            } else {
                this.labelElement.innerHTML = rightLabels[ 0 ].text;
            }

            this.select.innerHTML = this.getOptionHTML(classification);
            this.select.addEventListener("change", () => {
                this.changed();
            });

            if (this._resolveHanging != null) {
                this._resolveHanging();
            }
        });
    }

    private _resolveHanging = null;
    private root: HTMLElement;
    private rootVal: string;
    private _template: string;
    private select: HTMLSelectElement;

    private labelElement: HTMLElement;

    public reset() {
        this.select.values = this.select.options.item(0).innerText;
    }

    public attach(to: HTMLElement) {
        to.appendChild(this.root);
    }

    public detach(from: HTMLElement) {
        from.removeChild(this.root);
    }

    public getSolrQueryPart(): string {
        let field = `${this.searchFields[ 0 ]}:"${this.className}:${this.select.value}"`;
        return (this.select.value !== this.rootVal) ? field : null;
    }

    private getOptionHTML(clazz: Classification | ClassificationCategory, level = [ 0 ]): string {
        level.push(0);
        let lang = I18N.getCurrentLanguage();

        let labels = ("label" in clazz ?
            (<Classification>clazz).label : (<ClassificationCategory>clazz).labels);
        labels = labels.filter(clazzLabel => clazzLabel.lang.indexOf("x-") != 0);
        let label = (labels.filter(label => label.lang == lang)[ 0 ] || labels[ 0 ]).text;
        let html = `<option ${level.length == 0 ? 'selected="selected" disabled="disabled"' : ''}  value="${clazz.ID}">${level.map(i => "&nbsp;&nbsp;").join("")}${label}</option>
                    ${("categories" in clazz && (this.level < 0 || this.level >= (level.length - 1))) ?
            clazz.categories.map(o => this.getOptionHTML(o, level)).join() : ''}`;
        level.pop();
        return html;
    }

    setValue(value: any) {
        let realValue = value.split(":")[ 1 ];
        if (this.select.querySelector("option[value='" + realValue + "']") != null) {
            this.select.value = realValue;
        } else {
            this._resolveHanging = () => {
                if (this.select.querySelector("option[value='" + realValue + "']") != null) {
                    this.select.value = realValue;
                }
            }
        }

    }
}


export class DateSearchFieldInput extends TextSearchFieldInput {


    public init() {
        this._template = this.getTemplate();

        this.root = <HTMLElement>document.createElement("div");
        this.root.classList.add("row");
        this.root.innerHTML = this._template;
        this.labelElement = <HTMLElement>this.root.querySelector("label.date");
        this.input = <HTMLInputElement>this.root.querySelector("input.noRange");
        this.inputFrom = <HTMLInputElement>this.root.querySelector("input.from");
        this.inputTo = <HTMLInputElement>this.root.querySelector("input.to");
        this.inputRangeCheckbox = <HTMLInputElement>this.root.querySelector("input.checkbox");
        this.rangeLabel = <HTMLLabelElement>this.root.querySelector("label.range");

        this.rangeBox = <HTMLDivElement>this.root.querySelector("div.range");
        this.noRangeBox = <HTMLDivElement>this.root.querySelector("div.noRange");

        this.fromLabel = <HTMLLabelElement>this.rangeBox.querySelector("label.from");
        this.toLabel = <HTMLLabelElement>this.rangeBox.querySelector("label.to");

        I18N.translate(this.label, (translation) => {
            this.labelElement.innerText = translation;
        });

        this.input.addEventListener("keyup", (event) => {
            this.changed();
        });

        this.inputFrom.addEventListener("keyup", (event) => {
            this.changed();
        });

        this.inputTo.addEventListener("keyup", (event) => {
            this.changed();
        });

        this.inputRangeCheckbox.addEventListener("change", (event) => {
            this.rangeCheckBoxChanged();
            this.changed();
        });

        I18N.translate("cmo.search.range", (translation) => {
            this.rangeLabel.innerText = translation;
        });

        I18N.translate("cmo.search.range.from", (translation) => {
            this.fromLabel.innerText = translation;
        });

        I18N.translate("cmo.search.range.to", (translation) => {
            this.toLabel.innerText = translation;
        });
    }

    public inputFrom: HTMLInputElement;
    public inputTo: HTMLInputElement;
    public inputRangeCheckbox: HTMLInputElement;
    public rangeLabel: HTMLLabelElement;
    private rangeBox: HTMLDivElement;
    private noRangeBox: HTMLDivElement;
    private fromLabel: HTMLLabelElement;
    private toLabel: HTMLLabelElement;

    private rangeCheckBoxChanged() {
        if (this.isRangeSelected()) {
            this.noRangeBox.classList.add("hidden");
            this.rangeBox.classList.remove("hidden");
        } else {
            this.rangeBox.classList.add("hidden");
            this.noRangeBox.classList.remove("hidden");
        }
    }

    private isRangeSelected() {
        return this.inputRangeCheckbox.checked;
    }

    attach(to: HTMLElement) {
        super.attach(to);
    }

    public changed() {
        if (this.validate()) {
            super.changed();
        }
    }

    public getSolrQueryPart(): string {
        if (this.isRangeSelected()) {
            let val1 = UserInputParser.escapeSpecialCharacters(this.inputFrom.value), val2 = UserInputParser.escapeSpecialCharacters(this.inputTo.value);
            if (val1.trim().length > 0 && val2.trim().length > 0) {
                return this.getQueryForValue(`[${val1} TO ${val2}]`);
            } else if (val1.trim().length > 0) {
                return this.getQueryForValue(`[${val1} TO *]`);
            } else if (val2.trim().length > 0) {
                return this.getQueryForValue(`[* TO ${val2}]`);
            } else {
                return null;
            }
        } else {

            if (this.input.value.trim().length > 0) {
                return this.getQueryForValue(UserInputParser.escapeSpecialCharacters(this.input.value));
            } else {
                return null;
            }
        }
    }

    private getQueryForValue(value: any) {
        return this.searchFields.length > 1 ? `(${this.searchFields.map(sf => `${sf}:${value}`).join(" OR ")})` : `${this.searchFields}:${value}`;
    }

    setValue(value: any) {
        if (value.indexOf(" TO ") == -1) {
            this.input.setAttribute("value", UserInputParser.unescapeSpecialCharacters(value));
        } else {
            this.inputRangeCheckbox.checked = true;
            let fromToString = Utils.stripSurrounding(Utils.stripSurrounding(value, "["), "]");

            let [ from, to ] = fromToString.split(" TO ", 2);
            if (from !== "*") {
                this.inputFrom.setAttribute("value", UserInputParser.unescapeSpecialCharacters(from));
            }
            if (to !== "*") {
                this.inputTo.setAttribute("value", UserInputParser.unescapeSpecialCharacters(to));
            }
            this.rangeCheckBoxChanged();
        }
    }

    public getTemplate() {
        let checkBoxID = Math.random().toString();

        return `
<div class="form-group">
    <label class="col-md-4 control-label form-inline date"></label>
    <div class="col-md-8">
        <div class="form-inline">
            <input id="date_${checkBoxID}" class="checkbox inline" type="checkbox" />
            <label for="#date_${checkBoxID}" class="range inline"> </label>
        </div>
        <div class="form-inline noRange">
            <input class="form-control noRange inline datepicker" type="text" placeholder="1788-03-28" />
        </div>
        <div class="form-inline range hidden input-group input-daterange">
            <label for="#date_1_${checkBoxID}" class="range inline from input-group-addon"> </label>
            <input id="date_1_${checkBoxID}" class="form-control inline from datepicker" type="text" placeholder="1788-03-28" />
            <label for="#date_2_${checkBoxID}" class="range inline to input-group-addon"> </label>
            <input  id="date_2_${checkBoxID}" class="form-control inline to datepicker" type="text" placeholder="1840" />
        </div>
    </div>
</div>`;
    }

    private validate() {

        let markForm = (form: HTMLElement, valid) => {
            let invalidClass = "has-error";

            if (valid) {
                form.classList.remove(invalidClass);
            } else {
                form.classList.add(invalidClass);
            }
        };

        let getDate = (date) => {
            let regExp = /^([0-9][0-9]?[0-9]?[0-9]?)(-[0-1][0-9])?(-[0-3][0-9])?$/;

            if (!regExp.test(date)) {
                return null;
            }

            let [ , yearString, monthMatch, dayMatch ] = regExp.exec(date);

            let year = parseInt(yearString, 10);
            if (isNaN(year)) {
                return null;
            }

            let valDate = new Date();
            valDate.setFullYear(year);


            if (monthMatch != undefined) {
                let monthString = monthMatch.substring(1);
                let month = parseInt(monthString, 10);
                if (!(month >= 1 && month <= 12)) {
                    return null;
                }

                valDate.setMonth(month);

                if (dayMatch != undefined) {
                    let dayString = dayMatch.substring(1);
                    let day = parseInt(dayString, 10);
                    if (!(day >= 1 && day <= 31)) {
                        return null;
                    }

                    valDate.setDate(day);
                }
            } else if (dayMatch != undefined) {
                console.log("edge case!");
                return null;
            }

            return valDate.getTime();
        };

        let inputValues: Array<string>;
        let formToMark;
        let rangeSelected = this.isRangeSelected();
        if (rangeSelected) {
            inputValues = [ this.inputFrom.value.trim(), this.inputTo.value.trim() ];
            formToMark = this.rangeBox;
        } else {
            inputValues = [ this.input.value.trim() ];
            formToMark = this.noRangeBox;
        }

        let result = inputValues.filter(s => s.length > 0).map(getDate);
        let isValid = result.indexOf(null) == -1 && (!rangeSelected || (result[ 0 ] < result[ 1 ] ));
        markForm(formToMark, isValid);
        return isValid;
    }
}
