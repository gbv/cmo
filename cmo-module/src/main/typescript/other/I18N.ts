export module I18N {
    export class I18N {
        private static DEFAULT_FETCH_LEVEL = 1;

        private static keyObj = {};

        private static fetchKeyHandlerList = {};

        static translate(key: string, callback: (translation: string) => void) {
            let baseUrl: string = window[ "mcrBaseURL" ];
            let resourceUrl = baseUrl + "rsc/locale/translate/";

            if (key in I18N.keyObj) {
                callback(I18N.keyObj[ key ]);
            } else {
                let fetchKey = key;
                if (key.indexOf(".") != -1) {
                    fetchKey = key.split('.', I18N.DEFAULT_FETCH_LEVEL).join(".") + "*";
                }

                let wrappedCallback = () => key in I18N.keyObj ? callback(I18N.keyObj[ key ]) : callback("???" + key + "???");

                if (fetchKey in I18N.fetchKeyHandlerList) {
                    I18N.fetchKeyHandlerList[ fetchKey ].push(wrappedCallback);
                } else {
                    I18N.fetchKeyHandlerList[ fetchKey ] = [ wrappedCallback ];

                    let xhttp = new XMLHttpRequest();
                    xhttp.onreadystatechange = () => {
                        if (xhttp.readyState === XMLHttpRequest.DONE && xhttp.status == 200) {
                            console.log(xhttp.response);
                            let jsonData = JSON.parse(xhttp.response);
                            for (let key in jsonData) {
                                I18N.keyObj[ key ] = jsonData[ key ];
                            }

                            for (let index in I18N.fetchKeyHandlerList[ fetchKey ]) {
                                I18N.fetchKeyHandlerList[ fetchKey ][ index ]()
                            }
                        }
                    };
                    xhttp.open('GET', resourceUrl + fetchKey, true);
                    xhttp.send();
                }
            }
        }
    }
}
