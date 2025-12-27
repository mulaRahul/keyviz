
import { Item, ItemActions, ItemContent, ItemDescription, ItemTitle } from "@/components/ui/item";
import { Switch } from "@/components/ui/switch";
import { CommandIcon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "../ui/accordion";
import { NumberInput } from "../ui/number-input";
import { ToggleGroup, ToggleGroupItem } from "../ui/toggle-group";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "../ui/select";
import { useKeyStyle } from "@/stores/key_style";
import { ColorInput } from "../ui/color-input";

export const KeycapSettings = () => {

    const text = useKeyStyle(state => state.text);
    const setTextStyle = useKeyStyle(state => state.setText);

    const modifier = useKeyStyle(state => state.modifier);
    const setModifierStyle = useKeyStyle(state => state.setModifier);

    return <div className="flex flex-col gap-y-4 p-6 pb-10">
        <Accordion type="multiple" className="w-full">
            <AccordionItem value="text">
                <AccordionTrigger>Text</AccordionTrigger>
                <AccordionContent className="h-fit flex flex-col gap-4">
                    <div className="flex flex-col gap-4 md:flex-row">
                        <Item variant="muted" className="flex-2">
                            <ItemContent>
                                <ItemTitle>Size</ItemTitle>
                            </ItemContent>
                            <ItemActions>
                                <NumberInput
                                    value={text.size}
                                    onChange={(value) => setTextStyle({ size: value })} minValue={8}
                                    className="w-24 h-8"
                                />
                            </ItemActions>
                        </Item>
                        <div className="flex gap-4 flex-4">
                            <Item variant="muted" className="flex-2">
                                <ItemContent>
                                    <ItemTitle>Modifier</ItemTitle>
                                </ItemContent>
                                <ItemActions>
                                    <Select value={modifier.textVariant} onValueChange={(value) => setModifierStyle({ textVariant: value as any })}>
                                        <SelectTrigger>
                                            <SelectValue placeholder="text variant" />
                                        </SelectTrigger>
                                        <SelectContent>
                                            <SelectItem value="text-short">Short Text</SelectItem>
                                            <SelectItem value="text">Full Text</SelectItem>
                                            <SelectItem value="icon">Icon Only</SelectItem>
                                        </SelectContent>
                                    </Select>

                                </ItemActions>
                            </Item>
                            <ToggleGroup
                                type="single"
                                value={text.caps} onValueChange={(value) => setTextStyle({ caps: value as 'uppercase' | 'title' | 'lowercase' })}
                            >
                                <ToggleGroupItem variant="outline" className="h-full w-10" value="uppercase">AA</ToggleGroupItem>
                                <ToggleGroupItem variant="outline" className="h-full w-10" value="title">Aa</ToggleGroupItem>
                                <ToggleGroupItem variant="outline" className="h-full w-10" value="lowercase">aa</ToggleGroupItem>
                            </ToggleGroup>
                        </div>
                    </div>
                    <div className="flex gap-4">
                        <Item variant="muted" className="flex-2">
                            <ItemContent>
                                <ItemTitle>Color</ItemTitle>
                            </ItemContent>
                            <ItemActions>
                                <ColorInput value={text.color} onChange={(color) => setTextStyle({ color })} />
                            </ItemActions>
                        </Item>
                        {
                            modifier.highlight &&
                            <Item variant="muted" className="flex-2">
                                <ItemContent>
                                    <ItemTitle>Modifier Color</ItemTitle>
                                </ItemContent>
                                <ItemActions>
                                    Color Picker
                                </ItemActions>
                            </Item>
                        }
                    </div>
                </AccordionContent>
            </AccordionItem>

            <AccordionItem value="layout">
                <AccordionTrigger>Layout</AccordionTrigger>
                <AccordionContent className="flex flex-col gap-4 text-balance">
                    <p>
                        We offer worldwide shipping through trusted courier partners.
                        Standard delivery takes 3-5 business days, while express shipping
                        ensures delivery within 1-2 business days.
                    </p>
                    <p>
                        All orders are carefully packaged and fully insured. Track your
                        shipment in real-time through our dedicated tracking portal.
                    </p>
                </AccordionContent>
            </AccordionItem>

            <AccordionItem value="border">
                <AccordionTrigger>Border</AccordionTrigger>
                <AccordionContent className="flex flex-col gap-4 text-balance">
                    <p>
                        We stand behind our products with a comprehensive 30-day return
                        policy. If you&apos;re not completely satisfied, simply return the
                        item in its original condition.
                    </p>
                    <p>
                        Our hassle-free return process includes free return shipping and
                        full refunds processed within 48 hours of receiving the returned
                        item.
                    </p>
                </AccordionContent>
            </AccordionItem>

            <AccordionItem value="background">
                <AccordionTrigger>Background</AccordionTrigger>
                <AccordionContent className="flex flex-col gap-4 text-balance">
                    <p>
                        We stand behind our products with a comprehensive 30-day return
                        policy. If you&apos;re not completely satisfied, simply return the
                        item in its original condition.
                    </p>
                    <p>
                        Our hassle-free return process includes free return shipping and
                        full refunds processed within 48 hours of receiving the returned
                        item.
                    </p>
                </AccordionContent>
            </AccordionItem>
        </Accordion>
    </div>;
}