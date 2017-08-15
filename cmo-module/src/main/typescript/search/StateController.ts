export class StateController {

    static setState(state: Array<Array<string>>) {
        let paramPart = state.map((kv) => {
            let [ key ] = kv;
            return kv.slice(1).map(v => `${key}=${v}`).join("&");
        }).join("&");

        //window.history.pushState({}, document.title, window.document.location.toString().split("#")[ 0 ] + "#" +
        // paramPart);
        //StateController.stateChanged(window.location.toString());

        StateController.selfChange = paramPart;
        window.location.hash = paramPart;

    }

    static stateHandlerList: Array<(handler: Array<Array<string>>, selfChange: boolean) => void> = [];
    static globHandlerRegistered = false;
    static selfChange = null;

    static onStateChange(changeHandler: (newState: Array<Array<string>>, selfChange: boolean) => void) {
        let onHashChange = function (newURL: string) {
            StateController.stateChanged(newURL);
        };

        if (StateController.globHandlerRegistered == false) {
            StateController.globHandlerRegistered = true;

            window.addEventListener('hashchange', (evt: HashChangeEvent) => {
                onHashChange(evt.newURL);

            });

        }

        StateController.stateHandlerList.push(changeHandler);
        if (typeof window.location.hash !== "undefined" && window.location.hash != null) {
            onHashChange(window.location.toString());
        }
    }


    static stateChanged(newURL:string){
        let arrParams: Array<Array<string>> = [];

        let [ , hash ] = newURL.split("#", 2);

        if (typeof hash !== "undefined") {
            hash = decodeURIComponent(hash);

            let params = hash.split("&");
            let groupObj = {};

            params.forEach(kv => {
                if (kv != null && kv.length > 0 && kv.indexOf("=") != -1) {
                    let [ key, value ] = kv.split("=");
                    if (!(key in groupObj)) {
                        groupObj[ key ] = [];
                    }
                    groupObj[ key ].push(value);
                }
            });

            for (let key in groupObj) {
                arrParams.push([ key ].concat(groupObj[ key ]));
            }


        }
        StateController.stateHandlerList.forEach(handler => handler(arrParams, StateController.selfChange == window.location.hash.substring(1)));
    }

}
