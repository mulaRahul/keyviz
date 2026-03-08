import { translate, type TranslationKey, type TranslationParams } from "@/i18n";
import { usePreferences } from "@/stores/preferences";
import { useCallback } from "react";

export function useI18n() {
  const language = usePreferences((state) => state.language);

  const t = useCallback(
    (key: TranslationKey, params?: TranslationParams) =>
      translate(language, key, params),
    [language],
  );

  return { language, t };
}
