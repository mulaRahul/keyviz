import { cn } from "@/lib/utils";
import { Alignment } from "@/types/style";
import { ArrowDown02Icon, ArrowDownLeftIcon, ArrowDownRightIcon, ArrowLeft02Icon, ArrowRight02Icon, ArrowUp02Icon, ArrowUpLeftIcon, ArrowUpRightIcon, PlusSignIcon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { useTranslation } from "react-i18next";


interface AlignmentSelectorProps {
    value: Alignment;
    onChange: (value: Alignment) => void;
    className?: string;
    disabledOptions?: Alignment[];
    iconStrokeWidth?: number;
}

const AlignmentSelector: React.FC<AlignmentSelectorProps> = ({ value, onChange, className, disabledOptions = [], iconStrokeWidth = 2 }) => {
    const { t } = useTranslation();

    const items = [
        { value: 'top-left' as Alignment, icon: ArrowUpLeftIcon, },
        { value: 'top-center' as Alignment, icon: ArrowUp02Icon, },
        { value: 'top-right' as Alignment, icon: ArrowUpRightIcon, },
        { value: 'center-left' as Alignment, icon: ArrowLeft02Icon, },
        { value: 'center' as Alignment, icon: PlusSignIcon, },
        { value: 'center-right' as Alignment, icon: ArrowRight02Icon, },
        { value: 'bottom-left' as Alignment, icon: ArrowDownLeftIcon, },
        { value: 'bottom-center' as Alignment, icon: ArrowDown02Icon, },
        { value: 'bottom-right' as Alignment, icon: ArrowDownRightIcon, }
    ]

    return (
        <div className={cn("p-2 bg-background border border-primary/20 rounded-xl w-fit", className)}>
            <div className="w-full h-full grid grid-cols-3 grid-rows-3 gap-2">
                {items.map(({ value: pos, icon }) => {
                    const isSelected = value === pos;
                    const position = pos.split('-').map(part => part[0].toUpperCase() + part.slice(1)).join(' ');
                    return (
                        disabledOptions?.includes(pos) ? <div key={pos}/> :
                            <button
                                key={pos}
                                onClick={() => onChange(pos)}
                                title={t(position)}
                                aria-label={t("Align {{position}}", { position: t(position) })}
                                aria-pressed={isSelected}
                                className={`
                  relative rounded-md transition-all duration-200 ease-in-out
                  ${isSelected
                                        ? "bg-primary/10 scale-105"  // Active State
                                        : "hover:bg-primary/25" // Inactive State
                                    }
                `}
                            >
                                {isSelected
                                    ? <HugeiconsIcon icon={icon} size="1em" strokeWidth={iconStrokeWidth ?? 2} className="m-auto text-primary" />
                                    : <span className="absolute inset-0 m-auto w-1 h-1 bg-secondary rounded-full opacity-80" />
                                }
                            </button>
                    );
                })}
            </div>
        </div>
    );
};

export { AlignmentSelector };

