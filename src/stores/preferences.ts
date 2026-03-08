import { defaultLanguage, type Language } from "@/i18n";
import { getCurrentWindow } from "@tauri-apps/api/window";
import { createJSONStorage, persist } from "zustand/middleware";
import { tauriStorage } from "./storage";
import { createSyncedStore } from "./sync";

export const PREFERENCES_STORE = "preferences_store";

interface PreferencesState {
  language: Language;
}

interface PreferencesActions {
  setLanguage(language: Language): void;
}

export type PreferencesStore = PreferencesState & PreferencesActions;

const createPreferencesStore = createSyncedStore<PreferencesStore>(
  PREFERENCES_STORE,
  (set) => ({
    language: defaultLanguage,
    setLanguage(language) {
      set({ language });
    },
  }),
  (config) =>
    persist(config, {
      name: PREFERENCES_STORE,
      storage: createJSONStorage(() => tauriStorage),
    }),
);

export const usePreferences = createPreferencesStore(
  getCurrentWindow().label === "settings",
);
