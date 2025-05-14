import {CMOBaseDocument, Response, SolrSearcher} from "../other/Solr";

export class BasketStore {

    private static BASKET_STORE_KEY = "BasketStore";
    public static BASKET_LIMIT = 3000;

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
        let left = BasketStore.BASKET_LIMIT - this.count();
        docs.slice(0, left)
            .filter(doc=> !this.contains(doc))
            .forEach(docID => {
            this._store.push(docID);
        });
        this.save();
        this._listener.forEach(listener => listener());
    }

    public addAll(docs: string[]) {
        let left = BasketStore.BASKET_LIMIT - this.count();
        docs.slice(0, left)
            .filter(doc=> !this.contains(doc))
            .forEach(docID => {
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


    public removeAll() {
        this._store.slice().forEach(e => this.remove(e));
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
        } else {
            callback([]);
        }
    }

    public getDocumentsGrouped(groupBy: string, callback: (docs: any, sort:string) => void, sortBy:string= "displayTitle asc"): void {
        let updateSearcher = new SolrSearcher();
        if (this.count() > 0) {
            // build slice ranges to avoid too many documents in one request
            let sliceRanges: { start: number, rows: number }[] = [];

            const sliceSize = 100;
            for (let i = 0; i < this._store.length; i += sliceSize) {
                let start = i;
                let rows = Math.min(sliceSize, this._store.length - i);
                sliceRanges.push({ start, rows });
            }

            console.log(["Slice ranges", sliceRanges]);


            // make requests for each slice
            let requests: Promise<CMOBaseDocument[]>[] = sliceRanges.map(slice => {
                return new Promise<CMOBaseDocument[]>((resolve) => {
                    updateSearcher.search([
                        [ "q", "id:(" + this._store.slice(slice.start, slice.start + slice.rows).join(" ") + ")" ],
                        [ "start", "0" ],
                        [ "rows", sliceSize.toString()],
                        [ "sort", sortBy]
                    ], (result) => {
                        resolve(result.response.docs);
                    });
                });
            });

            // wait for all requests to complete
            Promise.all(requests).then((results)=> {
                console.log("Results", results);
                const groupMap = {};
                for (const result of results) {
                    for (let doc of result) {
                        let groupValue = doc[ groupBy ];
                        if (groupMap[ groupValue ] == null) {
                            groupMap[ groupValue ] = [];
                        }
                        groupMap[ groupValue ].push(doc);
                    }
                }

                callback(groupMap, sortBy);
            });
        } else {
            callback({}, sortBy);
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
