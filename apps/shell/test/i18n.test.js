'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');
const i18n = require('../utils/i18n');

describe('Shell i18n utilities', () => {
  const OLD_ENV = process.env;

  beforeEach(() => {
    process.env = { ...OLD_ENV, NODE_ENV: 'test' };
    delete process.env.OOD_LOCALE;
    delete process.env.OOD_SUPPORTED_LOCALES;
    delete process.env.OOD_USER_SETTINGS_FILE;
    delete process.env.OOD_CONFIG_D_DIRECTORY;
  });

  afterAll(() => {
    process.env = OLD_ENV;
  });

  test('normalizes POSIX underscore and lowercase locale tags to canonical BCP 47', () => {
    expect(i18n.toBcp47('ja_JP')).toBe('ja-JP');
    expect(i18n.toBcp47('fr_ca')).toBe('fr-CA');
    expect(i18n.toBcp47('zh_hans_cn')).toBe('zh-Hans-CN');
    expect(i18n.toBcp47('')).toBe('en');
  });

  test('every shipped locale JSON has 100% key parity and matching placeholders with en.json', () => {
    const enKeys = Object.keys(i18n.CATALOGS.en).sort();
    expect(enKeys.length).toBeGreaterThanOrEqual(15);

    for (const [locale, catalog] of Object.entries(i18n.CATALOGS)) {
      expect(Object.keys(catalog).sort()).toEqual(enKeys);
      for (const key of enKeys) {
        const enVars = (i18n.CATALOGS.en[key].match(/%\{[a-zA-Z0-9_]+\}/g) || []).sort();
        const locVars = (catalog[key].match(/%\{[a-zA-Z0-9_]+\}/g) || []).sort();
        expect({ locale, key, vars: locVars }).toEqual({ locale, key, vars: enVars });
      }
    }
  });

  test('resolves locale in precedence order: settings.yml -> ood_locale cookie -> Accept-Language -> OOD_LOCALE', () => {
    const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'shell-i18n-'));
    const settingsPath = path.join(tmpDir, 'settings.yml');
    fs.writeFileSync(settingsPath, 'locale: fr-CA\n', 'utf8');

    try {
      process.env.OOD_USER_SETTINGS_FILE = settingsPath;
      process.env.OOD_LOCALE = 'en';

      expect(
        i18n.resolveLocale({
          headers: {
            cookie: 'ood_locale=ja-JP',
            'accept-language': 'zh-CN,zh;q=0.9',
          },
        })
      ).toBe('fr-CA');

      fs.unlinkSync(settingsPath);
      expect(
        i18n.resolveLocale({
          headers: {
            cookie: 'other=1; ood_locale=ja_JP',
            'accept-language': 'zh-CN,zh;q=0.9',
          },
        })
      ).toBe('ja-JP');

      expect(
        i18n.resolveLocale({
          headers: {
            'accept-language': 'fr-FR,fr;q=0.9,en;q=0.8',
          },
        })
      ).toBe('fr-CA');

      process.env.OOD_LOCALE = 'fa_IR';
      expect(i18n.resolveLocale({ headers: {} })).toBe('fa-IR');
    } finally {
      fs.rmSync(tmpDir, { recursive: true, force: true });
    }
  });

  test('interpolates placeholders and falls back cleanly to English for missing keys', () => {
    expect(i18n.t('fr-CA', 'host_label', { host: 'eureka-login2' })).toBe('Hôte : eureka-login2');
    expect(i18n.t('fr-CA', 'page_title', { siteTitle: 'Eureka' })).toBe('Terminal - Eureka');

    const partialCatalogs = {
      en: { greeting: 'Hello %{name}', only_en: 'Fallback works' },
      'fr-CA': { greeting: 'Bonjour %{name}' },
    };
    expect(i18n.t('fr-CA', 'greeting', { name: 'Gaius' }, partialCatalogs)).toBe('Bonjour Gaius');
    expect(i18n.t('fr-CA', 'only_en', {}, partialCatalogs)).toBe('Fallback works');
  });
});
