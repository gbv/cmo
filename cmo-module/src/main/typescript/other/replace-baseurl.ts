import {Utils} from "./Utils";

/**
 * Placeholder used in static web content (MyCoReWebPage files) instead of a
 * hard-coded absolute base URL.
 */
const BASE_URL_PLACEHOLDER = "{$webApplicationBaseURL}";

/**
 * Resolves the {$webApplicationBaseURL} placeholder in all links below the
 * given root to the actual application base URL.
 */
export function replaceBaseUrlPlaceholder(root: ParentNode = document): void {
    const baseURL = Utils.getBaseURL() || "";
    Array.from(root.querySelectorAll("a[href]")).forEach((link: Element) => {
        const href = link.getAttribute("href");
        if (href !== null && href.indexOf(BASE_URL_PLACEHOLDER) !== -1) {
            link.setAttribute("href", href.split(BASE_URL_PLACEHOLDER).join(baseURL));
        }
    });
}
