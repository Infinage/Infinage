api.Hints.setCharacters('abcdefghijklmnopqrstuvwxyz');

settings.hintAlign = 'left';
settings.omnibarPosition = 'bottom';
settings.focusAfterClosed = 'last';
settings.modeAfterYank = 'Normal';
settings.showTabIndices = true;

// Hints mode to open in new tab
api.map('F', 'C');

// Open clipboard URL in new tab
api.map('P', 'cc');

// Switch tab
api.map('gt', 'T');

// Open a URL in current tab
api.map('e', 'go');

// Edit current URL, and open in same tab
api.map('O', ';U');

// Edit current URL, and open in new tab
api.map('T', ';u');

// History Back / Forward
api.map('J', 'D');
api.map('K', 'S');

// Tab Delete/Undo
api.map('D', 'x');

// Scroll Page Down/Up
api.map('<Ctrl-d>', 'd')
api.map('<Ctrl-u>', 'u')

// Command mode scroll options
api.cmap('<Ctrl-k>', '<Tab>');
api.cmap('<Ctrl-j>', '<Shift-Tab>');

// Unmap existing combinations
api.unmap('S');
api.unmap('D');

/* set theme gruvbox */
settings.theme = `
.sk_theme {
    font-family: Input Sans Condensed, Charcoal, sans-serif;
    font-size: 10pt;
    background: #282828;
    color: #ebdbb2;
}
.sk_theme tbody {
    color: #b8bb26;
}
.sk_theme input {
    color: #d9dce0;
}
.sk_theme .url {
    color: #98971a;
}
.sk_theme .annotation {
    color: #b16286;
}
.sk_theme .omnibar_highlight {
    color: #ebdbb2;
}
.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
    background: #282828;
}
.sk_theme #sk_omnibarSearchResult ul li.focused {
    background: #d3869b;
}
#sk_status, #sk_find {
    font-size: 20pt;
}`;
