import {CMOBaseDocument} from "../other/Solr";
import {BasketStore} from "./BasketStore";
import {I18N} from "../other/I18N";

export class BasketUtil {

    private static basket: BasketStore = BasketStore.getInstance();

    public static activateLinks(html: HTMLElement) {
        let basketElements = Array.prototype.slice.call(html.querySelectorAll("[data-basket]"));


        basketElements.forEach((basketElement: HTMLElement) => {
            let inactive = basketElement.getAttribute("data-basket-activated") !== "true";
            if (inactive) {
                let id: string = basketElement.getAttribute("data-basket");

                let changed = () => {
                    let contains = BasketUtil.basket.contains(id);

                    if (contains) {
                        basketElement.setAttribute("data-i18n", "cmo.basket.remove");
                    } else{
                        basketElement.setAttribute("data-i18n", "cmo.basket.add");
                    }

                    I18N.translateElements(basketElement.parentElement);
                };

                basketElement.addEventListener("click", () => {
                    let contains = BasketUtil.basket.contains(id);

                    if(contains){
                        BasketUtil.basket.remove(id);
                    } else {
                        BasketUtil.basket.add(id);
                    }

                    changed();
                });

                changed();
            }
        })
    }

}
