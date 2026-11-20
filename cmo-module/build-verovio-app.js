/*
 * Builds the locally served Verovio App for the MEI music editions (see xsl/layout/viewer.xsl and
 * js/cmo-mei-viewer.js) into target/classes/META-INF/resources/verovio-app.
 *
 * Nothing of it is kept in the sources. The files come from two packages in package.json:
 *  - verovio-editor: rism-digital/verovio-editor (AGPL-3.0), fetched from GitHub by its commit id.
 *    The "Verovio App" of https://www.verovio.org/app.html is the App class of the editor.
 *  - verovio: the Verovio toolkit (LGPL-3.0) from npm.
 *
 * Only the files needed at runtime are copied: dist/ (without source maps), the css with its loading
 * images, the svg filter, the icons without the *_b variants and the license.
 *
 * The editor loads its assets and the toolkit from fixed urls (editor.verovio.org, www.verovio.org).
 * Because everything has to be served by CMO, three patches are applied while copying. Each patch
 * replaces a text that has to occur exactly once, otherwise the build fails. After an update of
 * verovio-editor the patches have to be checked.
 *
 * Update: change the commit id of verovio-editor and the version of verovio in package.json, then
 * run yarn install.
 */
const fs = require('fs');
const path = require('path');

const editorDir = path.resolve(__dirname, 'node_modules/verovio-editor');
const toolkitFile = path.resolve(__dirname, 'node_modules/verovio/dist/verovio-toolkit-wasm.js');
const targetDir = path.resolve(__dirname, 'target/classes/META-INF/resources/verovio-app');

const patches = {
    'dist/app.js': [
        {
            // serve css, icons, svg filter and workers from the directory app.js was loaded from
            search: 'const host = (window.location.hostname == "localhost") ? `http://${window.location.host}` : "https://editor.verovio.org";',
            replace: '// CMO patch: assets are served by CMO, see build-verovio-app.js\n'
                + 'const host = new URL(\'..\', import.meta.url).href.replace(/\\/$/, \'\');'
        },
        {
            // allow to give the url of the locally served toolkit as option
            search: 'const verovioUrl = `https://www.verovio.org/javascript/${this.options.verovioVersion}/verovio-toolkit-wasm.js`;',
            replace: '// CMO patch: the toolkit is served by CMO, see build-verovio-app.js\n'
                + '        const verovioUrl = this.options.verovioUrl || `https://www.verovio.org/javascript/${this.options.verovioVersion}/verovio-toolkit-wasm.js`;'
        }
    ],
    'dist/verovio/verovio-worker.js': [
        {
            // invalid MEI can make the toolkit throw a WebAssembly exception; without an answer the
            // app would wait forever, so the call is answered with result null
            search: 'result = fn.apply(verovioToolkit, args || []);',
            replace: '// CMO patch: answer a failed call, see build-verovio-app.js\n'
                + '        try {\n'
                + '            result = fn.apply(verovioToolkit, args || []);\n'
                + '        }\n'
                + '        catch (e) {\n'
                + '            console.error(\'Verovio toolkit failed in \' + method, e);\n'
                + '            result = null;\n'
                + '        }'
        }
    ]
};

function isRuntimeFile(relPath) {
    const parts = relPath.split('/');
    switch (parts[0]) {
        case 'dist':
            return relPath.endsWith('.js');
        case 'css':
            return ['verovio.css', 'loading.svg', 'loading_b.svg'].includes(parts[1]);
        case 'svg':
            return relPath === 'svg/filter.xml';
        case 'icons':
            return !(parts.length > 2 && parts[1].endsWith('_b'));
        case 'LICENSE':
            return parts.length === 1;
        default:
            return false;
    }
}

function listFiles(dir, prefix) {
    let files = [];
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
        const relPath = prefix ? prefix + '/' + entry.name : entry.name;
        if (entry.isDirectory()) {
            files = files.concat(listFiles(path.join(dir, entry.name), relPath));
        } else {
            files.push(relPath);
        }
    }
    return files;
}

function applyPatches(relPath, content) {
    for (const patch of patches[relPath]) {
        const first = content.indexOf(patch.search);
        if (first < 0 || content.indexOf(patch.search, first + 1) >= 0) {
            throw new Error('CMO patch does not apply to ' + relPath + ', expected exactly once: ' + patch.search);
        }
        content = content.substring(0, first) + patch.replace + content.substring(first + patch.search.length);
    }
    return content;
}

function copy(source, target, content) {
    fs.mkdirSync(path.dirname(target), { recursive: true });
    if (content === undefined) {
        fs.copyFileSync(source, target);
    } else {
        fs.writeFileSync(target, content, 'utf8');
    }
}

fs.rmSync(targetDir, { recursive: true, force: true });

const files = listFiles(editorDir, '').filter(isRuntimeFile);
for (const relPath of files) {
    const source = path.join(editorDir, relPath);
    const content = patches[relPath] ? applyPatches(relPath, fs.readFileSync(source, 'utf8')) : undefined;
    copy(source, path.join(targetDir, relPath), content);
}
for (const relPath of Object.keys(patches)) {
    if (!files.includes(relPath)) {
        throw new Error('CMO patch target missing in verovio-editor: ' + relPath);
    }
}
copy(toolkitFile, path.join(targetDir, 'verovio/verovio-toolkit-wasm.js'));

console.log('Verovio App: ' + (files.length + 1) + ' files copied to ' + targetDir);
