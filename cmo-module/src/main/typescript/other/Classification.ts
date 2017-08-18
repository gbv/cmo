import {Utils} from "./utils";
import {I18N} from "./I18N";
export interface Classification {
    ID: string,
    label: Array<ClassificationLabel>,
    categories: Array<ClassificationCategory>
}

export interface ClassificationCategory {
    ID: string,
    labels: Array<ClassificationLabel>,
    categories: Array<ClassificationCategory>
}

export interface ClassificationLabel {
    lang: string,
    text: string,
    description: string
}

export class ClassificationResolver {

    private static cache = {};
    private static resolved = {};

    public static resolve(classID: string, onResolve: (clazz: Classification) => void) {
        if (classID in ClassificationResolver.cache) {
            onResolve(ClassificationResolver.cache[ classID ]);
            return;
        }

        if (classID in this.resolved) {
            ClassificationResolver.resolved[ classID ].push(onResolve);
        } else {
            ClassificationResolver.resolved[ classID ] = [];
            ClassificationResolver.resolved[ classID ].push(onResolve);
            let baseUrl: string = Utils.getBaseURL();
            let resourceUrl = `${baseUrl}api/v1/classifications/${classID}?format=json`;
            let xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = () => {
                if (xhttp.readyState === XMLHttpRequest.DONE && xhttp.status == 200) {
                    let jsonData = JSON.parse(xhttp.response);
                    ClassificationResolver.cache[ classID ] = jsonData;
                    ClassificationResolver.resolved[ classID ].forEach(resolve => resolve(jsonData));
                }
            };
            xhttp.open('GET', resourceUrl, true);
            xhttp.send();
        }

    };

    public static clearCache() {
        ClassificationResolver.cache = {};
        ClassificationResolver.resolved = {};
    }

    public static putLabels(container: HTMLElement) {
        Array.prototype.slice.call(container.querySelectorAll("[data-clazz]")).forEach(childElement => {
            let htmlElement = (<HTMLElement>childElement);
            let classAttr = htmlElement.getAttribute("data-clazz");

            if (classAttr != null) {
                ClassificationResolver.resolve(classAttr, (clazz) => {
                    let category = htmlElement.getAttribute("data-category");

                    let findCategory = (cat: ClassificationCategory, id: string) => {
                        if (cat.ID == id) {
                            return cat;
                        }

                        for (let catIndex in cat.categories) {
                            let childCat = cat.categories[ catIndex ];
                            let rightChildCategory = findCategory(childCat, id);
                            if (rightChildCategory != null) {
                                return rightChildCategory;
                            }
                        }

                        return null;
                    };
                    if (category != null) {
                        for (let catIndex in clazz.categories) {
                            let cat = findCategory(clazz.categories[ catIndex ], category);
                            if(cat!=null){
                                let rightCategoryLabel = cat.labels
                                    .filter(clazzLabel=>clazzLabel.lang.indexOf("x-") != 0)
                                    .filter(clazzLabel => clazzLabel.lang == I18N.getCurrentLanguage());
                                if (rightCategoryLabel.length > 0) {
                                    htmlElement.innerText = rightCategoryLabel[ 0 ].text;
                                } else {
                                    htmlElement.innerText = cat.labels[ 0 ].text;
                                }
                                break;
                            }
                        }
                    } else {
                        let labels = clazz.label.filter(clazzLabel=>clazzLabel.lang.indexOf("x-") != 0);
                        let rightLabel = labels
                            .filter(clazzLabel => clazzLabel.lang == I18N.getCurrentLanguage());
                        if (rightLabel.length > 0) {
                            htmlElement.innerText = rightLabel[ 0 ].text;
                        } else {
                            htmlElement.innerText = labels[ 0 ].text;
                        }
                    }
                });
            }
        });
    }
}


