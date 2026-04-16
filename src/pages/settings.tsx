import { useState } from "react";

import { AboutPage, AppearanceSettings, GeneralSettings, KeycapSettings, MouseSettings } from "@/components/settings";
import { useI18n } from "@/i18n";
import { VERSION } from "@/components/settings/about";
import { ThemeModeToggle } from "@/components/theme-mode-toggle";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Separator } from "@/components/ui/separator";
import { SidebarItem } from "@/components/ui/sidebar-item";
import { ComputerIcon, InformationSquareIcon, KeyboardIcon, Mouse09Icon, Settings03Icon } from "@hugeicons/core-free-icons";

const sideBar = [
    { title: "General", icon: Settings03Icon },
    { title: "Appearance", icon: ComputerIcon },
    { title: "Keycap", icon: KeyboardIcon },
    { title: "Mouse", icon: Mouse09Icon },
]

const Settings = () => {
    const { t } = useI18n();
    const [activeTab, setActiveTab] = useState(sideBar[0].title);

    const localizedTitle = (title: string) => {
        switch (title) {
            case "General":
                return t("General", "通用");
            case "Appearance":
                return t("Appearance", "外观");
            case "Keycap":
                return t("Keycap", "键帽");
            case "Mouse":
                return t("Mouse", "鼠标");
            case "About":
                return t("About", "关于");
            default:
                return title;
        }
    };

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
                        <a key={item.title} onClick={() => setActiveTab(item.title)} className="cursor-pointer">
                            <SidebarItem item={{ ...item, title: localizedTitle(item.title) }} isActive={activeTab === item.title} />
                        </a>
                    ))
                }
                <div className="mt-auto flex gap-2 items-center">
                    <a key="about" onClick={() => setActiveTab("About")} className="flex-1 cursor-pointer">
                        <SidebarItem item={{ title: localizedTitle("About"), icon: InformationSquareIcon }} isActive={activeTab === "About"} />
                    </a>
                    <ThemeModeToggle />
                </div>
            </div>
            <Separator orientation="vertical" />
            <ScrollArea className="flex-1 relative">
                {activeTab === "General" && <GeneralSettings />}
                {activeTab === "Appearance" && <AppearanceSettings />}
                {activeTab === "Keycap" && <KeycapSettings />}
                {activeTab === "Mouse" && <MouseSettings />}
                {activeTab === "About" && <AboutPage />}
            </ScrollArea>
        </div>
    );
}

export default Settings;
