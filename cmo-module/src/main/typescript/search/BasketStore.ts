import {CMOBaseDocument, SolrSearcher} from "../other/Solr";

export class BasketStore {

    private static BASKET_STORE_KEY = "BasketStore";
    private static _instance: BasketStore = (() => BasketStore.load())();

    public static getInstance() {
        return BasketStore._instance;
    }

    private _store: Array<string> = [];
    private _listener = [];


    public addListener(listener: () => void) {
        if (this._listener.indexOf(listener) == -1) {
            this._listener.push(listener);
        }
    }

    public removeListener(listener: () => void) {
        let index = this._listener.indexOf(listener);
        if (index !== -1) {
            this._listener.splice(index, 1);
        }
    }

    public add(...docs: string[]) {
        docs.forEach(docID => {
            this._store.push(docID);
        });
        this.save();
        this._listener.forEach(listener => listener());
    }

    public remove(...docs: string[]) {
        docs.forEach(docID => {
            let index = this._store.indexOf(docID);
            if (index !== -1) {
                this._store.splice(index, 1);
            }
        });
        this.save();
        this._listener.forEach(listener => listener());
    }

    public contains(id: string) {
        return this._store.indexOf(id) !== -1;
    }

    public getDocuments(callback: (docs: Array<CMOBaseDocument>) => void) {
        let updateSearcher = new SolrSearcher();

        if (this.count() > 0) {

            updateSearcher.search([
                [ "q", "id:(" + this._store.join(" ") + ")" ],
                [ "start", "0" ],
                [ "rows", "99999" ] ], (result) => {
                callback(result.response.docs);
            });
        }
    }

    public getDocumentsGrouped(groupBy: string, callback: (docs: any, sort:string) => void, sortBy:string= "displayTitle asc"): void {
        let updateSearcher = new SolrSearcher();
        if (this.count() > 0) {
            updateSearcher.search([
                [ "q", "id:(" + this._store.join(" ") + ")" ],
                [ "start", "0" ],
                [ "rows", "99999" ],
                [ "sort", sortBy],
                [ "group", "true" ],
                [ "group.limit", "9999" ],
                [ "group.field", groupBy ] ], (result) => {
                let groups = result.grouped[ groupBy ].groups;
                let groupMap = {};
                for (let groupIndex in groups) {
                    if (groups.hasOwnProperty(groupIndex)) {
                        let group = groups[ groupIndex ];
                        groupMap[ group.groupValue ] = group.doclist.docs;
                    }
                }

                callback(groupMap, sortBy);
            });
        }
    }

    private save() {
        let data = JSON.stringify(this._store);

        if ("localStorage" in window) {
            window.localStorage.setItem(BasketStore.BASKET_STORE_KEY, data);

        }
    }

    private load() {
        if ("localStorage" in window) {
            let item = window.localStorage.getItem(BasketStore.BASKET_STORE_KEY);
            if (item != null) {
                this._store = JSON.parse(item);
            }
        }
    }

    public count(): number {
        return this._store.length;
    }

    private static load(): BasketStore {
        let basketStore = new BasketStore();
        basketStore.load();
        return basketStore;
    }

    public clear() {
        window.localStorage.setItem(BasketStore.BASKET_STORE_KEY, "[]");
        this.load();
    }
}
