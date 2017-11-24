import get = Reflect.get;

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

export class JSOptionalImpl<T> implements Optional<T> {


    public static of<T>(value: T): Optional<T> {
        if (value === null || value === undefined) {
            throw "value is undefined!";
        }

        return new JSOptionalImpl(value);
    }

    public static ofNullable<T>(value: T): Optional<T> {
        return new JSOptionalImpl(value);
    }

    public static EMPTY: Optional<any> = JSOptionalImpl.ofNullable(null);

    private constructor(private value: T) {
    }

    isPresent(): boolean {
        return this.value !== null && this.value !== undefined;
    }

    get(): T {
        if (!this.isPresent()) {
            throw "value is undefined!";
        }
        return this.value;
    }

    ifPresent(consumer: (value: T) => void): void {
        if (this.isPresent()) {
            consumer(this.get());
        }
    }

    filter(predicate: (value: T) => boolean): Optional<T> {
        if (this.isPresent()) {
            let val = this.get();
            if (predicate(val)) {
                return this;
            } else {
                return JSOptionalImpl.EMPTY;
            }
        } else {
            return this;
        }
    }

    orElse(other: T): T {
        if (this.isPresent()) {
            return this.get();
        }
        return other;
    }

    orElseGet(supplier: () => T) {
        if (this.isPresent()) {
            return this.get();
        }

        return supplier();
    }

    orElseThrow(exceptionSupplier: () => any) {
        if (this.isPresent()) {
            return this.get();
        }

        throw exceptionSupplier();
    }

    map<RESULT_TYPE>(mapper: (input: T) => RESULT_TYPE): Optional<RESULT_TYPE> {
        if (this.isPresent()) {
            return JSOptionalImpl.ofNullable(mapper(this.get()));
        } else {
            return JSOptionalImpl.EMPTY;
        }

    }

    or(...providers: Array<() => Optional<T>| Optional<T>>): Optional<T> {
        if (this.isPresent()) {
            return this;
        } else {
            for (let provider of providers) {
                let other = provider instanceof Function ? provider(): provider;
                if (other.isPresent()) {
                    return other;
                }
            }
        }

        return JSOptionalImpl.EMPTY;
    }

    and<Y, Z>(other: Optional<Y>, combinator: (T, Y) => Z) {
        if (this.isPresent() && other.isPresent()) {
            return JSOptionalImpl.ofNullable(combinator(this.get(), other.get()));
        }
        return JSOptionalImpl.EMPTY;
    }
}

export interface Optional<T> {
    isPresent(): boolean;

    get(): T;

    ifPresent(consumer: (value: T) => void): void;

    isPresent(): boolean;

    filter(predicate: (value: T) => boolean): Optional<T>;

    orElse(other: T): T;

    orElseGet(supplier: () => T);

    orElseThrow(exceptionSupplier: () => any);

    map<RESULT_TYPE>(mapper: (input: T) => RESULT_TYPE): Optional<RESULT_TYPE>;

    or(...provider: any[]): Optional<T>;

    and<Y, Z>(other: Optional<Y>, combinator: (x1: T, x2: Y) => Z): Optional<Z>;


}

