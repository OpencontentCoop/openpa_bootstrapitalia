#!/usr/bin/env node
/**
 * Test standalone (nessun framework) per la funzione OpenPAFlyImg.rewrite(url, alias),
 * duplicata identica in 8 file JS del progetto. Verifica:
 *  - il caso base (URL assoluto grezzo -> URL proxato flyimg)
 *  - idempotenza (un URL già proxato non va riavvolto una seconda volta)
 *  - passthrough di URL relativi/same-origin (es. /image/view/<id>/small)
 *  - passthrough quando flyimg è disabilitato o l'URL è vuoto
 * su TUTTE le copie note dell'helper, per intercettare una copia dimenticata
 * in un futuro fix (rischio concreto: due bug precedenti sono stati corretti
 * in due giri perché alcune copie erano state inizialmente saltate).
 *
 * Esecuzione: node tests/test_openpa_flyimg_rewrite.js
 */

const fs = require('fs');
const path = require('path');
const vm = require('vm');
const assert = require('assert');
const { URL } = require('url');

const REPO_ROOT = path.resolve(__dirname, '..');

const FILES = [
    'design/bootstrapitalia/javascript/jquery.opendatabrowse.js',
    'design/bootstrapitalia2/javascript/jquery.opendatabrowse.js',
    'design/bootstrapitalia2110/javascript/jquery.opendatabrowse.js',
    'design/bootstrapitalia/javascript/jquery.opendataform.js',
    'design/bootstrapitalia/javascript/ezoe/popup_utils.js',
    'design/backend/javascript/ezoe/popup_utils.js',
    'design/bootstrapitalia/javascript/jquery.relationsbrowse.js',
    'design/bootstrapitalia2110/javascript/jquery.relationsbrowse.js',
];

const START_MARKER = 'var OpenPAFlyImg = (function ($) {';
const END_MARKER = '})(jQuery);';

function extractHelperSource(fileRelPath) {
    const fullPath = path.join(REPO_ROOT, fileRelPath);
    const src = fs.readFileSync(fullPath, 'utf8');
    const startIdx = src.indexOf(START_MARKER);
    if (startIdx === -1) {
        throw new Error(`Marker di inizio helper non trovato in ${fileRelPath}`);
    }
    const endIdx = src.indexOf(END_MARKER, startIdx);
    if (endIdx === -1) {
        throw new Error(`Marker di fine helper non trovato in ${fileRelPath}`);
    }
    return src.slice(startIdx, endIdx + END_MARKER.length);
}

function fakeDocument() {
    return {
        createElement(tag) {
            if (tag !== 'a') {
                throw new Error(`document.createElement('${tag}') non supportato nello shim di test`);
            }
            let parsed = null;
            return {
                set href(value) {
                    parsed = new URL(value);
                },
                get host() {
                    return parsed.host;
                },
                get protocol() {
                    return parsed.protocol;
                },
            };
        },
    };
}

function fakeJQuery(ajaxResponse) {
    function jq() {}
    jq.ajax = function (opts) {
        return {
            done(callback) {
                callback(ajaxResponse);
                return this;
            },
        };
    };
    return jq;
}

function loadOpenPAFlyImg(fileRelPath, ajaxResponse) {
    const code = extractHelperSource(fileRelPath);
    const sandbox = {
        jQuery: fakeJQuery(ajaxResponse),
        document: fakeDocument(),
    };
    vm.createContext(sandbox);
    vm.runInContext(code, sandbox, { filename: fileRelPath });
    if (!sandbox.OpenPAFlyImg || typeof sandbox.OpenPAFlyImg.rewrite !== 'function') {
        throw new Error(`OpenPAFlyImg.rewrite non definito dopo l'eval di ${fileRelPath}`);
    }
    return sandbox.OpenPAFlyImg;
}

const ENABLED_CONFIG_RESPONSE = {
    content: {
        enabled: true,
        baseUrl: 'https://static-opencity.localtest.me/upload',
        backendBaseUrl: 'minio:9000',
        backendBaseScheme: 'http',
        defaultFilter: 'o_auto',
        filters: {
            reference: { w: 2500, h: 2500 },
            large: { w: 800, h: 800 },
            imagelargeoverlay: { w: 800, h: 800 },
            medium: { w: 400, h: 400 },
            small: { w: 200, h: 200 },
            mini: { w: 180, h: 180 },
            rss: { w: 100, h: 100 },
        },
    },
};

const DISABLED_CONFIG_RESPONSE = { content: { enabled: false } };

let failures = 0;
let checks = 0;

function check(description, fn) {
    checks++;
    try {
        fn();
        process.stdout.write(`  ok - ${description}\n`);
    } catch (err) {
        failures++;
        process.stdout.write(`  FAIL - ${description}\n`);
        process.stdout.write(`    ${err.message}\n`);
    }
}

for (const file of FILES) {
    process.stdout.write(`\n${file}\n`);

    check('URL assoluto grezzo -> URL flyimg proxato (caso base)', () => {
        const helper = loadOpenPAFlyImg(file, ENABLED_CONFIG_RESPONSE);
        const raw = 'https://opencity.localtest.me/opencity-bucket/var/opencity/storage/images/media/images/foo.png/1-1-ita-IT/foo.png_reference.png';
        const result = helper.rewrite(raw, 'small');
        const expectedSource = 'http://minio:9000/opencity-bucket/var/opencity/storage/images/media/images/foo.png/1-1-ita-IT/foo.png_reference.png';
        const expected = 'https://static-opencity.localtest.me/upload/rf_1,o_auto,w_200,h_200/' + encodeURIComponent(expectedSource);
        assert.strictEqual(result, expected);
    });

    check('idempotenza: un URL già proxato non viene riavvolto (bug del doppio-proxy)', () => {
        const helper = loadOpenPAFlyImg(file, ENABLED_CONFIG_RESPONSE);
        const raw = 'https://opencity.localtest.me/opencity-bucket/var/opencity/storage/images/media/images/foo.png/1-1-ita-IT/foo.png_reference.png';
        const firstPass = helper.rewrite(raw, 'small');
        const secondPass = helper.rewrite(firstPass, 'small');
        assert.strictEqual(secondPass, firstPass, 'la seconda chiamata a rewrite() non deve modificare un URL già proxato');
    });

    check('URL relativo/same-origin passa invariato (bug /image/view/<id>/small)', () => {
        const helper = loadOpenPAFlyImg(file, ENABLED_CONFIG_RESPONSE);
        const relative = '/image/view/59/small';
        const result = helper.rewrite(relative, 'small');
        assert.strictEqual(result, relative);
    });

    check('URL falsy (stringa vuota) passa invariato', () => {
        const helper = loadOpenPAFlyImg(file, ENABLED_CONFIG_RESPONSE);
        assert.strictEqual(helper.rewrite('', 'small'), '');
    });

    check('flyimg disabilitato -> URL assoluto passa invariato', () => {
        const helper = loadOpenPAFlyImg(file, DISABLED_CONFIG_RESPONSE);
        const raw = 'https://opencity.localtest.me/opencity-bucket/var/opencity/storage/images/media/images/foo.png/1-1-ita-IT/foo.png_reference.png';
        assert.strictEqual(helper.rewrite(raw, 'small'), raw);
    });
}

process.stdout.write(`\n${checks - failures}/${checks} check superati su ${FILES.length} file\n`);

if (failures > 0) {
    process.exitCode = 1;
}
