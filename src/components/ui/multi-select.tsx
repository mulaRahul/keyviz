'use client';
import * as React from 'react';
import { CheckIcon, ChevronDown } from 'lucide-react';

import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from '@/components/ui/popover';
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from '@/components/ui/command';
import { useTranslation } from 'react-i18next'
import i18next from 'i18next'

interface MultiSelectProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  options: {
    label: string;
    value: string;
    icon?: React.ComponentType<{ className?: string }>;
    disable?: boolean;
  }[];
  onValueChange: (value: string[]) => void;
  defaultValue?: string[];
  placeholder?: string;
  maxCount?: number;
  modalPopover?: boolean;
  asChild?: boolean;
  className?: string;
  popoverClass?: string;
  showall?: boolean;
}

const MultiSelect = React.forwardRef<
  HTMLButtonElement,
  MultiSelectProps
>(
  (
    {
      options,
      onValueChange,
      defaultValue = [],
      placeholder = i18next.t('selectOptions', 'Select options'),
      maxCount = 3,
      modalPopover = false,
      className,
      popoverClass,
      showall = false,
      ...props
    },
    _
  ) => {
    const { t } = useTranslation()
    const [selectedValues, setSelectedValues] =
      React.useState<string[]>(defaultValue);
    const [isPopoverOpen, setIsPopoverOpen] = React.useState(false);

    const handleInputKeyDown = (
      event: React.KeyboardEvent<HTMLInputElement>
    ) => {
      if (event.key === 'Enter') {
        setIsPopoverOpen(true);
      } else if (event.key === 'Backspace' && !event.currentTarget.value) {
        const newSelectedValues = [...selectedValues];
        newSelectedValues.pop();
        setSelectedValues(newSelectedValues);
        onValueChange(newSelectedValues);
      }
    };

    const toggleOption = (option: string) => {
      const newSelectedValues = selectedValues.includes(option)
        ? selectedValues.filter((value) => value !== option)
        : [...selectedValues, option];
      setSelectedValues(newSelectedValues);
      onValueChange(newSelectedValues);
    };

    const handleClear = () => {
      setSelectedValues([]);
      onValueChange([]);
    };

    const filteredOptions = options.filter((option) => !option.disable);
    const toggleAll = () => {
      if (selectedValues.length === filteredOptions.length) {
        handleClear();
      } else {
        const allValues = filteredOptions.map((option) => option.value);
        setSelectedValues(allValues);
        onValueChange(allValues);
      }
    };

    return (
      <Popover
        open={isPopoverOpen}
        onOpenChange={setIsPopoverOpen}
        modal={modalPopover}
      >
        {/* The trigger has to be the button itself (asChild): wrapping one
            button inside another made every click toggle the popover twice, so
            it never stayed open. */}
        <PopoverTrigger asChild>
          <Button
            // ref={ref}
            {...props}
            className={cn(
              'flex w-full p-1 rounded-md border min-h-9 h-auto items-start justify-between gap-1 overflow-hidden bg-background hover:bg-background',
              className
            )}
          >
            {selectedValues.length > 0 ? (
              <>
                <div className='flex min-w-0 flex-1 flex-col items-stretch gap-1 py-0.5'>
                  {(showall
                    ? selectedValues
                    : selectedValues.slice(0, maxCount)
                  ).map((value) => {
                    const option = options.find((o) => o.value === value);
                    const IconComponent = option?.icon;
                    return (
                      <div
                        key={value}
                        className='flex h-7 w-full min-w-0 items-center gap-2 rounded-md border border-border bg-background px-2 text-xs font-medium text-foreground'
                      >
                        {IconComponent && (
                          <IconComponent className='h-4 w-4 shrink-0' />
                        )}
                        <span className='truncate'>{option?.label}</span>
                      </div>
                    );
                  })}
                  {!showall && selectedValues.length > maxCount && (
                    <div className='flex h-7 w-full items-center rounded-md border border-border bg-background px-2 text-xs text-muted-foreground'>
                      {t('valMore', '+ {{val}} more', { val: selectedValues.length - maxCount })}
                    </div>
                  )}
                </div>
                <ChevronDown className='mt-2 h-4 w-4 shrink-0 text-muted-foreground' />
              </>
            ) : (
              <div className='flex w-full items-center justify-between'>
                <span className='mx-3 text-sm text-muted-foreground'>
                  {placeholder}
                </span>
                <ChevronDown className='mx-2 h-4 w-4 text-muted-foreground' />
              </div>
            )}
          </Button>
        </PopoverTrigger>
        <PopoverContent
          className={cn('w-auto p-0', popoverClass)}
          align='start'
        //   onEscapeKeyDown={() => setIsPopoverOpen(false)}
        >
          <Command>
            <CommandInput
              placeholder={t('search', 'Search...')}
              onKeyDown={handleInputKeyDown}
            />
            <CommandList>
              <CommandEmpty>{t('noResultsFound', 'No results found.')}</CommandEmpty>
              <CommandGroup>
                <CommandItem
                  key='all'
                  onSelect={toggleAll}
                  className='cursor-pointer'
                >
                  <div
                    className={cn(
                      'mr-2 flex h-4 w-4 items-center justify-center rounded-sm border border-primary',
                      selectedValues.length === filteredOptions.length
                        ? 'bg-primary text-primary-foreground'
                        : 'opacity-50 [&_svg]:invisible'
                    )}
                  >
                    <CheckIcon className='h-4 w-4' />
                  </div>
                  <span>{t('selectAll', '(Select All)')}</span>
                </CommandItem>
                {options.map((option) => {
                  const isSelected = selectedValues.includes(option.value);
                  const isDisabled = option.disable; 

                  return (
                    <CommandItem
                      key={option.value}
                      onSelect={() => !isDisabled && toggleOption(option.value)}
                      className={cn(
                        'cursor-pointer',
                        isDisabled && 'opacity-50 cursor-not-allowed'
                      )}
                    >
                      <div
                        className={cn(
                          'mr-2 flex h-4 w-4 items-center justify-center rounded-sm border border-primary',
                          isSelected
                            ? 'bg-primary text-primary-foreground'
                            : 'opacity-50 [&_svg]:invisible'
                        )}
                      >
                        {!isDisabled && <CheckIcon className='h-4 w-4' />}
                      </div>
                      {option.icon && (
                        <option.icon
                          className={cn(
                            'mr-2 h-4 w-4',
                            isDisabled ? 'text-muted-foreground' : ''
                          )}
                        />
                      )}
                      <span>{option.label}</span>
                    </CommandItem>
                  );
                })}
              </CommandGroup>
            </CommandList>
          </Command>
        </PopoverContent>
      </Popover>
    );
  }
);

MultiSelect.displayName = 'MultiSelect';

export default MultiSelect;