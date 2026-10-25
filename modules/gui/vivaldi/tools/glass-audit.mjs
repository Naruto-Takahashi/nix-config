#!/usr/bin/env node
// =========================================================================
// glass-audit: Vivaldi UI の「ガラス化漏れ」をCDPで検査する
// =========================================================================
// 自動非表示UI (.auto-hide-wrapper 配下) とポップアップのうち、不透明な
// 背景 (alpha >= 0.85) が残っている可視要素と、ガラスの上で読みにくい
// 文字色 (ダークテーマで暗い文字等) を列挙する。Vivaldi更新後に
// glass.css のセレクタがまだ効いているかの再監査に使う。
//
// 使い方:
//   1. Vivaldi をデバッグポート付きで起動し直す
//        Mac: osascript -e 'quit app "Vivaldi"'; open -a Vivaldi --args --remote-debugging-port=9222
//   2. node glass-audit.mjs [--panels]
//        自動非表示UIを一時的に強制表示して検査する (検査後に元に戻す)。
//        --panels を付けるとパネルを1つずつ切り替えて全パネルを検査する。
//   Node 22+ (グローバル WebSocket) が必要。
const PORT = process.env.CDP_PORT ?? 9222;
const withPanels = process.argv.includes('--panels');

const list = await (await fetch(`http://127.0.0.1:${PORT}/json/list`)).json();
const target = list.find((t) => t.url.endsWith('/window.html'));
if (!target) throw new Error('window.html が見つからない (Vivaldi をデバッグポート付きで起動したか確認)');

const ws = new WebSocket(target.webSocketDebuggerUrl);
await new Promise((r) => (ws.onopen = r));
let seq = 0;
const evaluate = (fn, ...args) =>
  new Promise((resolve) => {
    const id = ++seq;
    ws.addEventListener('message', function h(m) {
      const r = JSON.parse(m.data);
      if (r.id !== id) return;
      ws.removeEventListener('message', h);
      resolve(r.result?.result?.value);
    });
    ws.send(JSON.stringify({
      id, method: 'Runtime.evaluate',
      params: { expression: `(${fn})(...${JSON.stringify(args)})`, returnByValue: true, awaitPromise: true },
    }));
  });

// --- ページ内で実行する関数 ---
const forceShow = (on) => {
  // Vivaldi は表示中のラッパーに .show を付け、その状態で不透明な背景を
  // 塗るため、transform を外すだけでなく .show も付けて表示時を再現する
  let st = document.getElementById('glass-audit-show');
  for (const w of document.querySelectorAll('.auto-hide-wrapper')) {
    if (on && !w.classList.contains('show')) w.classList.add('show'), (w.dataset.glassAudit = '1');
    if (!on && w.dataset.glassAudit) w.classList.remove('show'), delete w.dataset.glassAudit;
  }
  if (!on) return void st?.remove();
  st ??= Object.assign(document.createElement('style'), { id: 'glass-audit-show' });
  st.textContent = '.auto-hide-wrapper{transform:none!important;pointer-events:auto!important}';
  document.head.appendChild(st);
};

const audit = () => {
  const alphaOf = (bg) => {
    if (bg === 'transparent') return 0;
    const slash = bg.match(/\/\s*([0-9.]+)\s*\)$/);
    if (slash) return +slash[1];
    const p = bg.match(/\(([^)]*)\)/)[1].split(',');
    return p.length === 4 ? +p[3] : 1;
  };
  const name = (e) => e.tagName.toLowerCase() + (e.id ? '#' + e.id : '') +
    (typeof e.className === 'string' && e.className
      ? '.' + e.className.trim().split(/\s+/).filter((c) => !/[0-9a-f]{8}-/.test(c)).slice(0, 3).join('.') : '');
  const path = (el) => {
    const p = [];
    for (let e = el; e && e.id !== 'browser'; e = e.parentElement) p.unshift(name(e));
    return p.slice(-3).join(' > ');
  };
  // 機能的な表示 (選択行・チェックボックス・スライダー・サムネイル操作) は対象外
  const ignore = '.tree-row-selected, .tree-row-selected *, input[type=checkbox], input[type=range], .thumb-controls *, .item-count, svg *';
  const rows = new Map();
  for (const el of document.querySelectorAll('.auto-hide-wrapper, .auto-hide-wrapper *, .inner > .StatusInfo *, .button-popup, .button-popup *')) {
    if (el.matches(ignore)) continue;
    const r = el.getBoundingClientRect();
    if (r.width < 4 || r.height < 4) continue;
    const bg = getComputedStyle(el).backgroundColor;
    const a = alphaOf(bg);
    if (a < 0.85) continue;
    const key = path(el);
    rows.set(key, `a=${a.toFixed(2)} ${bg} ${Math.round(r.width)}x${Math.round(r.height)} | ${key}`);
  }

  // 文字色の検査: ガラス (背景を置き換えた所) の上に、元の不透明背景向けの
  // 文字色が残っていないか (例: アクティブタブの --colorAccentFg)。
  // ダークテーマで暗い文字 / ライトテーマで明るい文字を報告する。
  // 不透明に近い背景 (選択行のアクセント等) の上にある文字は対象外
  const rgbOf = (c) => {
    const n = c.match(/[0-9.]+/g).map(Number);
    return c.startsWith('color(') ? n.slice(0, 3).map((v) => v * 255) : n.slice(0, 3);
  };
  const lum = ([r, g, b]) => (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255;
  const dark = document.getElementById('browser').classList.contains('theme-dark');
  const onSolid = (el) => {
    for (let e = el; e && !e.classList.contains('auto-hide-wrapper'); e = e.parentElement)
      if (alphaOf(getComputedStyle(e).backgroundColor) >= 0.5) return true;
    return false;
  };
  for (const el of document.querySelectorAll('.auto-hide-wrapper *, .button-popup *')) {
    if (el.matches(ignore) || el.closest('.tree-row-selected')) continue;
    if (![...el.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim())) continue;
    const r = el.getBoundingClientRect();
    if (r.width < 4 || r.height < 4) continue;
    const c = getComputedStyle(el).color;
    const l = lum(rgbOf(c));
    if ((dark ? l >= 0.35 : l <= 0.65) || onSolid(el)) continue;
    const key = path(el);
    rows.set('text:' + key, `text lum=${l.toFixed(2)} ${c} | ${key}`);
  }

  // 各辺のラッパーにガラス (自身か ::after の、半透明背景 + backdrop-filter)
  // があるか。ぼかしだけで背景色が消えていると (Vivaldi 側の詳細度の高い
  // 指定に負けた等)、ページの明暗がそのまま透けて文字が読めなくなる
  for (const w of document.querySelectorAll('.auto-hide-wrapper')) {
    const r = w.getBoundingClientRect();
    if (r.width < 4 || r.height < 4) continue;
    const glassy = (cs) => cs.backdropFilter !== 'none' && alphaOf(cs.backgroundColor) > 0;
    if (!glassy(getComputedStyle(w)) && !glassy(getComputedStyle(w, '::after')))
      rows.set('noglass:' + name(w), `no-glass (背景色かぼかしが無い) | ${name(w)}`);
  }

  // ガラスの二重掛け検査: ガラス (backdrop-filter) の中に別のガラスがあると、
  // 半透明が重なって濃く見えたり、同じ辺のバー同士の継ぎ目が線として
  // 見えたりする。入力候補・ポップアップは上に重なる別レイヤーなので対象外
  const layered = '.OmniDropdown, .button-popup';
  for (const el of document.querySelectorAll('.auto-hide-wrapper *')) {
    if (getComputedStyle(el).backdropFilter === 'none' || el.matches(layered) || el.closest(layered)) continue;
    const r = el.getBoundingClientRect();
    if (r.width < 4 || r.height < 4) continue;
    const outer = el.parentElement.closest('.auto-hide-wrapper, .auto-hide-wrapper *');
    let a = el.parentElement;
    while (a && getComputedStyle(a).backdropFilter === 'none') a = a.parentElement;
    if (!a || !outer) continue;
    rows.set('nested:' + path(el), `nested-glass in ${name(a)} | ${path(el)}`);
  }
  return [...rows.values()];
};

const panelCount = () => document.querySelectorAll('#switch button[aria-controls="ui-region-panel"]').length;
const activePanel = () =>
  [...document.querySelectorAll('#switch button[aria-controls="ui-region-panel"]')].findIndex((b) => b.parentElement.classList.contains('active'));
const openPanel = async (i) => {
  // Vivaldi の UI は click() だけでは反応しないため pointer/mouse 一式を送る
  const b = document.querySelectorAll('#switch button[aria-controls="ui-region-panel"]')[i];
  const r = b.getBoundingClientRect();
  const o = { bubbles: true, cancelable: true, clientX: r.x + 5, clientY: r.y + 5, button: 0, pointerId: 1, pointerType: 'mouse', isPrimary: true };
  for (const t of ['pointerdown', 'mousedown', 'pointerup', 'mouseup', 'click'])
    b.dispatchEvent(t.startsWith('pointer') ? new PointerEvent(t, o) : new MouseEvent(t, o));
  await new Promise((res) => setTimeout(res, 800));
  return `${b.title} (${document.querySelector('#panels .panel')?.className || '-'})`;
};

// --- 実行 ---
await evaluate(forceShow, true);
try {
  const report = (label, rows) =>
    console.log(`== ${label}: ${rows.length ? rows.length + ' 件の問題' : 'OK'}\n${rows.join('\n')}`.trimEnd());
  if (withPanels) {
    // 検査後は元の表示状態 (開いていたパネル、または閉じた状態) に戻す
    const before = await evaluate(activePanel);
    const n = await evaluate(panelCount);
    for (let i = 0; i < n; i++) report(await evaluate(openPanel, i), await evaluate(audit));
    if (before >= 0) await evaluate(openPanel, before);
    else await evaluate(openPanel, n - 1), await evaluate(openPanel, n - 1);
  } else {
    report('現在の表示', await evaluate(audit));
  }
} finally {
  await evaluate(forceShow, false);
  ws.close();
}
