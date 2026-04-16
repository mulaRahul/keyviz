import { locale as getSystemLocale } from "@tauri-apps/plugin-os";
import { createContext, ReactNode, useContext, useEffect, useMemo, useState } from "react";
import { useKeyStyle } from "./stores/key_style";

export type SupportedLanguage = "en" | "zh-CN";

interface I18nContextValue {
  language: SupportedLanguage;
  systemLocale: string | null;
  t: (english: string, chinese: string) => string;
}

const I18nContext = createContext<I18nContextValue>({
  language: "en",
  systemLocale: null,
  t: (english) => english,
});

function normalizeLanguage(locale: string | null | undefined): SupportedLanguage {
  if (locale?.toLowerCase().startsWith("zh")) {
    return "zh-CN";
  }
  return "en";
}

export function I18nProvider({ children }: { children: ReactNode }) {
  const preference = useKeyStyle((state) => state.appearance.language);
  const [systemLocale, setSystemLocale] = useState<string | null>(null);

  useEffect(() => {
    let mounted = true;

    const loadLocale = async () => {
      try {
        const locale = await getSystemLocale();
        if (mounted) {
          setSystemLocale(locale ?? navigator.language ?? null);
        }
      } catch {
        if (mounted) {
          setSystemLocale(navigator.language ?? null);
        }
      }
    };

    loadLocale();

    return () => {
      mounted = false;
    };
  }, []);

  const language = useMemo<SupportedLanguage>(() => {
    if (preference === "system") {
      return normalizeLanguage(systemLocale);
    }
    return preference;
  }, [preference, systemLocale]);

  const value = useMemo<I18nContextValue>(() => ({
    language,
    systemLocale,
    t: (english, chinese) => language === "zh-CN" ? chinese : english,
  }), [language, systemLocale]);

  return <I18nContext.Provider value={value}>{children}</I18nContext.Provider>;
}

export function useI18n() {
  return useContext(I18nContext);
}
