
    export class Utils {
        constructor(){

        }

        static getBaseURL(): string {
            return window[ "mcrBaseURL" ];
        }
    }

    export class CombinedCallback<T> {

        constructor(context: T, onAllComplete:(result:T)=>void) {
            this.context = context;
            this._onAllComplete = onAllComplete;
        }

        private context:T;
        private _onAllComplete: (T) => void;
        private _count:number = 0;

        public getCallback(myCallback: (params: Array<any>, context: T) => void): any {
            this._count++;
            return (e: any) => {
                this._count--;
                myCallback(e, this.context);
                if(this._count == 0){
                    this._onAllComplete(this.context);
                }
            }
        }
    }


