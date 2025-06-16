const KEYBOARD_ENTRIES = [
 /* 2 */ "Αα",
    /* 3 */ "Ββ",
    /* 4 */ "Γγ",
    /* 5 */ "Γ̇γ̇",
    /* 6 */ "ΓΓ γγ",
    /* 7 */ "ΓΚ γκ",
    /* 8 */ "ΓΙ̠ γι̠",
    /* 9 */ "Δδ",
    /* 10 */ "Δ̇δ̇",
    /* 11 */ "δζ",
    /* 12 */ "Εε",
    /* 13 */ "Ζζ",
    /* 14 */ "Ηη",
    /* 15 */ "Θθ",
    /* 16 */ "Ιι",
    /* 17 */ "Ϊϊ",
    /* 18 */ "ɩ̮1", // <-- looks broken
    /* 19 */ "IO ιο",
    /* 20 */ "I̠ȮY ι̠ȯυ",
    /* 21 */ "Κκ",
    /* 22 */ "Κ̇κ̇",
]


export function attachKeyboard(input: HTMLInputElement|HTMLTextAreaElement) {
    const keyboardPanel = document.createElement('div');
    keyboardPanel.style.position = 'absolute';
    keyboardPanel.style.background = '#fff';
    keyboardPanel.style.zIndex = '1000';
    keyboardPanel.classList.add("card");

    const keyboardBody = document.createElement('div');
    keyboardBody.classList.add("card-body");
    keyboardPanel.appendChild(keyboardBody);


    KEYBOARD_ENTRIES.forEach(entry => {
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.classList.add("btn", "btn-secondary", "btn-sm", "m-1");
        btn.textContent = entry;
        btn.onclick = () => {
            const start = input.selectionStart ? input.selectionStart: 0;
            const end = input.selectionEnd ? input.selectionEnd: 0;
            const value = input.value;
            input.value = value.slice(0, start) + entry + value.slice(end);
            input.focus();
            input.selectionStart = input.selectionEnd = start + entry.length;
        };
        keyboardBody.appendChild(btn);
    });

    function updatePosition() {
        const rect = input.getBoundingClientRect();
        keyboardPanel.style.left = `${rect.left + window.scrollX}px`;
        keyboardPanel.style.top = `${rect.bottom + window.scrollY + 4}px`;
    }
    const rect = input.getBoundingClientRect();

    updatePosition();

    input.addEventListener('resize', updatePosition);

    document.body.appendChild(keyboardPanel);

    function removeKeyboard() {
        keyboardPanel.remove();
        input.removeEventListener('blur', removeKeyboard);
        input.removeEventListener('resize', updatePosition);
    }
    input.addEventListener('blur', removeKeyboard);

    keyboardPanel.addEventListener('mousedown', e => e.preventDefault());
}