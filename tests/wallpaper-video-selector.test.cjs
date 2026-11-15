const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const service = fs.readFileSync(path.join(__dirname, '../home/.config/quickshell/end4-pC/services/Wallpapers.qml'), 'utf8');
const extensions = service.match(/property list<string> extensions:\s*\[([^\]]+)\]/)?.[1].match(/"([a-z0-9]+)"/g)?.map(value => value.slice(1, -1));

test('local selector offers videos accepted by switchwall', () => {
    assert.ok(extensions, 'wallpaper file filters must be readable');
    for (const extension of ['mp4', 'webm', 'mkv', 'avi', 'mov']) {
        assert.ok(extensions.includes(extension), `local selector excludes .${extension} videos`);
    }
});
