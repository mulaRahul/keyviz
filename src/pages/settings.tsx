import { useState } from "react";

import { AboutPage, AppearanceSettings, GeneralSettings, KeycapSettings, MouseSettings } from "@/components/settings";
import { VERSION } from "@/components/settings/about";
import { useI18n } from "@/hooks/use-i18n";
import { ThemeModeToggle } from "@/components/theme-mode-toggle";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Separator } from "@/components/ui/separator";
import { SidebarItem } from "@/components/ui/sidebar-item";
import { ComputerIcon, InformationSquareIcon, KeyboardIcon, Mouse09Icon, Settings03Icon } from "@hugeicons/core-free-icons";

const sideBar = [
    { id: "general", titleKey: "settings.sidebar.general" as const, icon: Settings03Icon },
    { id: "appearance", titleKey: "settings.sidebar.appearance" as const, icon: ComputerIcon },
    { id: "keycap", titleKey: "settings.sidebar.keycap" as const, icon: KeyboardIcon },
    { id: "mouse", titleKey: "settings.sidebar.mouse" as const, icon: Mouse09Icon },
];

const Settings = () => {
    const { t } = useI18n();
    const [activeTab, setActiveTab] = useState(sideBar[0].id);

    return (
        <div className="flex w-screen h-screen overflow-hidden border-t bg-background">
            <div className="w-44 p-2 flex flex-col gap-y-1 rounded-xl">
                <div className="flex items-center m-2 mb-2 gap-x-2">
                    <img src="./logo.svg" alt="logo" className="w-8 h-8" />
                    <div className="flex flex-col gap-y-0.5">
                        <h1 className="text-sm font-semibold">Keyviz</h1>
                        <p className="text-xs text-gray-400">v{VERSION}-beta</p>
                    </div>
                </div>
                {
                    sideBar.map((item) => (
                        <a key={item.id} onClick={() => setActiveTab(item.id)} className="cursor-pointer">
                            <SidebarItem
                                item={{ title: t(item.titleKey), icon: item.icon }}
                                isActive={activeTab === item.id}
                            />
                        </a>
                    ))
                }
                <div className="mt-auto flex gap-2 items-center">
                    <a key="about" onClick={() => setActiveTab("about")} className="flex-1 cursor-pointer">
                        <SidebarItem
                            item={{ title: t("settings.sidebar.about"), icon: InformationSquareIcon }}
                            isActive={activeTab === "about"}
                        />
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
