import { AppearanceSettings, GeneralSettings, KeycapSettings } from "@/components/settings";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Separator } from "@/components/ui/separator";
import { SidebarItem } from "@/components/ui/sidebar-item";
import { ComputerIcon, InformationSquareIcon, KeyboardIcon, Mouse09Icon, Settings03Icon } from "@hugeicons/core-free-icons";
import { useState } from "react";


const sideBar = [
    { title: "General", icon: Settings03Icon },
    { title: "Appearance", icon: ComputerIcon },
    { title: "Keycap", icon: KeyboardIcon },
    { title: "Mouse", icon: Mouse09Icon },
]

const Settings = () => {
    const [activeTab, setActiveTab] = useState(sideBar[0].title);

    return (
        <div className="flex w-screen h-screen overflow-hidden">
            <div className="w-48 p-2 flex flex-col gap-y-1 rounded-xl">
                <div className="flex items-center m-2 mb-2 gap-x-2">
                    <img src="./tauri.svg" alt="logo" className="w-8 h-8" />
                    <div className="flex flex-col gap-y-1">
                        <h1 className="text-sm font-semibold">Keyviz</h1>
                        <p className="text-xs text-gray-400">v2.0.4a</p>
                    </div>
                </div>
                {
                    sideBar.map((item) => (
                        <a href="#" key={item.title} onClick={() => setActiveTab(item.title)}>
                            <SidebarItem item={item} isActive={activeTab === item.title} />
                        </a>
                    ))
                }
                <a href="#" key="about" onClick={() => setActiveTab("About")} className="mt-auto">
                    <SidebarItem item={{ title: "About", icon: InformationSquareIcon }} isActive={activeTab === "About"} />
                </a>
            </div>
            <Separator orientation="vertical" />
            <ScrollArea className="flex-1 relative">
                {
                    activeTab === "General" && <GeneralSettings />
                }
                {
                    activeTab === "Appearance" && <AppearanceSettings />
                }
                {
                    activeTab === "Keycap" && <KeycapSettings />
                }
            </ScrollArea>
        </div>
    );
}

export default Settings;