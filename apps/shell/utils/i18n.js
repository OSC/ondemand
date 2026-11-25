'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');
const yaml = require('js-yaml');

const LOCALES_DIR = path.join(__dirname, '..', 'locales');

function toBcp47(rawLocale) {
  const raw = String(rawLocale || '').trim();
  if (!raw) return 'en';

  const parts = raw.replace(/_/g, '-').split('-').filter(Boolean);
  if (parts.length === 0) return 'en';

  return parts
    .map((subtag, idx) => {
      if (idx === 0) return subtag.toLowerCase();
      if (subtag.length === 4 && /^[a-zA-Z]{4}$/.test(subtag)) {
        return subtag[0].toUpperCase() + subtag.slice(1).toLowerCase();
      }
      if ((subtag.length === 2 && /^[a-zA-Z]{2}$/.test(subtag)) || /^\d{3}$/.test(subtag)) {
        return subtag.toUpperCase();
      }
      return subtag;
    })
    .join('-');
}

function loadCatalogs(localesDir = LOCALES_DIR) {
  const catalogs = {};
  if (!fs.existsSync(localesDir)) return catalogs;

  for (const file of fs.readdirSync(localesDir).sort()) {
    if (!file.endsWith('.json')) continue;
    const tag = toBcp47(path.basename(file, '.json'));
    try {
      const parsed = JSON.parse(fs.readFileSync(path.join(localesDir, file), 'utf8'));
      if (parsed && typeof parsed === 'object') {
        catalogs[tag] = parsed;
      }
    } catch (_err) {
      // Ignore malformed custom locale files
    }
  }
  return catalogs;
}

const CATALOGS = loadCatalogs();

function availableLocales(catalogs = CATALOGS) {
  const keys = Object.keys(catalogs);
  return keys.length > 0 ? keys : ['en'];
}

function normalizeLocale(raw, allowed = availableLocales()) {
  if (raw === null || raw === undefined) return null;
  const cleaned = String(raw).trim();
  if (!cleaned) return null;

  const target = toBcp47(path.basename(cleaned, path.extname(cleaned))).toLowerCase();
  const exact = allowed.find((loc) => loc.toLowerCase() === target);
  if (exact) return exact;

  const primary = target.split('-')[0];
  return allowed.find((loc) => loc.toLowerCase().split('-')[0] === primary) || null;
}

function parseCookies(cookieHeader) {
  const result = {};
  if (!cookieHeader || typeof cookieHeader !== 'string') return result;

  for (const pair of cookieHeader.split(';')) {
    const idx = pair.indexOf('=');
    if (idx <= 0) continue;
    const key = pair.slice(0, idx).trim();
    const rawVal = pair.slice(idx + 1).trim();
    if (!key) continue;
    try {
      result[key] = decodeURIComponent(rawVal);
    } catch (_err) {
      result[key] = rawVal;
    }
  }
  return result;
}

function negotiateAcceptLanguage(header, supported = availableLocales()) {
  if (!header || typeof header !== 'string' || supported.length === 0) return null;

  const ranges = [];
  header.split(',').forEach((entry, idx) => {
    const [rawTag, ...params] = entry.trim().split(';');
    const tag = (rawTag || '').trim();
    if (!tag || tag === '*') return;

    let q = 1.0;
    for (const param of params) {
      const [k, v] = param.trim().split('=');
      if (k === 'q' && v !== undefined) {
        const parsed = Number(v);
        if (!Number.isNaN(parsed)) q = parsed;
      }
    }
    if (q > 0 && q <= 1.0) {
      ranges.push({ tag: toBcp47(tag).toLowerCase(), q, idx });
    }
  });

  ranges.sort((a, b) => (b.q !== a.q ? b.q - a.q : a.idx - b.idx));

  for (const { tag } of ranges) {
    const exact = supported.find((loc) => loc.toLowerCase() === tag);
    if (exact) return exact;

    const primary = tag.split('-')[0];
    const prefix = supported.find((loc) => loc.toLowerCase().split('-')[0] === primary);
    if (prefix) return prefix;
  }

  return null;
}

function readUserSettingsLocale() {
  const portal = process.env.OOD_PORTAL || 'ondemand';
  const defaultPath =
    process.env.NODE_ENV === 'test' && !process.env.OOD_USER_SETTINGS_FILE
      ? null
      : path.join(os.homedir(), '.config', portal, 'settings.yml');
  const settingsPath = process.env.OOD_USER_SETTINGS_FILE || defaultPath;
  if (!settingsPath || !fs.existsSync(settingsPath)) return null;

  try {
    const data = yaml.load(fs.readFileSync(settingsPath, 'utf8'));
    if (data && typeof data === 'object' && data.locale) {
      return String(data.locale);
    }
  } catch (_err) {
    return null;
  }
  return null;
}

function readOndemandConfig() {
  const dir =
    process.env.OOD_CONFIG_D_DIRECTORY ||
    (process.env.NODE_ENV === 'production' ? '/etc/ood/config/ondemand.d' : null);
  if (!dir || !fs.existsSync(dir)) return {};

  const merged = {};
  try {
    const files = fs
      .readdirSync(dir)
      .filter((f) => f.endsWith('.yml') || f.endsWith('.yaml'))
      .sort();
    for (const file of files) {
      try {
        const doc = yaml.load(fs.readFileSync(path.join(dir, file), 'utf8'));
        if (doc && typeof doc === 'object') Object.assign(merged, doc);
      } catch (_err) {
        // Ignore unreadable config fragment
      }
    }
  } catch (_err) {
    return {};
  }
  return merged;
}

function supportedLocales(catalogs = CATALOGS) {
  const allowed = availableLocales(catalogs);
  const ondemandCfg = readOndemandConfig();
  const rawList = process.env.OOD_SUPPORTED_LOCALES
    ? process.env.OOD_SUPPORTED_LOCALES.split(',').map((s) => s.trim()).filter(Boolean)
    : Array.isArray(ondemandCfg.supported_locales)
      ? ondemandCfg.supported_locales
      : [];

  const normalized = Array.from(
    new Set(rawList.map((entry) => normalizeLocale(entry, allowed)).filter(Boolean))
  );
  return normalized.length > 0 ? normalized : allowed;
}

function defaultLocale(catalogs = CATALOGS) {
  const allowed = availableLocales(catalogs);
  const ondemandCfg = readOndemandConfig();
  const rawDefault = process.env.OOD_LOCALE || ondemandCfg.locale || 'en';
  return normalizeLocale(rawDefault, allowed) || 'en';
}

function resolveLocale(req = {}, catalogs = CATALOGS) {
  const headers = (req && req.headers) || {};
  const supported = supportedLocales(catalogs);

  const userLocale = normalizeLocale(readUserSettingsLocale(), supported);
  if (userLocale) return userLocale;

  const cookies = parseCookies(headers.cookie);
  const cookieLocale = normalizeLocale(cookies.ood_locale, supported);
  if (cookieLocale) return cookieLocale;

  if (supported.length > 1) {
    const negotiated = negotiateAcceptLanguage(headers['accept-language'], supported);
    if (negotiated) return negotiated;
  }

  return defaultLocale(catalogs);
}

function catalogFor(locale, catalogs = CATALOGS) {
  const en = catalogs.en || {};
  const resolved = normalizeLocale(locale, availableLocales(catalogs)) || 'en';
  return Object.assign({}, en, catalogs[resolved] || {});
}

function interpolate(template, params = {}) {
  return String(template).replace(/%\{([a-zA-Z0-9_]+)\}/g, (match, key) =>
    Object.prototype.hasOwnProperty.call(params, key) && params[key] !== undefined && params[key] !== null
      ? String(params[key])
      : match
  );
}

function t(locale, key, params = {}, catalogs = CATALOGS) {
  const cat = catalogFor(locale, catalogs);
  const template = Object.prototype.hasOwnProperty.call(cat, key) ? cat[key] : key;
  return interpolate(template, params);
}

module.exports = {
  CATALOGS,
  availableLocales,
  catalogFor,
  defaultLocale,
  interpolate,
  loadCatalogs,
  negotiateAcceptLanguage,
  normalizeLocale,
  parseCookies,
  readOndemandConfig,
  readUserSettingsLocale,
  resolveLocale,
  supportedLocales,
  t,
  toBcp47,
};
