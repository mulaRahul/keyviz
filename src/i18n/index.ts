import { emit, listen } from "@tauri-apps/api/event";
import { invoke } from "@tauri-apps/api/core";
import { locale } from "@tauri-apps/plugin-os";
import i18next from "i18next";
import { initReactI18next } from "react-i18next";
import { store } from "@/stores/storage";
import en from "./locales/en.json";
import fr from "./locales/fr.json";

export type Language = "en" | "fr";
export type LanguagePreference = "system" | Language;

interface LanguagePreferenceEvent {
  preference: LanguagePreference;
  language: Language;
}

let detectedLanguage: Language = "en";
let languagePreference: LanguagePreference = "system";

function supportedLanguage(locale: string | null | undefined): Language | undefined {
  const normalized = locale?.toLowerCase();
  if (normalized?.startsWith("fr")) return "fr";
  if (normalized?.startsWith("en")) return "en";
  return undefined;
}

async function setActiveLanguage(language: Language): Promise<void> {
  await i18next.changeLanguage(language);
  document.documentElement.lang = language;
  try {
    await invoke("set_language", { language });
  } catch (error) {
    console.error("Failed to update native language", error);
  }
}

export async function initializeLanguage(): Promise<void> {
  const osLocale = await locale().catch(() => null);
  detectedLanguage = supportedLanguage(osLocale)
    ?? supportedLanguage(navigator.language)
    ?? "en";
  const storedPreference = await store.get<unknown>("language_preference");
  languagePreference = storedPreference === "en" || storedPreference === "fr" || storedPreference === "system"
    ? storedPreference
    : "system";

  await i18next.use(initReactI18next).init({
    resources: {
      en: { translation: en },
      fr: { translation: fr },
    },
    lng: languagePreference === "system" ? detectedLanguage : languagePreference,
    fallbackLng: "en",
    keySeparator: false,
    interpolation: { escapeValue: false },
  });

  await setActiveLanguage(languagePreference === "system" ? detectedLanguage : languagePreference);

  await listen<LanguagePreferenceEvent>("language-preference", ({ payload }) => {
    languagePreference = payload.preference;
    void setActiveLanguage(payload.language);
  });
}

export function getLanguagePreference(): LanguagePreference {
  return languagePreference;
}

export async function setLanguagePreference(preference: LanguagePreference): Promise<void> {
  languagePreference = preference;
  const language = preference === "system" ? detectedLanguage : preference;
  await store.set("language_preference", preference);
  await store.save();
  await setActiveLanguage(language);
  await emit<LanguagePreferenceEvent>("language-preference", { preference, language });
}