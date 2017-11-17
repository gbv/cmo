import {Utils} from "./Utils";

export class SolrSearcher {
    constructor() {

    }

    public search(params: Array<Array<string>>, callback: (result: SolrSearchResult) => void) {
        let baseUrl: string = Utils.getBaseURL();
        let xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = () => {
            if (xhttp.readyState === XMLHttpRequest.DONE && xhttp.status == 200) {
                let jsonData = JSON.parse(xhttp.response);
                callback(jsonData);
            }
        };

        let paramPart = params.map((kv) => {
            let [ key ] = kv;
            return kv.slice(1).map(v => `${key}=${encodeURIComponent(v)}`).join("&");
        }).join("&");

        xhttp.open('GET', baseUrl + "servlets/solr/select?" + paramPart + "&wt=json", true);
        xhttp.send();
    }
}


export interface SolrSearchResult {
    responseHeader: ResponseHeader;
    response: Response;
    grouped: any;
    facet_counts: FacetHeader;
}

export interface FacetHeader {
    /**
     * Contains the type as key and as value a array [name1,count1, name2,count2]
     */
    facet_fields: any;
}

export interface ResponseHeader {
    status: number;
    QTime: number;
    params: {};
}

export interface Response {
    rows?: number;
    numFound: number;
    start: number;
    docs: Array<CMOBaseDocument>;
}

export interface CMOBaseDocument {
    objectKind: "mycoreobject";
    id: string;
    returnId?: string;
    objectProject: string;
    objectType: string
    modified: string;
    created: string;
    parent?: string;
    derCount: number;
    hasFiles: boolean;
    identifier?: Array<string>;
    "composer.ref"?: Array<string>;
    lyricist: Array<string>;
    incip: Array<string>;
    category: Array<string>;
}
