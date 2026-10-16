import { palettes, getTheme, flattenTokens } from './tokens.mjs';

const $ = selector => document.querySelector(selector);
const params = new URLSearchParams(location.search);
let color = Object.hasOwn(palettes, params.get('color')) ? params.get('color') : 'blue';
let mode = ['light', 'dark'].includes(params.get('mode')) ? params.get('mode') : 'light';
let material = ['glass', 'solid'].includes(params.get('material')) ? params.get('material') : 'glass';
const reducedTransparency = matchMedia('(prefers-reduced-transparency: reduce)');
const supportsGlass = CSS.supports('backdrop-filter', 'blur(1px)') || CSS.supports('-webkit-backdrop-filter', 'blur(1px)');
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
  const effectiveMaterial = reducedTransparency.matches || !supportsGlass ? 'solid' : material;
  current = getTheme(color, mode, effectiveMaterial);
  for (const [name, value] of flattenTokens(current)) document.documentElement.style.setProperty(`--${name}`, value);
  document.documentElement.style.colorScheme = mode;
  document.documentElement.dataset.mode = mode;
  document.documentElement.dataset.material = effectiveMaterial;
  $('#theme-name').textContent = `${palettes[color].name} / ${mode === 'light' ? '浅色' : '深色'}`;
  $('#theme-english').textContent = `${palettes[color].english} · ${mode === 'light' ? 'Light' : 'Dark'}`;
  $('#material-toggle').setAttribute('aria-pressed', String(effectiveMaterial === 'glass'));
  $('#material-toggle').disabled = reducedTransparency.matches || !supportsGlass;
  $('#material-toggle').setAttribute('aria-label', reducedTransparency.matches ? '系统已启用减少透明度' : !supportsGlass ? '当前浏览器使用实底材质' : `${effectiveMaterial === 'glass' ? '玻璃' : '实底'}材质，切换为${effectiveMaterial === 'glass' ? '实底' : '玻璃'}`);
  $('#material-label').textContent = effectiveMaterial === 'glass' ? '玻璃' : '实底';
  $('#control-spec').textContent = `${current.size.control} 高度 / 胶囊圆角`;
  $('#radius-spec').textContent = `圆角 ${current.radius.control.replace('px', '')} / ${current.radius.card.replace('px', '')} / ${current.radius.container.replace('px', '')}`;
  document.querySelectorAll('[data-color]').forEach(button => button.setAttribute('aria-pressed', String(button.dataset.color === color)));
  document.querySelectorAll('button[data-mode]').forEach(button => button.setAttribute('aria-pressed', String(button.dataset.mode === mode)));
  const preview = [['page', current.surface.page], ['glass', current.material.panel], ['card', current.surface.card], ['brand', current.brand.primary], ['text', current.text.primary]];
  $('#token-preview').replaceChildren(...preview.map(([name, value]) => {
    const item = document.createElement('div'); item.className = 'token-item';
    item.style.setProperty('--preview-color', value);
    item.innerHTML = `<div class="token-color" aria-hidden="true"></div><code>${name}</code><small>${value}</small>`;
    return item;
  }));
  if (updateURL) { const url = new URL(location.href); url.searchParams.set('color', color); url.searchParams.set('mode', mode); url.searchParams.set('material', material); history.replaceState(null, '', url); }
  $('#announcement').textContent = `主题已切换：${current.name}`;
  document.body.dataset.ready = 'true';
}

document.querySelectorAll('button[data-mode]').forEach(button => button.addEventListener('click', () => { mode = button.dataset.mode; applyTheme(); }));
$('#material-toggle').addEventListener('click', () => { material = material === 'glass' ? 'solid' : 'glass'; applyTheme(); });
reducedTransparency.addEventListener('change', () => applyTheme());
window.addEventListener('popstate', () => { const p = new URLSearchParams(location.search); const t = getTheme(p.get('color'), p.get('mode'), p.get('material')); color = t.color; mode = t.mode; material = t.material.kind; applyTheme(false); });

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
$('#card-demo').addEventListener('click', () => { $('#card-feedback').textContent = `卡片规则：${current.space['4']} 内边距 · ${current.radius.card} 圆角 · ${current.material.kind === 'glass' ? '半透明表面与细高光' : '实底表面'}。`; });
document.querySelectorAll('.list-row').forEach(button => button.addEventListener('click', () => {
  document.querySelectorAll('.list-row').forEach(row => row.setAttribute('aria-pressed', String(row === button)));
  $('#list-feedback').textContent = `当前：${button.dataset.note}`;
}));
$('#download-tokens').addEventListener('click', () => {
  const blob = new Blob([`${JSON.stringify(current, null, 2)}\n`], { type: 'application/json' });
  const url = URL.createObjectURL(blob); const link = document.createElement('a');
  link.href = url; link.download = `strata-${color}-${mode}-${current.material.kind}.json`; link.click();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
  $('#announcement').textContent = `已下载 ${current.name} 的 tokens JSON。`;
});
document.querySelectorAll('svg:not(.svg-defs)').forEach(svg => svg.setAttribute('aria-hidden', 'true'));
applyTheme();
