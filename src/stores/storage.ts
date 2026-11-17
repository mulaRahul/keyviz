import { getCurrentWindow } from '@tauri-apps/api/window';
import { load } from '@tauri-apps/plugin-store';
import { StateStorage } from 'zustand/middleware';

// only allow writes from the settings window
const isSender = getCurrentWindow().label === "settings";

// initialize the store instance
export const store = await load('store.json', {
    autoSave: isSender ? 1000 : false,
    defaults: {},
});

//create the storage adapter for Zustand
export const tauriStorage: StateStorage = {
    getItem: async (name: string): Promise<string | null> => {
        return (await store.get<string>(name)) ?? null;
    },

    setItem: async (name: string, value: string): Promise<void> => {
        if (!isSender) return;
        await store.set(name, value);
    },
    
    removeItem: async (name: string): Promise<void> => {
        if (!isSender) return;
        await store.delete(name);
    },
};