import { cn } from "@/lib/utils";
import { HugeiconsIcon, IconSvgElement } from "@hugeicons/react";

export const SidebarItem = ({ item, isActive, className }: { item: { title: string; icon: IconSvgElement }, isActive: boolean, className?: string }) => {
    return (
        <div 
            key={item.title} 
            className={cn(
                "p-2 flex items-center gap-x-2 text-sm text-muted-foreground hover:bg-primary/10 rounded-md transition-colors", 
                isActive && "text-sidebar-foreground bg-sidebar",
                className
            )}
        >
            <HugeiconsIcon icon={item.icon} size="1.1em" strokeWidth={isActive ? 2.5 : 2} /><span>{item.title}</span>
        </div>
    );
}