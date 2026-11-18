import { useState } from "react";

import { AboutPage, AppearanceSettings, GeneralSettings, KeycapSettings, MouseSettings } from "@/components/settings";
import { VERSION } from "@/components/settings/about";
import { ThemeModeToggle } from "@/components/theme-mode-toggle";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Separator } from "@/components/ui/separator";
import { SidebarItem } from "@/components/ui/sidebar-item";
import { ComputerIcon, InformationSquareIcon, KeyboardIcon, Mouse09Icon, Settings03Icon } from "@hugeicons/core-free-icons";
import { useTranslation } from 'react-i18next'

const sideBar = [
    { titleKey: "general", fallback: "General", icon: Settings03Icon },
    { titleKey: "appearance", fallback: "Appearance", icon: ComputerIcon },
    { titleKey: "keycap", fallback: "Keycap", icon: KeyboardIcon },
    { titleKey: "mouse", fallback: "Mouse", icon: Mouse09Icon },
]

const Settings = () => {
    const { t } = useTranslation()
    const [activeTab, setActiveTab] = useState(sideBar[0].titleKey);

    return (
        <div className="flex w-screen h-screen overflow-hidden border-t bg-background">
            <div className="w-44 p-2 flex flex-col gap-y-1 rounded-xl">
                <div className="flex items-center m-2 mb-2 gap-x-2">
                    <img src="./logo.svg" alt={t('logo', 'logo')} className="w-8 h-8" />
                    <div className="flex flex-col gap-y-0.5">
                        <h1 className="text-sm font-semibold">{t('keyviz', 'Keyviz')}</h1>
                        <p className="text-xs text-gray-400">v{VERSION}-beta</p>
                    </div>
                </div>
                {
                    sideBar.map((item) => (
                        <a key={item.titleKey} onClick={() => setActiveTab(item.titleKey)} className="cursor-pointer">
                            <SidebarItem item={{ title: t(item.titleKey, item.fallback), icon: item.icon }} isActive={activeTab === item.titleKey} />
                        </a>
                    ))
                }
                <div className="mt-auto flex gap-2 items-center">
                    <a key="about" onClick={() => setActiveTab("about")} className="flex-1 cursor-pointer">
                        <SidebarItem item={{ title: t('about', 'About'), icon: InformationSquareIcon }} isActive={activeTab === "about"} />
                    </a>
                    <ThemeModeToggle />
                </div>
            </div>
            <Separator orientation="vertical" />
            <ScrollArea className="flex-1 relative">
                {activeTab === "general" && <GeneralSettings />}
                {activeTab === "appearance" && <AppearanceSettings />}
                {activeTab === "keycap" && <KeycapSettings />}
                {activeTab === "mouse" && <MouseSettings />}
                {activeTab === "about" && <AboutPage />}
            </ScrollArea>
        </div>
    );
}

export default Settings;