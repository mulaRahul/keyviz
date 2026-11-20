import { getCurrentWindow } from '@tauri-apps/api/window';
import { load } from '@tauri-apps/plugin-store';
import { StateStorage } from 'zustand/middleware';
import { inTauri } from '@/lib/env';

// only allow writes from the settings window
const isSender = inTauri && getCurrentWindow().label === "settings";

// initialize the store instance; outside Tauri (the OBS browser source page)
// there is no store file, so fall back to localStorage to keep the page inert
const store = inTauri
    ? await load('store.json', {
        autoSave: isSender ? 1000 : false,
        defaults: {},
    })
    : null;

//create the storage adapter for Zustand
export const tauriStorage: StateStorage = {
    getItem: async (name: string): Promise<string | null> => {
        if (!store) return localStorage.getItem(name);
        return (await store.get<string>(name)) ?? null;
    },

    setItem: async (name: string, value: string): Promise<void> => {
        if (!store) {
            localStorage.setItem(name, value);
            return;
        }
        if (!isSender) return;
        await store.set(name, value);
    },

    removeItem: async (name: string): Promise<void> => {
        if (!store) {
            localStorage.removeItem(name);
            return;
        }
        if (!isSender) return;
        await store.delete(name);
    },
};
