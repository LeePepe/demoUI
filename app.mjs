import { palettes, getTheme, flattenTokens } from './tokens.mjs';

const $ = selector => document.querySelector(selector);
const params = new URLSearchParams(location.search);
let color = Object.hasOwn(palettes, params.get('color')) ? params.get('color') : 'blue';
let mode = ['light', 'dark'].includes(params.get('mode')) ? params.get('mode') : 'light';
let current;

for (const [key, palette] of Object.entries(palettes)) {
  const button = document.createElement('button');
  button.type = 'button'; button.className = 'swatch-button'; button.dataset.color = key;
  button.setAttribute('aria-label', palette.name); button.title = palette.name;
  button.style.setProperty('--swatch-color', palette.seed);
  button.style.setProperty('--swatch-ink', getTheme(key, 'light').text.primary);
  button.innerHTML = '<span class="color-dot"><svg aria-hidden="true"><use href="#check"/></svg></span>';
  button.addEventListener('click', () => { color = key; applyTheme(); });
  $('#palette-options').append(button);
}

function applyTheme(updateURL = true) {
  current = getTheme(color, mode);
  for (const [name, value] of flattenTokens(current)) document.documentElement.style.setProperty(`--${name}`, value);
  document.documentElement.style.colorScheme = mode;
  document.documentElement.dataset.mode = mode;
  $('#theme-name').textContent = `${palettes[color].name} / ${mode === 'light' ? '浅色' : '深色'}`;
  $('#theme-english').textContent = `${palettes[color].english} · ${mode === 'light' ? 'Light' : 'Dark'}`;
  document.querySelectorAll('[data-color]').forEach(button => button.setAttribute('aria-pressed', String(button.dataset.color === color)));
  document.querySelectorAll('button[data-mode]').forEach(button => button.setAttribute('aria-pressed', String(button.dataset.mode === mode)));
  const preview = [['page', current.surface.page], ['region', current.surface.region], ['card', current.surface.card], ['brand', current.brand.primary], ['text', current.text.primary]];
  $('#token-preview').replaceChildren(...preview.map(([name, value]) => {
    const item = document.createElement('div'); item.className = 'token-item';
    item.style.setProperty('--preview-color', value);
    item.innerHTML = `<div class="token-color" aria-hidden="true"></div><code>${name}</code><small>${value}</small>`;
    return item;
  }));
  if (updateURL) { const url = new URL(location.href); url.searchParams.set('color', color); url.searchParams.set('mode', mode); history.replaceState(null, '', url); }
  $('#announcement').textContent = `主题已切换：${current.name}`;
  document.body.dataset.ready = 'true';
}

document.querySelectorAll('button[data-mode]').forEach(button => button.addEventListener('click', () => { mode = button.dataset.mode; applyTheme(); }));
window.addEventListener('popstate', () => { const p = new URLSearchParams(location.search); const t = getTheme(p.get('color'), p.get('mode')); color = t.color; mode = t.mode; applyTheme(false); });

$('#save-demo').addEventListener('click', async event => {
  const button = event.currentTarget;
  button.disabled = true; button.setAttribute('aria-busy', 'true');
  button.innerHTML = '<span class="spinner" aria-hidden="true"></span><span>保存中…</span>';
  $('#button-feedback').textContent = '正在模拟保存，无网络请求。';
  await new Promise(resolve => setTimeout(resolve, parseInt(current.motion.feedback, 10)));
  button.removeAttribute('aria-busy'); button.disabled = false;
  button.innerHTML = '<svg aria-hidden="true"><use href="#check"/></svg><span>保存示例</span>';
  $('#button-feedback').textContent = '✓ 示例已保存。仅演示反馈，未写入真实数据。';
});
$('#secondary-demo').addEventListener('click', () => { $('#button-feedback').textContent = '✓ Secondary 已触发：次级操作使用中性表面。'; });
$('#ghost-demo').addEventListener('click', () => { $('#button-feedback').textContent = '✓ Ghost 已触发：轻量操作保持视觉克制。'; });
$('#card-demo').addEventListener('click', () => { $('#card-feedback').textContent = '卡片规则：16px 内边距 · 12px 圆角 · 独立表面层级。'; });
document.querySelectorAll('.list-row').forEach(button => button.addEventListener('click', () => {
  document.querySelectorAll('.list-row').forEach(row => row.setAttribute('aria-pressed', String(row === button)));
  $('#list-feedback').textContent = `当前：${button.dataset.note}`;
}));
$('#download-tokens').addEventListener('click', () => {
  const blob = new Blob([`${JSON.stringify(current, null, 2)}\n`], { type: 'application/json' });
  const url = URL.createObjectURL(blob); const link = document.createElement('a');
  link.href = url; link.download = `strata-${color}-${mode}.json`; link.click();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
  $('#announcement').textContent = `已下载 ${current.name} 的 tokens JSON。`;
});
document.querySelectorAll('svg:not(.svg-defs)').forEach(svg => svg.setAttribute('aria-hidden', 'true'));
applyTheme();
