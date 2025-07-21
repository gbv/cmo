import {BasketStore} from "./BasketStore";
import {I18N} from "../other/I18N";

export class BasketUtil {

    private static basket: BasketStore = BasketStore.getInstance();

    public static activateLinks(html: HTMLElement) {
        let basketElements = Array.prototype.slice.call(html.querySelectorAll("[data-basket]"));


        basketElements.forEach((basketElement: HTMLElement) => {
            let inactive = basketElement.getAttribute("data-basket-activated") !== "true";
            if (inactive) {
                let ids: Array<string> = basketElement.getAttribute("data-basket")
                .split(",")
                .filter(s=> s.trim().length > 0);

                let changed = () => {
                    let containsAll = !ids.map(id => BasketUtil.basket.contains(id)).some(isInBasket => !isInBasket);

                    if (containsAll) {
                        basketElement.setAttribute("data-i18n", ids.length > 1 ? "cmo.basket.remove.multi" : "cmo.basket.remove");
                    } else{
                        basketElement.setAttribute("data-i18n", ids.length > 1 ? "cmo.basket.add.multi" : "cmo.basket.add");
                    }

                    I18N.translateElements(basketElement.parentElement);
                };

                basketElement.addEventListener("click", () => {
                    let containsAll = !ids.map(id => BasketUtil.basket.contains(id)).some(isInBasket => !isInBasket);

                    if (containsAll) {
                        BasketUtil.basket.remove.apply(BasketUtil.basket, ids);
                    } else {
                        BasketUtil.basket.add.apply(BasketUtil.basket, ids)
                    }

                    changed();
                });

                changed();
            }
        })
    }

}
