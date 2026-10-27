// Strata 0.2 — a glass material study with custom candy-inspired colors.
// This is the only source of color values and shared dimensions.
export const foundations = {
  font: { family: '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif', mono: 'ui-monospace, SFMono-Regular, Consolas, monospace', body: '14px', small: '12px', label: '11px', title: '32px', heading: '18px', metric: '40px', line: '1.6' },
  space: { '1': '4px', '2': '8px', '3': '12px', '4': '16px', '6': '24px', '8': '32px' },
  radius: { control: '16px', card: '24px', container: '32px', pill: '999px', button: '999px' },
  motion: { quick: '140ms', feedback: '900ms', easing: 'cubic-bezier(.2,.8,.2,1)' },
  size: { control: '40px', icon: '18px', swatch: '28px', focus: '3px', hairline: '1px', content: '1232px', sidebar: '228px', palette: '64px' }
};

export const palettes = {
  blue: { name: '潮汐蓝', english: 'Tidal blue', seed: '#82B8E4', light: { primary: '#2859BC', hover: '#204CA6', active: '#183D8B', subtle: '#EAF0FB', text: '#2859BC', page: '#E9EDF0', region: '#F2F4F6', card: '#FFFFFF', inset: '#F5F7F9', hoverSurface: '#E9EDF1', selected: '#DEE4EA' }, dark: { primary: '#94C5F0', hover: '#ACD4F6', active: '#7FB4E2', subtle: '#25394C', text: '#ACD4F6', page: '#161B21', region: '#1D242C', card: '#27313C', inset: '#202933', hoverSurface: '#303C48', selected: '#394653' } },
  green: { name: '青苔绿', english: 'Moss green', seed: '#99CDA4', light: { primary: '#236747', hover: '#1A573B', active: '#12472F', subtle: '#E8F2EA', text: '#236747', page: '#E9EDE8', region: '#F1F4EF', card: '#FFFFFF', inset: '#F5F7F3', hoverSurface: '#E7ECE5', selected: '#DDE5DA' }, dark: { primary: '#A3D8B0', hover: '#B8E4C1', active: '#8CC89B', subtle: '#293F32', text: '#B8E4C1', page: '#171D19', region: '#1F2822', card: '#2A352D', inset: '#232D26', hoverSurface: '#334036', selected: '#3C4A3F' } },
  pink: { name: '蔷薇粉', english: 'Rose pink', seed: '#E9A4B8', light: { primary: '#9C3C63', hover: '#873053', active: '#722545', subtle: '#F7EAF0', text: '#9C3C63', page: '#EFE9EB', region: '#F6F1F3', card: '#FFFFFF', inset: '#FAF5F7', hoverSurface: '#EEE6E9', selected: '#E8DDE1' }, dark: { primary: '#EFB0C5', hover: '#F6C4D4', active: '#DF9BB2', subtle: '#49323D', text: '#F6C4D4', page: '#20191D', region: '#2A2227', card: '#382D34', inset: '#30262C', hoverSurface: '#44363F', selected: '#4D3F47' } },
  yellow: { name: '麦芽黄', english: 'Malt yellow', seed: '#EDD47D', light: { primary: '#71560B', hover: '#604809', active: '#4D3906', subtle: '#F5EFD9', text: '#71560B', page: '#EEECE5', region: '#F6F4ED', card: '#FFFFFF', inset: '#FAF8F1', hoverSurface: '#EEEADD', selected: '#E5E0D1' }, dark: { primary: '#E7CF82', hover: '#F0DFA4', active: '#D7BA64', subtle: '#443D27', text: '#F0DFA4', page: '#201E17', region: '#29271F', card: '#363328', inset: '#2D2B22', hoverSurface: '#423E31', selected: '#4B4739' } },
  purple: { name: '鸢尾紫', english: 'Iris purple', seed: '#B7A4DB', light: { primary: '#6947AA', hover: '#5A3B95', active: '#49307D', subtle: '#F0EBF7', text: '#6947AA', page: '#ECE9EF', region: '#F4F1F7', card: '#FFFFFF', inset: '#F8F5FA', hoverSurface: '#EBE6F0', selected: '#E2DCE9' }, dark: { primary: '#C6B3EA', hover: '#D7C8F3', active: '#B39CD9', subtle: '#3D334E', text: '#D7C8F3', page: '#1C1922', region: '#25212D', card: '#322C3C', inset: '#2A2533', hoverSurface: '#3C3548', selected: '#463E53' } }
};

const semantic = {
  light: { text: { primary: '#232831', secondary: '#505864', onBrand: '#FFFFFF' }, border: '#C2C9D2', status: { success: '#276442', successSurface: '#EAF3EC', warning: '#795506', warningSurface: '#FAF1D8', error: '#AA3642', errorSurface: '#FBECEE' }, chart: { primary: '#527A91', secondary: '#9681A9', tertiary: '#B29C66' } },
  dark: { text: { primary: '#F1F1F4', secondary: '#CAC8D1', onBrand: '#201C28' }, border: '#746D80', status: { success: '#A4D8B4', successSurface: '#293E33', warning: '#E5CD8F', warningSurface: '#423B28', error: '#F0AEB8', errorSurface: '#493039' }, chart: { primary: '#9DC4D6', secondary: '#BFAAD6', tertiary: '#D4BF92' } }
};

const withAlpha = (hex, alpha) => `${hex}${Math.round(alpha * 255).toString(16).padStart(2, '0')}`;

// Materials have separate light/dark recipes. Opaque surface roles remain the
// fallback and the backing color; never apply opacity to a container's text.
function getMaterial(t, seed, mode, kind) {
  const light = mode === 'light', glass = kind === 'glass';
  const edge = light ? '#FFFFFFC7' : '#FFFFFF29';
  const highlight = light ? '#FFFFFFB8' : '#FFFFFF1F';
  const shade = light ? '#384B6310' : '#00000038';
  return {
    kind, panel: glass ? withAlpha(t.region, light ? .62 : .72) : t.region,
    content: glass ? withAlpha(t.card, light ? .70 : .82) : t.card,
    control: glass ? withAlpha(t.card, light ? .64 : .85) : t.card,
    edge: glass ? edge : 'transparent', highlight: glass ? highlight : 'transparent',
    innerEdge: glass ? (light ? '#FFFFFFA3' : '#FFFFFF17') : 'transparent',
    innerInset: glass ? `inset 0 1px 0 ${light ? '#FFFFFF80' : '#FFFFFF12'}` : 'none',
    sheen: glass ? `linear-gradient(155deg, ${highlight}, transparent 40%)` : 'none',
    blur: glass ? '24px' : '0px', saturation: glass ? '125%' : '100%',
    shadow: glass ? `0 8px 32px ${shade}` : 'none',
    inset: glass ? `inset 0 1px 0 ${highlight}, inset 0 -1px 0 ${light ? '#FFFFFF33' : '#0000001F'}` : 'none',
    ambient: withAlpha(seed, light ? .34 : .20), ambientSoft: withAlpha(seed, light ? .18 : .12),
    ambientEdge: withAlpha(seed, light ? .42 : .28), ambientVisibility: glass ? '1' : '0',
    ambientMobileScale: '.65',
    ambientWidth: '600px', ambientHeight: '280px', ambientStroke: '56px', ambientBlur: '2px'
  };
}

export function getTheme(color = 'blue', mode = 'light', material = 'glass') {
  if (!Object.hasOwn(palettes, color)) color = 'blue';
  if (!['light', 'dark'].includes(mode)) mode = 'light';
  if (!['glass', 'solid'].includes(material)) material = 'glass';
  const p = palettes[color], t = p[mode], s = semantic[mode];
  return { name: `Strata / ${p.name} / ${mode === 'light' ? '浅色' : '深色'} / ${material === 'glass' ? '玻璃' : '实底'}`, version: '0.2.0-prototype', color, mode, ...foundations,
    surface: { page: t.page, region: t.region, card: t.card, inset: t.inset, hover: t.hoverSurface, selected: t.selected },
    text: s.text, brand: { seed: p.seed, seedInk: semantic.light.text.primary, primary: t.primary, hover: t.hover, active: t.active, subtle: t.subtle, text: t.text },
    status: s.status, chart: s.chart, border: { default: s.border }, focus: { ring: t.primary },
    material: getMaterial(t, p.seed, mode, material)
  };
}

export function flattenTokens(object, prefix = '') {
  return Object.entries(object).flatMap(([key, value]) => {
    const name = prefix ? `${prefix}-${key}` : key;
    return value && typeof value === 'object' ? flattenTokens(value, name) : [[name.replace(/[A-Z]/g, m => `-${m.toLowerCase()}`), String(value)]];
  });
}
