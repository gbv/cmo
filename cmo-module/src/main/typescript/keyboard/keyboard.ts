import {I18N} from "../other/I18N";

// Interface for keyboard character variants
interface CharacterVariant {
    uppercase: string[];
    lowercase: string[];
}

// Interface for keyboard entries
interface KeyboardEntry {
    character: CharacterVariant;
    display?: string; // Optional display text
}

// Interface for keyboard tabs
interface KeyboardTab {
    name: string;
    entries: KeyboardEntry[];
}

// Updated keyboard data structure based on your provided list
const KEYBOARD_ENTRIES: KeyboardTab[] = [
    {
        name: "greek",
        entries: [
            {character: {uppercase: ["Α̠"], lowercase: ["α̠"]}},
            {character: {uppercase: ["Γ̇"], lowercase: ["γ̇"]}},
            {character: {uppercase: ["Δ̇"], lowercase: ["δ̇"]}},
            {character: {uppercase: ["Ε̠"], lowercase: ["ε̠"]}},
            {character: {uppercase: ["Ι̠"], lowercase: ["ι̠"]}},
            {character: {uppercase: ["Ϊ"], lowercase: ["ϊ"]}},
            {character: {uppercase: ["Ι̮"], lowercase: ["ɩ̮"]}},
            {character: {uppercase: ["Ο̠"], lowercase: ["ο̠"]}},
            {character: {uppercase: ["Ȯ"], lowercase: ["ȯ"]}},
            {character: {uppercase: ["Υ̠"], lowercase: ["υ̠"]}},
            {character: {uppercase: ["Κ̇"], lowercase: ["κ̇"]}},
            {character: {uppercase: ["Ȯ"], lowercase: ["ȯ"]}},
            {character: {uppercase: ["Ö"], lowercase: ["ö"]}},
            {character: {uppercase: ["ᴕ"], lowercase: ["ᴕ"]}},
            {character: {uppercase: ["ᴕ̇"], lowercase: ["ᴕ̇"]}},
            {character: {uppercase: ["ᴕ́"], lowercase: ["ᴕ́"]}},
            {character: {uppercase: ["Π͘"], lowercase: ["π͘"]}},
            {character: {uppercase: ["Σ͘"], lowercase: ["σ͘", "ς͘"]}},
            {character: {uppercase: ["Σ̈"], lowercase: ["σ̈"]}},
            {character: {uppercase: ["Σ˙"], lowercase: ["σ˙"]}},
            {character: {uppercase: ["Ṫ"], lowercase: ["τ͘"]}},
            {character: {uppercase: ["T˙"], lowercase: ["τ˙"]}},
            {character: {uppercase: ["Ẋ"], lowercase: ["ẋ"]}}
        ]
    },
    {
        name: "latin",
        entries: [
            {character: {uppercase: ["Ā"], lowercase: ["ā"]}},
            {character: {uppercase: ["Ā̲"], lowercase: ["ā̲"]}},
            {character: {uppercase: ["Ĉ"], lowercase: ["ĉ"]}},
            {character: {uppercase: ["Ċ"], lowercase: ["ċ"]}},
            {character: {uppercase: ["Ç"], lowercase: ["ç"]}},
            {character: {uppercase: ["Ḉ"], lowercase: ["ḉ"]}},
            {character: {uppercase: ["Ḅ"], lowercase: ["ḅ"]}},
            {character: {uppercase: ["Ḇ"], lowercase: ["ḇ"]}},
            {character: {uppercase: ["Ḃ"], lowercase: ["ḃ"]}},
            {character: {uppercase: ["Ḋ"], lowercase: ["ḋ"]}},
            {character: {uppercase: ["Ḏ"], lowercase: ["ḏ"]}},
            {character: {uppercase: ["Đ"], lowercase: ["đ"]}},
            {character: {uppercase: ["Ḍ"], lowercase: ["ḍ"]}},
            {character: {uppercase: ["E̲"], lowercase: ["e̲"]}},
            {character: {uppercase: ["Ė"], lowercase: ["ė"]}},
            {character: {uppercase: ["F̲"], lowercase: ["f̲"]}},
            {character: {uppercase: ["Ḡ"], lowercase: ["ḡ"]}},
            {character: {uppercase: ["G̲"], lowercase: ["g̲"]}},
            {character: {uppercase: ["Ğ"], lowercase: ["ğ"]}},
            {character: {uppercase: ["Ġ"], lowercase: ["ġ"]}},
            {character: {uppercase: ["Ĝ"], lowercase: ["ĝ"]}},
            {character: {uppercase: ["Ǵ"], lowercase: ["ǵ"]}},
            {character: {uppercase: ["Ģ"], lowercase: ["ģ"]}},
            {character: {uppercase: ["H̲"], lowercase: ["h̲"]}},
            {character: {uppercase: ["Ḣ"], lowercase: ["ḣ"]}},
            {character: {uppercase: ["İ"], lowercase: ["i"]}},
            {character: {uppercase: ["I"], lowercase: ["ı"]}},
            {character: {uppercase: ["Ī"], lowercase: ["ī"]}},
            {character: {uppercase: ["Ї"], lowercase: ["ї"]}},
            {character: {uppercase: ["Ḳ"], lowercase: ["ḳ"]}},
            {character: {uppercase: ["Ḵ"], lowercase: ["ḵ"]}},
            {character: {uppercase: ["Ō"], lowercase: ["ō"]}},
            {character: {uppercase: ["Œ"], lowercase: ["œ"]}},
            {character: {uppercase: ["Ö̲"], lowercase: ["ö̲"]}},
            {character: {uppercase: ["Ȭ"], lowercase: ["ȭ"]}},
            {character: {uppercase: ["Ȍ"], lowercase: ["ȍ"]}},
            {character: {uppercase: ["Ő"], lowercase: ["ő"]}},
            {character: {uppercase: ["Ȫ"], lowercase: ["ȫ"]}},
            {character: {uppercase: ["P̲"], lowercase: ["p̲"]}},
            {character: {uppercase: ["S̲"], lowercase: ["s̲"]}},
            {character: {uppercase: ["Ş"], lowercase: ["ş"]}},
            {character: {uppercase: ["Š"], lowercase: ["š"]}},
            {character: {uppercase: ["Ŝ"], lowercase: ["ŝ"]}},
            {character: {uppercase: ["Ś"], lowercase: ["ś"]}},
            {character: {uppercase: ["T̲"], lowercase: ["t̲"]}},
            {character: {uppercase: ["Ự"], lowercase: ["ự"]}},
            {character: {uppercase: ["Ư"], lowercase: ["ư"]}},
            {character: {uppercase: ["Ŭ"], lowercase: ["ŭ"]}},
            {character: {uppercase: ["Ŭ̲"], lowercase: ["ŭ̲"]}},
            {character: {uppercase: ["Ụ"], lowercase: ["ụ"]}},
            {character: {uppercase: ["Ű"], lowercase: ["ű"]}},
            {character: {uppercase: ["Ũ"], lowercase: ["ũ"]}},
            {character: {uppercase: ["Ǖ"], lowercase: ["ǖ"]}},
            {character: {uppercase: ["Ū"], lowercase: ["ū"]}},
            {character: {uppercase: ["Ů"], lowercase: ["ů"]}},
            {character: {uppercase: ["Ų"], lowercase: ["ų"]}},
            {character: {uppercase: ["Ȗ"], lowercase: ["ȗ"]}},
            {character: {uppercase: ["V̲"], lowercase: ["v̲"]}},
            {character: {uppercase: ["Ŷ"], lowercase: ["ŷ"]}},
            {character: {uppercase: ["Ȳ"], lowercase: ["ȳ"]}},
            {character: {uppercase: ["Ẏ"], lowercase: ["ẏ"]}},
            {character: {uppercase: ["Ÿ"], lowercase: ["ÿ"]}},
            {character: {uppercase: ["Ý"], lowercase: ["ý"]}},
            {character: {uppercase: ["Ż"], lowercase: ["ż"]}}
        ]
    }
];

const MODIFIER_KEYBOARD = [
    '\u0341', // ◌́ Combining Acute Tone Mark https://www.compart.com/de/unicode/U+0341
    '\u0340', // ̀ COMBINING GRAVE TONE MARK https://unicode-explorer.com/c/0340
    '\u0342', // ͂ COMBINING GREEK PERISPOMENI https://unicode-explorer.com/c/0342
    '\u0308', // ̈ COMBINING DIAERESIS https://unicode-explorer.com/c/0308
    '\u0343', // ◌̓ Combining Greek Koronis https://www.compart.com/de/unicode/U+0343
    '\u0351', // ͑ COMBINING LEFT HALF RING ABOVE https://unicode-explorer.com/c/0351
    '\u0345', // ͅ COMBINING GREEK YPOGEGRAMMENI https://unicode-explorer.com/c/345
];

export function enableKeyboard(input: HTMLInputElement | HTMLTextAreaElement, toggle: HTMLButtonElement) {
    const keyboardPanel = document.createElement('div');

    let removeKeyboard = null as () => void || null;

    function toggleKeyboard() {
        if (keyboardPanel.parentElement) {
            toggle.classList.remove('active');
            if (removeKeyboard) {
                removeKeyboard();
            }
        } else {
            toggle.classList.add('active');
            removeKeyboard = attachKeyboard(keyboardPanel, input);
        }
    }

    toggle.addEventListener('click', toggleKeyboard);
}

function attachKeyboard(keyboardPanel: HTMLDivElement, input: HTMLInputElement | HTMLTextAreaElement) {
    // Define constants for button dimensions and spacing
    const BUTTON_WIDTH = 3; // Base button width in em
    const BUTTON_HEIGHT = 2.5; // Base button height in em
    const GAP = 0.25; // Gap between buttons and containers in em


    keyboardPanel.style.position = 'absolute';
    keyboardPanel.style.background = '#fff';
    keyboardPanel.style.zIndex = '1000';
    keyboardPanel.classList.add("card", "shadow-sm", "on-screen-keyboard");

    // Create keyboard header for tabs
    const keyboardHeader = document.createElement('div');
    keyboardHeader.classList.add("card-header", "d-flex", "justify-content-between", "align-items-center");
    keyboardPanel.appendChild(keyboardHeader);

    // Create tab navigation
    const tabNav = document.createElement('ul');
    tabNav.classList.add("nav", "nav-tabs", "card-header-tabs");
    keyboardHeader.appendChild(tabNav);

    // Create case toggle button
    const caseToggleBtn = document.createElement('button');
    caseToggleBtn.type = 'button';
    caseToggleBtn.classList.add("btn", "btn-outline-secondary", "btn-sm", "ms-3");
    caseToggleBtn.textContent = 'Aa';
    caseToggleBtn.title = 'Toggle case';
    keyboardHeader.appendChild(caseToggleBtn);

    // Create keyboard body
    const keyboardBody = document.createElement('div');
    keyboardBody.classList.add("card-body");
    keyboardPanel.appendChild(keyboardBody);

    // Track current state
    let currentCase: 'uppercase' | 'lowercase' = 'lowercase';
    let currentTab = 0;

    // Function to toggle case
    function toggleCase() {
        currentCase = currentCase === 'uppercase' ? 'lowercase' : 'uppercase';
        renderCurrentTab();
    }

    // Add click handler to case toggle button
    caseToggleBtn.onclick = toggleCase;

    // a list of modifiers which will be applied to the next typed char
    const modifierList: Array<string> = [];
    const MODIFIER_TOGGLE_CLASS = "modifier-toggle";
    const KEYBOARD_CHAR_ATTR = "data-keyboard-char";

    // Create tabs
    KEYBOARD_ENTRIES.forEach((tab, index) => {
        const tabItem = document.createElement('li');
        tabItem.classList.add("nav-item");

        const tabLink = document.createElement('a');
        tabLink.classList.add("nav-link");
        if (index === currentTab) tabLink.classList.add("active");

        tabLink.href = "#";
        tabLink.textContent = tab.name;
        I18N.translate(`cmo.keyboard.tab.${tab.name}`,
            (translation) => tabLink.textContent = translation || tab.name);

        tabLink.onclick = (e) => {
            e.preventDefault();
            currentTab = index;
            // Update active tab
            Array.from(tabNav.querySelectorAll('.nav-link')).forEach(link => link.classList.remove('active'));
            tabLink.classList.add('active');
            renderCurrentTab();
        };

        tabItem.appendChild(tabLink);
        tabNav.appendChild(tabItem);
    });

    // Function to insert text at cursor position
    function insertTextAtCursor(text: string) {
        const start = input.selectionStart ? input.selectionStart : 0;
        const end = input.selectionEnd ? input.selectionEnd : 0;
        const value = input.value;

        let combinedText = text;
        if (modifierList.length > 0) {
            modifierList.forEach(modifier => {
                combinedText += modifier;
            })
            modifierList.length = 0;
            refreshModifierToggledState();
        }

        input.value = value.slice(0, start) + combinedText + value.slice(end);
        input.focus();
        input.selectionStart = input.selectionEnd = start + combinedText.length;
    }

    function addDiacriticsToText(event: KeyboardEvent) {
        if (modifierList.length > 0 && event.key.length === 1) {
            event.preventDefault();
            insertTextAtCursor(event.key);
        }
    }

    function createButton(text: string, onClick: () => void): HTMLButtonElement {
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.classList.add("on-screen-keyboard-btn", "btn", "btn-secondary", "btn-sm", "d-flex", "align-items-center", "justify-content-center");
        btn.textContent = text;
        btn.style.height = `${BUTTON_HEIGHT}em`;
        btn.onclick = onClick;
        return btn;
    }

    function refreshModifierToggledState() {
        Array.from(keyboardBody.querySelectorAll("." + MODIFIER_TOGGLE_CLASS)).forEach(btn => {
            const buttonChar = btn.getAttribute(KEYBOARD_CHAR_ATTR);
            const BUTTON_ACTIVE_CLASS = "active";
            if (btn.classList.contains(BUTTON_ACTIVE_CLASS)) {
                if (buttonChar && modifierList.indexOf(buttonChar) == -1) {
                    btn.classList.remove(BUTTON_ACTIVE_CLASS);
                }
            } else {
                if (buttonChar && modifierList.indexOf(buttonChar) > -1) {
                    btn.classList.add(BUTTON_ACTIVE_CLASS);
                }
            }
        });
    }

    /**
     * Renders the current tab using a stable grid layout.
     * This is the core of the corrected logic.
     */
    function renderCurrentTab() {
        keyboardBody.innerHTML = '';

        const currentTabData = KEYBOARD_ENTRIES[currentTab];

        const rowWrap = document.createElement('div');
        rowWrap.classList.add("row");
        keyboardBody.appendChild(rowWrap);

        const normalCol = document.createElement('div');
        normalCol.classList.add("col-9");
        rowWrap.appendChild(normalCol);

        const normalColContainer = document.createElement('div');
        normalColContainer.style.display = 'flex';
        normalColContainer.style.flexWrap = 'wrap';
        normalColContainer.style.gap = `${GAP}em`;
        normalCol.appendChild(normalColContainer);

        const diacriticsCol = document.createElement('div');
        diacriticsCol.classList.add("col-3");
        rowWrap.appendChild(diacriticsCol);

        const diacriticsColContainer = document.createElement('div');
        diacriticsColContainer.style.display = 'flex';
        diacriticsColContainer.style.flexWrap = 'wrap';
        diacriticsColContainer.style.gap = `${GAP}em`;
        diacriticsCol.appendChild(diacriticsColContainer);

        currentTabData.entries.forEach((entry) => {
            const maxVariants = Math.max(
                entry.character.uppercase.length,
                entry.character.lowercase.length,
                entry.display ? 1 : 0
            );
            if (maxVariants === 0) return;

            const entryContainer = document.createElement('div');
            entryContainer.style.display = 'flex'; // Use flex to arrange buttons inside
            entryContainer.style.gap = `${GAP}em`;

            const containerWidth = (maxVariants * BUTTON_WIDTH) + ((maxVariants - 1) * GAP);
            entryContainer.style.width = `${containerWidth}em`;

            const variants = entry.display ? [entry.display] : entry.character[currentCase];

            variants.forEach((char) => {
                const btn = createButton(char, () => insertTextAtCursor(char));
                btn.style.flexGrow = '1';
                btn.style.width = `${BUTTON_WIDTH}em`; // Set a base width for flex calculation
                entryContainer.appendChild(btn);
            });

            normalColContainer.appendChild(entryContainer);
        });

        MODIFIER_KEYBOARD.forEach((char) => {
            const entryContainer = document.createElement('div');
            entryContainer.style.display = 'flex'; // Use flex to arrange buttons inside
            entryContainer.style.gap = `${GAP}em`;
            entryContainer.style.width = `${BUTTON_WIDTH}em`;
            const btn = createButton(char, () => {
                modifierList.push(char);
                refreshModifierToggledState();
                input.focus();
            });
            btn.style.flexGrow = '1';
            btn.classList.add(MODIFIER_TOGGLE_CLASS);
            btn.setAttribute(KEYBOARD_CHAR_ATTR, char)
            entryContainer.appendChild(btn);
            diacriticsColContainer.appendChild(entryContainer);
        });

        refreshModifierToggledState();
    }


    // Initial render
    renderCurrentTab();

    document.body.appendChild(keyboardPanel);

    // Position keyboard relative to the input
    function updatePosition() {
        const rect = input.getBoundingClientRect();
        keyboardPanel.style.left = `${rect.left + window.scrollX}px`;
        keyboardPanel.style.top = `${rect.bottom + window.scrollY + 5}px`;
    }

    updatePosition();
    window.addEventListener('resize', updatePosition);
    window.addEventListener('scroll', updatePosition);
    input.addEventListener('keydown', addDiacriticsToText);

    return () => {
        window.removeEventListener('resize', updatePosition);
        window.removeEventListener('scroll', updatePosition);
        input.removeEventListener('keydown', addDiacriticsToText);
        keyboardPanel.innerHTML = '';
        keyboardPanel.remove();
    };
}