/*
 * Renders the MEI music editions of an object page with the Verovio App (see layout/viewer.xsl).
 *
 * Every MEI tab pane contains a <div class="cmo-mei" data-mei-src="..."> placeholder. When the
 * tab is shown for the first time, the Verovio App is loaded (an ES module served locally from
 * verovio-app/), the raw MEI file is fetched and handed to the app. The app is created lazily
 * because it measures its container, which has no size while the tab is hidden.
 *
 * The app runs in read only mode (no editor, no file menu, no GitHub). It is the App class of
 * the Verovio Editor with these CMO specific changes:
 *  - the Verovio toolkit is served locally, nothing is loaded from verovio.org
 *  - nothing is written to the localStorage (options and recently opened files)
 *  - the MIDI playback is removed, it would need several external libraries and sound fonts
 *  - a file that cannot be rendered (e.g. invalid MEI) shows a CMO error message instead of an
 *    empty or forever loading viewer
 */
const appBase = new URL('../verovio-app/', import.meta.url);
const toolkitUrl = new URL('verovio/verovio-toolkit-wasm.js', appBase).href;

let appClassPromise = null;

const apps = [];

function loadAppClass() {
    if (appClassPromise === null) {
        appClassPromise = import(new URL('dist/app.js', appBase).href).then(module => {
            return class CmoVerovioApp extends module.App {
                constructor(div, options, onRendered) {
                    super(div, options);
                    this.cmoOnRendered = onRendered;
                }

                // do not store the options and the loaded file in the localStorage
                onBeforeUnload(e) {
                }

                // a hidden app (inactive tab) has no size, it is resized again when its tab is shown
                onResize(e) {
                    if (this.div.offsetParent === null) {
                        return;
                    }
                    super.onResize(e);
                }

                // no MIDI playback, see above
                createToolbar() {
                    super.createToolbar();
                    this.midiToolbarObj.midiControls.remove();
                }

                async playMEI() {
                }

                // called by the views after the data was loaded; reports the first page count once
                setPageCount(pageCount) {
                    super.setPageCount(pageCount);
                    if (this.cmoOnRendered) {
                        const callback = this.cmoOnRendered;
                        this.cmoOnRendered = null;
                        callback(pageCount);
                    }
                }
            };
        });
    }
    return appClassPromise;
}

/*
 * MEI files exported by Sibelius and the CMO transformation are UTF-16 encoded, so the file is
 * decoded by its byte order mark (or the byte pattern of '<') instead of relying on the
 * charset sent by the server.
 */
function decode(buffer) {
    const bytes = new Uint8Array(buffer);
    let encoding = 'utf-8';
    if (bytes.length >= 2) {
        if (bytes[0] === 0xFE && bytes[1] === 0xFF) {
            encoding = 'utf-16be';
        } else if (bytes[0] === 0xFF && bytes[1] === 0xFE) {
            encoding = 'utf-16le';
        } else if (bytes[0] === 0x00 && bytes[1] === 0x3C) {
            encoding = 'utf-16be';
        } else if (bytes[0] === 0x3C && bytes[1] === 0x00) {
            encoding = 'utf-16le';
        }
    }
    return new TextDecoder(encoding).decode(bytes);
}

function fileName(src) {
    const path = new URL(src, window.location.href).pathname;
    return decodeURIComponent(path.substring(path.lastIndexOf('/') + 1));
}

function showError(el, appDiv, detail) {
    if (appDiv) {
        appDiv.remove();
    }
    const loading = el.querySelector('.cmo-mei-loading');
    if (loading) {
        loading.remove();
    }
    const alert = document.createElement('div');
    alert.className = 'alert alert-warning cmo-mei-error';
    alert.setAttribute('role', 'alert');
    alert.textContent = el.getAttribute('data-mei-error');
    if (detail) {
        console.warn('MEI music edition could not be rendered: ' + detail);
    }
    el.appendChild(alert);
}

async function initMei(el) {
    if (el.getAttribute('data-loaded')) {
        return;
    }
    el.setAttribute('data-loaded', '1');
    const src = el.getAttribute('data-mei-src');
    let appDiv = null;
    try {
        const [AppClass, response] = await Promise.all([loadAppClass(), fetch(src, { credentials: 'same-origin' })]);
        if (!response.ok) {
            throw new Error('HTTP ' + response.status + ' for ' + src);
        }
        const mei = decode(await response.arrayBuffer());

        // from now on the app shows its own loading indicator
        const loading = el.querySelector('.cmo-mei-loading');
        if (loading) {
            loading.remove();
        }
        appDiv = document.createElement('div');
        appDiv.className = 'cmo-mei-app';
        el.appendChild(appDiv);

        const app = new AppClass(appDiv, {
            verovioUrl: toolkitUrl,
            enableEditor: false,
            enableValidation: false,
            enableDocument: true,
            enableResponsive: true,
            defaultView: 'responsive',
            // index in the zoom levels of the app (35%); with the default of 75% the page is only as
            // high as the viewer and the title of a Sibelius export leaves no room for a system
            responsiveZoom: 3
        }, pageCount => {
            // no page (or no answer at all after a toolkit exception) means the file could not be rendered
            if (!pageCount) {
                showError(el, appDiv, 'Verovio rendered no page for ' + src);
            }
        });
        apps.push(app);
        app.loadData(mei, fileName(src));
    } catch (e) {
        showError(el, appDiv, String(e));
    }
}

function resizeApps() {
    apps.forEach(app => app.onResize());
}

function initVisible(root) {
    $(root).find('.cmo-mei[data-mei-src]').each(function () {
        initMei(this);
    });
}

$(function () {
    initVisible('#cmo-viewer .tab-pane.active');
    $('#cmo-viewer a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
        const pane = $($(e.target).attr('href'));
        initVisible(pane);
        resizeApps();
    });
    // every app replaces window.onresize, so all apps are resized here
    window.addEventListener('resize', resizeApps);
});
