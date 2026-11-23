import i18next from 'i18next';
import { initReactI18next } from 'react-i18next';
import { locale } from '@tauri-apps/plugin-os';
import { load } from '@tauri-apps/plugin-store';
import enUSTranslation from './locales/en-US/translation.json';
import zhCNTranslation from './locales/zh-CN/translation.json';
import frFRTranslation from './locales/fr-FR/translation.json';
import esESTranslation from './locales/es-ES/translation.json';

const supportedLanguages = ['en-US', 'zh-CN', 'fr-FR', 'es-ES'];

const matchSupportedLanguage = (language: string | null | undefined) => {
  if (!language) {
    return undefined;
  }
  const normalizedLanguage = language.replace(/_/g, '-').toLowerCase();
  return supportedLanguages.find(
    (supportedLanguage) => supportedLanguage.toLowerCase() === normalizedLanguage,
  ) ?? supportedLanguages.find(
    (supportedLanguage) => supportedLanguage.split('-')[0].toLowerCase() === normalizedLanguage.split('-')[0],
  );
};

const store = await load('store.json', { defaults: {} });
const savedLanguage = await store.get<string>('language');
const systemLocale = savedLanguage ? undefined : await locale();
const initialLanguage = savedLanguage
  ? matchSupportedLanguage(savedLanguage) ?? 'en-US'
  : matchSupportedLanguage(systemLocale) ?? 'en-US';

await i18next
  .use(initReactI18next)
  .init({
    lng: initialLanguage,
    returnEmptyString: false,
    fallbackLng: 'en-US',
    defaultNS: 'translation',
    resources: {
      'en-US': { translation: enUSTranslation },
      'zh-CN': { translation: zhCNTranslation },
      'fr-FR': { translation: frFRTranslation },
      'es-ES': { translation: esESTranslation },
    },
  });

document.documentElement.lang = i18next.language;
i18next.on('languageChanged', (language) => {
  document.documentElement.lang = language;
});

export default i18next;
