import { useI18n } from "@/i18n";
import { LanguagePreference, useKeyStyle } from "@/stores/key_style";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

export const LanguageSelect = () => {
  const appearance = useKeyStyle((state) => state.appearance);
  const setAppearance = useKeyStyle((state) => state.setAppearance);
  const { systemLocale, t } = useI18n();

  const systemLabel = systemLocale
    ? `${t("System", "跟随系统")} (${systemLocale})`
    : t("System", "跟随系统");

  return (
    <Select
      value={appearance.language}
      onValueChange={(language) => setAppearance({ language: language as LanguagePreference })}
    >
      <SelectTrigger className="w-40">
        <SelectValue />
      </SelectTrigger>
      <SelectContent>
        <SelectItem value="system">{systemLabel}</SelectItem>
        <SelectItem value="en">English</SelectItem>
        <SelectItem value="zh-CN">中文</SelectItem>
      </SelectContent>
    </Select>
  );
};
