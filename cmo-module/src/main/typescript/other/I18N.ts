import {Utils} from "./Utils";

export class I18N {
    private static DEFAULT_FETCH_LEVEL = 1;

    private static keyObj = {};

    private static fetchKeyHandlerList = {};

    private static currentLanguage: string = null;

    static translatePromise(key: string): Promise<string> {
        return new Promise((resolve, reject) => {
            I18N.translate(key, translation => {
                resolve(translation);
            });
        });
    }

    static translate(key: string, callback: (translation: string) => void) {
        let baseUrl: string = Utils.getBaseURL();
        let resourceUrl = baseUrl + "rsc/locale/translate/" + this.getCurrentLanguage() + "/";

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
                        let jsonData = JSON.parse(xhttp.response);
                        for (let key in jsonData) {
                            I18N.keyObj[ key ] = jsonData[ key ];
                        }

                        for (let index in I18N.fetchKeyHandlerList[ fetchKey ]) {
                            I18N.fetchKeyHandlerList[ fetchKey ][ index ]()
                        }
                        delete I18N.fetchKeyHandlerList[ fetchKey ];
                    }
                };
                xhttp.open('GET', resourceUrl + fetchKey, true);
                xhttp.send();
            }
        }
    }

    static translateElements(element: HTMLElement) {
        Array.prototype.slice.call(element.querySelectorAll("[data-i18n]")).forEach(childElement => {
            let child = <HTMLElement>childElement;
            let attr = child.getAttribute("data-i18n");
            I18N.translate(attr, translation => {
                child.innerHTML = translation
            });
        })
    }

    static getCurrentLanguage(): string {
        return window[ "mcrLanguage" ];
    }
}

