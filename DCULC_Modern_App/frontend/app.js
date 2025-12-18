const API_BASE = 'http://127.0.0.1:5000/api';

const els = {
    statusDot: document.getElementById('status-dot'),
    statusText: document.getElementById('status-text'),
    btnConnect: document.getElementById('btn-connect'),
    btnDisconnect: document.getElementById('btn-disconnect'),
    deviceMsg: document.getElementById('device-msg'),

    cardTypeSelect: document.getElementById('card-type'),
    detectMsg: document.getElementById('detect-msg'),
    btnSetType: document.getElementById('btn-set-type'),
    btnAutoDetect: document.getElementById('btn-auto-detect'),

    inputOffset: document.getElementById('input-offset'),
    inputLength: document.getElementById('input-length'),
    btnRead: document.getElementById('btn-read'),
    btnWrite: document.getElementById('btn-write'),

    // Password UI
    passwordGroup: document.getElementById('password-group'),
    inputPassword: document.getElementById('input-password'),
    btnVerify: document.getElementById('btn-verify'),
    verifyMsg: document.getElementById('verify-msg'),

    // Password Change UI
    passwordChangeGroup: document.getElementById('password-change-group'),
    inputNewPassword: document.getElementById('input-new-password'),
    btnChangePassword: document.getElementById('btn-change-password'),
    changeMsg: document.getElementById('change-msg'),

    hexContainer: document.getElementById('hex-container')
};

let isConnected = false;
let originalData = []; // Store original bytes for comparison
let currentOffset = 0; // Store where we read from
let isVerified = false; // For protected cards

// Event Listeners
els.btnConnect.addEventListener('click', connectDevice);
els.btnDisconnect.addEventListener('click', disconnectDevice);
els.btnSetType.addEventListener('click', () => setCardType(els.cardTypeSelect.value));
els.btnAutoDetect.addEventListener('click', detectCard);
els.btnRead.addEventListener('click', readData);
els.btnWrite.addEventListener('click', writeData);
els.btnVerify.addEventListener('click', verifyPassword);
els.btnChangePassword.addEventListener('click', changePassword);
document.getElementById('btn-exit').addEventListener('click', exitApp);

// Save/Load Events
document.getElementById('btn-save').addEventListener('click', saveDump);
document.getElementById('btn-load').addEventListener('click', () => document.getElementById('file-input').click());
document.getElementById('file-input').addEventListener('change', loadDump);


// Functions
function saveDump() {
    // Collect current data (including edits)
    const cells = document.querySelectorAll('.hex-cell');
    if (cells.length === 0) {
        alert("暂无数据可保存");
        return;
    }

    // Prompt for filename
    let filename = prompt("请输入保存文件名 (.dump):", "card_data.dump");
    if (!filename) return;
    if (!filename.endsWith(".dump")) filename += ".dump";

    // Create byte array
    const bytes = [];
    cells.forEach(cell => {
        bytes.push(parseInt(cell.innerText, 16));
    });

    const u8 = new Uint8Array(bytes);
    const blob = new Blob([u8], { type: "application/octet-stream" });
    const url = URL.createObjectURL(blob);

    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    a.click();
    URL.revokeObjectURL(url);
}

function loadDump(e) {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = function (evt) {
        const buffer = evt.target.result;
        const u8 = new Uint8Array(buffer);
        const data = Array.from(u8);

        // Render loaded data
        if (originalData.length === 0) {
            renderHex(data, currentOffset);
        } else {
            renderHex(data, currentOffset);
        }

        // Trigger dirty check for all cells to highlight diffs
        document.querySelectorAll('.hex-cell').forEach(cell => checkDirty(cell));

        alert(`已载入文件: ${file.name} (${data.length} 字节)`);

        // Reset input so same file can be selected again
        e.target.value = '';
    };
    reader.readAsArrayBuffer(file);
}

async function connectDevice() {
    updateStatus('connecting');
    try {
        const res = await fetch(`${API_BASE}/connect`, { method: 'POST' });
        const data = await res.json();

        if (data.status === 'connected') {
            isConnected = true;
            updateStatus('connected');
            els.deviceMsg.textContent = "设备已就绪";
            detectCard();
        } else {
            throw new Error(data.message);
        }
    } catch (err) {
        isConnected = false;
        updateStatus('error');
        els.deviceMsg.textContent = "连接失败: " + err.message;
    }
}

async function disconnectDevice() {
    try {
        await fetch(`${API_BASE}/disconnect`, { method: 'POST' });
    } catch (e) { console.error(e); }

    isConnected = false;
    updateStatus('disconnected');
    els.deviceMsg.textContent = "设备断开";
    isVerified = false;
    els.passwordGroup.style.display = 'none';
    resetUI();
}

function checkProtection(type) {
    const t = type.toUpperCase();
    if (t.includes('4442') || t.includes('4428')) {
        els.passwordGroup.style.display = 'block';
        // Reset verify state
        isVerified = false;
        els.btnWrite.disabled = true; // Lock write
        els.btnWrite.title = "请先验证密码";
        els.verifyMsg.textContent = "";
        els.verifyMsg.className = "";

        // Hide password change section until verified
        els.passwordChangeGroup.style.display = 'none';

        if (t.includes('4442')) {
            els.inputPassword.value = "FFFFFF";
            els.inputPassword.maxLength = 6;
            els.inputPassword.placeholder = "FFFFFF (6位)";
            els.inputNewPassword.maxLength = 6;
            els.inputNewPassword.placeholder = "新密码 (6位HEX)";
        }
        if (t.includes('4428')) {
            els.inputPassword.value = "FFFF";
            els.inputPassword.maxLength = 4;
            els.inputPassword.placeholder = "FFFF (4位)";
            els.inputNewPassword.maxLength = 4;
            els.inputNewPassword.placeholder = "新密码 (4位HEX)";
        }

        // Fetch and display password counter
        fetchPasswordCounter();
    } else {
        els.passwordGroup.style.display = 'none';
        isVerified = true; // Not required
        els.btnWrite.title = "";
    }
}

// Hex input validation for password fields
function setupHexInput(input) {
    input.addEventListener('input', (e) => {
        // Only allow hex characters
        e.target.value = e.target.value.replace(/[^0-9A-Fa-f]/g, '').toUpperCase();
    });
}
setupHexInput(els.inputPassword);
setupHexInput(els.inputNewPassword);

async function fetchPasswordCounter() {
    try {
        const res = await fetch(`${API_BASE}/password_counter`);
        const data = await res.json();
        if (data.status === 'ok') {
            els.verifyMsg.textContent = `密码计数器: ${data.counter} (剩余尝试次数)`;
            els.verifyMsg.style.color = data.counter >= 2 ? "var(--text-secondary)" : "var(--error-color)";
        }
    } catch (e) {
        // Ignore errors
    }
}

async function verifyPassword() {
    const pwd = els.inputPassword.value.trim();
    if (!pwd) return;

    els.verifyMsg.textContent = "验证中...";
    els.btnVerify.disabled = true;

    try {
        const res = await fetch(`${API_BASE}/verify_password`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ password: pwd })
        });
        const data = await res.json();

        if (data.status === 'ok') {
            isVerified = true;
            let msg = "密码验证成功！";
            if (data.counter !== null) {
                msg += ` 计数器: ${data.counter}`;
            }
            els.verifyMsg.textContent = msg;
            els.verifyMsg.style.color = "var(--success-color)";
            els.btnWrite.disabled = false;
            els.btnWrite.title = "";

            // Show password change section
            els.passwordChangeGroup.style.display = 'block';
            els.changeMsg.textContent = "";
        } else {
            isVerified = false;
            let msg = data.message;
            if (data.counter !== null && data.counter !== undefined) {
                msg += ` (剩余尝试: ${data.counter})`;
            }
            els.verifyMsg.textContent = msg;
            els.verifyMsg.style.color = "var(--error-color)";
            els.btnWrite.disabled = true;

            // Hide password change section
            els.passwordChangeGroup.style.display = 'none';
        }
    } catch (e) {
        els.verifyMsg.textContent = "请求失败";
    } finally {
        els.btnVerify.disabled = false;
    }
}

async function changePassword() {
    if (!isVerified) {
        els.changeMsg.textContent = "请先验证当前密码！";
        els.changeMsg.style.color = "var(--error-color)";
        return;
    }

    const newPwd = els.inputNewPassword.value.trim().toUpperCase();
    if (!newPwd) {
        els.changeMsg.textContent = "请输入新密码";
        els.changeMsg.style.color = "var(--error-color)";
        return;
    }

    // Validate hex format
    if (!/^[0-9A-F]+$/.test(newPwd)) {
        els.changeMsg.textContent = "密码必须是十六进制格式";
        els.changeMsg.style.color = "var(--error-color)";
        return;
    }

    els.changeMsg.textContent = "修改中...";
    els.btnChangePassword.disabled = true;

    try {
        const res = await fetch(`${API_BASE}/change_password`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ new_password: newPwd })
        });
        const data = await res.json();

        if (data.status === 'ok') {
            els.changeMsg.textContent = "密码修改成功！";
            els.changeMsg.style.color = "var(--success-color)";

            // Update the password input field with new password
            els.inputPassword.value = newPwd;
        } else {
            els.changeMsg.textContent = data.message || "修改失败";
            els.changeMsg.style.color = "var(--error-color)";
        }
    } catch (e) {
        els.changeMsg.textContent = "请求失败";
        els.changeMsg.style.color = "var(--error-color)";
    } finally {
        els.btnChangePassword.disabled = false;
    }
}

async function exitApp() {
    // Show non-blocking modal
    document.getElementById('modal-overlay').style.display = 'flex';
}

function closeModal() {
    document.getElementById('modal-overlay').style.display = 'none';
}

async function confirmExit() {
    closeModal();
    try {
        await fetch(`${API_BASE}/shutdown`, { method: 'POST' });
        document.body.innerHTML = `
            <div style="display:flex; justify-content:center; align-items:center; height:100vh; background:#1e1e2e; color:#fff; flex-direction:column;">
                <h1>程序已关闭</h1>
                <p>您可以直接关闭此窗口。</p>
            </div>
        `;
        window.close();
    } catch (e) {
        console.error(e);
        alert("关闭失败");
    }
}

// Make functions global so HTML onclick works
window.closeModal = closeModal;
window.confirmExit = confirmExit;

async function detectCard() {
    els.detectMsg.textContent = "正在识别卡片...";
    els.detectMsg.className = "";
    els.cardTypeSelect.disabled = true;

    try {
        const res = await fetch(`${API_BASE}/detect`, { method: 'POST' });
        const data = await res.json();

        if (data.success) {
            els.detectMsg.textContent = `自动识别成功: ${data.type}`;
            els.detectMsg.className = "success";

            const opts = Array.from(els.cardTypeSelect.options);
            // Relaxed matching: check if data.type contains option value OR option value contains data.type
            const match = opts.find(opt => {
                if (opt.disabled) return false;
                const val = opt.value.toUpperCase();
                const type = data.type.toUpperCase();
                return type.includes(val) || val.includes(type);
            });

            if (match) {
                els.cardTypeSelect.value = match.value;
                // Explicitly valid
            } else {
                els.detectMsg.textContent += " (列表中未找到匹配类型)";
                // Reset select to default if no match found
                els.cardTypeSelect.value = "";
            }

            // Auto-set length
            const type = data.type.toUpperCase();
            if (type.includes("4442")) els.inputLength.value = 256;
            else if (type.includes("4428")) els.inputLength.value = 1024;
            else if (type.includes("24C01")) els.inputLength.value = 128;
            else if (type.includes("24C02")) els.inputLength.value = 256;
            else if (type.includes("24C04")) els.inputLength.value = 512;
            else if (type.includes("24C08")) els.inputLength.value = 1024;
            else if (type.includes("24C16")) els.inputLength.value = 2048;
            else if (type.includes("24C64")) els.inputLength.value = 8192;
            else els.inputLength.value = 256; // Default

            checkProtection(type);

            els.cardTypeSelect.disabled = false;
            enableOperations();

        } else {
            els.detectMsg.textContent = "识别失败，请重新识别。";
            els.detectMsg.className = "fail";
            els.cardTypeSelect.disabled = false;
            els.cardTypeSelect.value = "";
            enableOperations();
        }
    } catch (err) {
        els.detectMsg.textContent = "检测出错: " + err.message;
        els.detectMsg.className = "fail";
        els.cardTypeSelect.disabled = false;
    }
}

async function setCardType(type) {
    if (!type) return;
    try {
        const res = await fetch(`${API_BASE}/set_type`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ type: type })
        });
        const data = await res.json();
        if (data.status === 'ok') {
            els.detectMsg.textContent = `已设置为: ${type}`;
            els.detectMsg.className = "success";

            // Auto-set length for manual selection too
            const upperType = type.toUpperCase();
            if (upperType.includes("4442")) els.inputLength.value = 256;
            else if (upperType.includes("4428")) els.inputLength.value = 1024;
            else if (upperType.includes("24C01")) els.inputLength.value = 128;
            else if (upperType.includes("24C02")) els.inputLength.value = 256;
            else if (upperType.includes("24C04")) els.inputLength.value = 512;
            else if (upperType.includes("24C08")) els.inputLength.value = 1024;
            else if (upperType.includes("24C16")) els.inputLength.value = 2048;
            else if (upperType.includes("24C64")) els.inputLength.value = 8192;

            checkProtection(upperType);
        }
    } catch (err) {
        console.error(err);
    }
}

async function readData() {
    const offset = parseInt(els.inputOffset.value);
    const length = parseInt(els.inputLength.value);

    els.hexContainer.innerHTML = '<div class="loading"></div>Reading...';
    // Don't disable write if verified (or handled by checkProtection logic)
    // els.btnWrite.disabled = true; 

    try {
        const res = await fetch(`${API_BASE}/read`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ offset, length })
        });
        const data = await res.json();

        if (data.status === 'ok') {
            originalData = data.data; // Store reference
            currentOffset = offset;
            renderHex(originalData, offset);

            // Only enable write if verified or not protected
            if (isVerified) els.btnWrite.disabled = false;

            els.deviceMsg.textContent = "读取成功";
        } else {
            els.hexContainer.innerHTML = `<span style="color:var(--error-color)">读取失败: ${data.message}</span>`;
        }
    } catch (err) {
        els.hexContainer.innerHTML = `<span style="color:var(--error-color)">请求错误: ${err.message}</span>`;
    }
}

async function writeData() {
    // Check protection first
    if (!isVerified) {
        alert("受保护的卡片必须先验证密码！");
        return;
    }

    // 1. Collect Data
    const cells = document.querySelectorAll('.hex-cell');
    const newData = [];
    let hasChanges = false;

    try {
        cells.forEach((cell, idx) => {
            const val = parseInt(cell.innerText, 16);
            if (isNaN(val) || val < 0 || val > 255) throw new Error(`无效数据在第 ${idx} 字节`);
            newData.push(val);
            if (val !== originalData[idx]) hasChanges = true;
        });
    } catch (e) {
        alert(e.message);
        return;
    }

    if (!hasChanges) {
        alert("数据未修改，无需写入。");
        return;
    }

    if (!confirm("确定要写入修改后的数据吗？")) return;

    updateStatus('connecting'); // Show working state
    els.deviceMsg.textContent = "正在写入...";

    try {
        // 2. Write Data
        const resWrite = await fetch(`${API_BASE}/write`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ offset: currentOffset, data: newData })
        });

        // Robust JSON parsing
        const text = await resWrite.text();
        let dataWrite;
        try {
            dataWrite = JSON.parse(text);
        } catch (e) {
            // If response is not JSON (e.g. HTML error page)
            console.error("Non-JSON Response:", text);
            throw new Error(`服务器返回了非 JSON 数据 (可能是错误页面): \n${text.substring(0, 200)}...`);
        }

        if (dataWrite.status !== 'ok') {
            throw new Error("写入失败: " + dataWrite.message);
        }

        els.deviceMsg.textContent = "写入成功，正在校验...";

        // 3. Verify (Read Back)
        const resRead = await fetch(`${API_BASE}/read`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ offset: currentOffset, length: newData.length })
        });
        const dataRead = await resRead.json();

        if (dataRead.status === 'ok') {
            // Compare
            const readBackData = dataRead.data;
            let mismatch = false;
            for (let i = 0; i < newData.length; i++) {
                if (readBackData[i] !== newData[i]) mismatch = true;
            }

            if (mismatch) {
                throw new Error("校验失败！写入数据与回读数据不一致！");
            } else {
                // Success!
                originalData = readBackData; // Update ref
                renderHex(originalData, currentOffset); // Re-render clean
                els.deviceMsg.textContent = "写入并校验成功！";
                els.deviceMsg.style.color = "var(--success-color)";
                // Flash animation
                document.querySelectorAll('.hex-cell').forEach(el => el.classList.add('flash-success'));
            }
        } else {
            throw new Error("校验读取失败");
        }

    } catch (err) {
        els.deviceMsg.textContent = err.message;
        els.deviceMsg.style.color = "var(--error-color)";
        alert(err.message);
    } finally {
        updateStatus('connected'); // Restore status
    }
}

function renderHex(bytes, startOffset) {
    let html = '';
    // Group by 16 bytes
    for (let i = 0; i < bytes.length; i += 16) {
        const chunk = bytes.slice(i, i + 16);
        const addr = (startOffset + i).toString(16).padStart(4, '0').toUpperCase();

        let hexPart = '';
        let asciiPart = '';

        chunk.forEach((b, idx) => {
            const globalIdx = i + idx;
            const hex = b.toString(16).padStart(2, '0').toUpperCase();
            // Don't use standard contenteditable, we handle it manually via keydown to prevent insert
            hexPart += `<span class="hex-cell" contenteditable="true" data-idx="${globalIdx}">${hex}</span> `;
            asciiPart += (b >= 32 && b <= 126) ? String.fromCharCode(b) : '.';
        });

        html += `
        <div class="hex-row">
            <div class="hex-addr">0x${addr}</div>
            <div class="hex-bytes">${hexPart}</div>
            <div class="hex-ascii">${asciiPart}</div>
        </div>`;
    }
    els.hexContainer.innerHTML = html;

    // Add input listeners
    document.querySelectorAll('.hex-cell').forEach(cell => {
        // Blur listener for formatting
        cell.addEventListener('blur', (e) => formatHexCell(e, cell));

        // Keydown listener for Navigation & Overwrite logic
        cell.addEventListener('keydown', (e) => {
            // Navigation
            if (e.key === 'Enter') {
                e.preventDefault();
                cell.blur(); // Or move next?
                return;
            }
            // Allow Navigation Keys
            if (['Backspace', 'Delete', 'Tab', 'ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown'].includes(e.key)) {
                return; // Default behavior
            }

            // Allow shortcuts
            if (e.ctrlKey || e.metaKey) return;

            // Hex Input Logic (Strict Overwrite)
            if (/^[0-9a-fA-F]$/.test(e.key)) {
                e.preventDefault(); // Stop Browser Insert

                const sel = window.getSelection();
                if (!sel.rangeCount) return;
                const range = sel.getRangeAt(0);

                let currentText = cell.innerText;
                if (currentText.length > 2) currentText = currentText.slice(0, 2); // Safety fix

                const cursorStart = range.startOffset;
                const cursorEnd = range.endOffset;

                // Prepare new char
                const newChar = e.key.toUpperCase();
                let chars = currentText.split('');

                // Overwrite Logic
                if (cursorEnd > cursorStart) {
                    // Selection: Replace first char of selection, remove others?
                    // Simplified: Just put char at start index.
                    chars[cursorStart] = newChar;
                } else {
                    // No selection: Overwrite char at cursor
                    if (cursorStart < 2) {
                        chars[cursorStart] = newChar;
                    } else {
                        // At end (index 2)? Replace index 1 (last char)? 
                        // Or Just ignore?
                        // User wants "jump to next". 
                        // If full and cursor at end, maybe we should have jumped already.
                        // Lets update last char if at end.
                        chars[1] = newChar;
                    }
                }

                // Re-assemble
                const newText = chars.join('').slice(0, 2); // Ensure max 2
                cell.innerText = newText;

                // Validation Style
                checkDirty(cell);

                // Auto-Advance Logic
                // If we executed an action that resulted in a "Full" cell or we were at index 1...
                // Move cursor logic:
                // If we edited index 0 -> Move cursor to index 1.
                // If we edited index 1 -> Move focus to NEXT CELL.

                let nextCursorPos = cursorStart + 1;

                if (nextCursorPos >= 2) {
                    // Jump to next cell
                    // Find next cell
                    let nextCell = cell.nextElementSibling; // Might be text node (space)?
                    // .hex-cell elements are separated by spaces in my HTML. 
                    // nextElementSibling should get the next span.

                    if (nextCell && nextCell.classList.contains('hex-cell')) {
                        nextCell.focus();
                        // Place cursor at 0
                        const r = document.createRange();
                        const s = window.getSelection();
                        r.setStart(nextCell.childNodes[0], 0);
                        r.collapse(true);
                        s.removeAllRanges();
                        s.addRange(r);
                    } else {
                        // Maybe end of row? Need to find next row?
                        // This is complex. DOM structure is hex-bytes -> spans.
                        // If no next sibling, we are at end of 16-byte chunk.
                        // Check hex-row parent -> next hex-row -> hex-bytes -> first hex-cell
                        const currentRow = cell.closest('.hex-row');
                        const nextRow = currentRow.nextElementSibling;
                        if (nextRow && nextRow.classList.contains('hex-row')) {
                            const nextStart = nextRow.querySelector('.hex-cell');
                            if (nextStart) {
                                nextStart.focus();
                                const r = document.createRange();
                                const s = window.getSelection();
                                r.setStart(nextStart.childNodes[0], 0);
                                r.collapse(true);
                                s.removeAllRanges();
                                s.addRange(r);
                            }
                        }
                    }
                } else {
                    // Stay in cell, move cursor to 1
                    try {
                        const r = document.createRange();
                        const s = window.getSelection();
                        r.setStart(cell.childNodes[0], 1);
                        r.collapse(true);
                        s.removeAllRanges();
                        s.addRange(r);
                    } catch (e) { }
                }

            } else {
                e.preventDefault(); // Block invalid keys
            }
        });
    });
}

function checkDirty(cell) {
    const idx = parseInt(cell.dataset.idx);
    const text = cell.innerText;
    try {
        const val = parseInt(text, 16);
        if (!isNaN(val) && val !== originalData[idx]) {
            cell.classList.add('modified');
        } else {
            cell.classList.remove('modified');
        }
    } catch (error) { }
}

function formatHexCell(e, cell) {
    let text = cell.innerText.trim().toUpperCase();

    // Auto-pad
    if (text.length === 0) text = '00';
    if (text.length === 1) text = '0' + text;

    // Restore if invalid (safeguard)
    if (!/^[0-9A-F]{2}$/.test(text)) {
        text = originalData[parseInt(cell.dataset.idx)].toString(16).padStart(2, '0').toUpperCase();
    }

    cell.innerText = text;
    checkDirty(cell);
}

function updateStatus(state) {
    els.statusDot.className = 'status-dot'; // reset
    els.deviceMsg.style.color = ""; // reset msg color
    if (state === 'connected') {
        els.statusDot.classList.add('connected');
        els.statusText.textContent = "已连接";
        els.btnConnect.style.display = 'none';
        els.btnDisconnect.style.display = 'block';
    } else if (state === 'error') {
        els.statusDot.classList.add('error');
        els.statusText.textContent = "错误";
    } else if (state === 'connecting') {
        els.statusText.textContent = "连接中...";
    } else {
        els.statusText.textContent = "未连接";
        els.btnConnect.style.display = 'block';
        els.btnDisconnect.style.display = 'none';
    }
}

function enableOperations() {
    els.btnSetType.disabled = false;
    els.btnAutoDetect.disabled = false;
    els.btnRead.disabled = false;
}

function resetUI() {
    els.cardTypeSelect.disabled = true;
    els.cardTypeSelect.value = "";
    els.detectMsg.textContent = "";
    els.btnSetType.disabled = true;
    els.btnAutoDetect.disabled = true;
    els.btnRead.disabled = true;
    els.btnWrite.disabled = true;
    els.hexContainer.innerHTML = '<div style="text-align: center; color: var(--text-secondary); margin-top: 20%;">暂无数据。请连接设备并点击“读取”。</div>';
}

// Heartbeat for Auto-Shutdown
// Send ping every 3 seconds
setInterval(() => {
    fetch(`${API_BASE}/heartbeat`, { method: 'POST' }).catch(e => {
        // If ping fails (e.g. server down), we don't really care, just ignore
    });
}, 3000);
