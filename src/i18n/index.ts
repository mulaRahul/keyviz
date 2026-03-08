import { en, type TranslationKey } from "./locales/en";
import { zhCN } from "./locales/zh-CN";

export type Language = "en" | "zh-CN";
export type TranslationParams = Record<string, string | number>;

export const defaultLanguage: Language = "en";

const locales: Record<Language, Record<TranslationKey, string>> = {
  en,
  "zh-CN": zhCN,
};

function interpolate(template: string, params?: TranslationParams): string {
  if (!params) return template;
  return template.replace(/\{(\w+)\}/g, (_, token: string) => {
    const value = params[token];
    return value === undefined ? `{${token}}` : String(value);
  });
}

export function translate(
  language: Language,
  key: TranslationKey,
  params?: TranslationParams,
): string {
  const locale = locales[language] ?? locales[defaultLanguage];
  const message = locale[key] ?? locales[defaultLanguage][key] ?? key;
  return interpolate(message, params);
}

export type { TranslationKey };
