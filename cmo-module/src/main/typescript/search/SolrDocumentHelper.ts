import {CMOBaseDocument} from "../other/Solr";
import {JSOptionalImpl, Optional, Utils} from "../other/Utils";

export class SolrDocumentHelper {
    constructor(private doc: CMOBaseDocument) {

    }

    public getID(): string {
        return this.doc[ "id" ];
    }

    public getSingleValue<X>(fieldName: string): Optional<X> {
        let value = this.doc[ fieldName ];
        let unwrap = (val) => (Array.isArray(val)) ? unwrap(val[ 0 ]) : val;
        return JSOptionalImpl.ofNullable(value).map(unwrap).map(value => Utils.encodeHtmlEntities(value));
    }

    public getSingleValues<X>(...fieldNames: string[]): Array<X> {
        let arr = [];
        fieldNames.forEach((fieldName) => {
            if (fieldName in this.doc && this.doc[ fieldName ]) {
                let value = this.doc[ fieldName ];
                arr.push(value);
            }
        });
        return arr;
    }

    public getMultiValue<X>(...fieldNames: string[]): Optional<X[]> {
        let arr = [];
        fieldNames.forEach((fieldName) => {
            let value = this.doc[ fieldName ];
            if (!(Array.isArray(value))) {
                return;
            } else {
                arr = arr.concat(value);
            }
        });

        if (arr.length == 0) {
            return JSOptionalImpl.EMPTY;
        }

        return JSOptionalImpl.ofNullable(arr).map(value => value.map(value => Utils.encodeHtmlEntities(value)));
    }

}



