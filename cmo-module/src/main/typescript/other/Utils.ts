export class Utils {
    constructor() {

    }

    static getBaseURL(): string {
        return window[ "mcrBaseURL" ];
    }

    static stripSurrounding(value: string, sign: string) {
        let stripped = value.indexOf(sign) == 0 ? value.substr(1) : value;
        stripped = stripped.lastIndexOf(sign) == stripped.length - 1 ? stripped.substr(0, stripped.length - 1) : stripped;
        return stripped;
    }

    static encodeHtmlEntities = function(str) {
        return str.replace(/[\u00A0-\u99999<>\&]/gim, function(i) {
            return '&#'+i.charCodeAt(0)+';';
        });
    };
}

export class CombinedCallback<T> {

    constructor(context: T, onAllComplete: (result: T) => void) {
        this.context = context;
        this._onAllComplete = onAllComplete;
    }

    private context: T;
    private _onAllComplete: (T) => void;
    private _count: number = 0;

    public getCallback(myCallback: (params: Array<any>, context: T) => void): any {
        this._count++;
        return (e: any) => {
            this._count--;
            myCallback(e, this.context);
            if (this._count == 0) {
                this._onAllComplete(this.context);
            }
        }
    }
}


export class UserInputParser {

    public static * parseUserInput(input: string) {
        let state = {
            quotePos : -1,
            spacePos : -1,
            lastCompleteFieldPos : 0
        };

        for (let i = 0; i < input.length; i++) {
            let currentChar = input[ i ];
            switch (currentChar) {
                case '"':
                    if (state.quotePos !== -1) {
                        let qp = state.quotePos;
                        state.quotePos = -1;
                        state.lastCompleteFieldPos = i + 1;
                        yield input.substring(qp, i + 1);
                    } else {
                        state.quotePos = i;
                    }
                    break;
                case ' ':
                    if (state.quotePos == -1) {
                        let lcp = state.lastCompleteFieldPos;
                        state.lastCompleteFieldPos = i + 1;
                        yield UserInputParser.escapeSpecialCharacters(input.substring(lcp, i));
                    }
                    break;
            }
        }
        if (state.lastCompleteFieldPos < input.length) {
            let lcp = state.lastCompleteFieldPos;
            state.lastCompleteFieldPos = input.length;
            yield UserInputParser.escapeSpecialCharacters(input.substring(lcp, input.length));
        }
    }
    static escapeSearchValue = /[\+\-\!\(\)\{\}\[\]\^\"\~\*\?\:\\\/\&\|]/g;
    static unescapeSearchValue = /[\\][\+\-\!\(\)\{\}\[\]\^\"\~\*\?\:\\\/\&\|]/g;

    public static escapeSpecialCharacters(str: string): string {
        return str.replace(UserInputParser.escapeSearchValue, (char) => {
            return "\\" + char;
        });
    }

    public static unescapeSpecialCharacters(str: string): string{
        return str.replace(UserInputParser.unescapeSearchValue, (char) => {
            return char.substring(1);
        });
    }

}

