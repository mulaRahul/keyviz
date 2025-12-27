'use client';
import * as React from 'react';
import { CheckIcon, XCircle, ChevronDown, XIcon } from 'lucide-react';

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
  CommandSeparator,
} from '@/components/ui/command';

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
  animation?: number;
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
      placeholder = 'Select options',
      animation = 0,
      maxCount = 3,
      modalPopover = false,
      asChild = false,
      className,
      popoverClass,
      showall = false,
      ...props
    },
    ref
  ) => {
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

    const handleTogglePopover = () => {
      setIsPopoverOpen((prev) => !prev);
    };

    const clearExtraOptions = () => {
      const newSelectedValues = selectedValues.slice(0, maxCount);
      setSelectedValues(newSelectedValues);
      onValueChange(newSelectedValues);
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
        {/* <PopoverTrigger asChild={asChild}> */}
        <PopoverTrigger>
          <Button
            // ref={ref}
            {...props}
            onClick={handleTogglePopover}
            className={cn(
              'flex w-full p-1 rounded-md border min-h-10 h-auto items-center justify-between bg-background hover:bg-background',
              className
            )}
          >
            {selectedValues.length > 0 ? (
              <div className='flex justify-between items-center w-full'>
                <div className='flex flex-wrap items-center  gap-1 p-1'>
                  {(showall
                    ? selectedValues
                    : selectedValues.slice(0, maxCount)
                  ).map((value) => {
                    const option = options.find((o) => o.value === value);
                    const IconComponent = option?.icon;
                    return (
                      <div
                        key={value}
                        className={cn(
                          'inline-flex items-center rounded-full border px-2 py-0.5 text-xs font-semibold  bg-primary text-primary-foreground  '
                        )}
                      >
                        {IconComponent && (
                          <IconComponent className='h-4 w-4 mr-2' />
                        )}
                        {option?.label}
                        <XCircle
                          className='ml-2 h-4 w-4 cursor-pointer'
                          onClick={(event) => {
                            event.stopPropagation();
                            toggleOption(value);
                          }}
                        />
                      </div>
                    );
                  })}
                  {!showall && selectedValues.length > maxCount && (
                    <div
                      className={cn(
                        'bg-primary-foreground inline-flex items-center border px-2 py-0.5  rounded-full text-foreground border-foreground/1 hover:bg-transparent'
                      )}
                      style={{ animationDuration: `${animation}s` }}
                    >
                      {`+ ${selectedValues.length - maxCount} more`}
                      <XCircle
                        className='ml-2 h-4 w-4 cursor-pointer'
                        onClick={(event) => {
                          event.stopPropagation();
                          clearExtraOptions();
                        }}
                      />
                    </div>
                  )}
                </div>
                <div className='flex items-center justify-between'>
                  <XIcon
                    className='h-4 mx-2 cursor-pointer text-muted-foreground'
                    onClick={(event) => {
                      event.stopPropagation();
                      handleClear();
                    }}
                  />
                  <ChevronDown className='h-4 mx-2 cursor-pointer text-muted-foreground' />
                </div>
              </div>
            ) : (
              <div className='flex items-center justify-between w-full mx-auto'>
                <span className='text-sm text-muted-foreground mx-3'>
                  {placeholder}
                </span>
                <ChevronDown className='h-4 cursor-pointer text-muted-foreground mx-2' />
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
              placeholder='Search...'
              onKeyDown={handleInputKeyDown}
            />
            <CommandList>
              <CommandEmpty>No results found.</CommandEmpty>
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
                  <span>(Select All)</span>
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
              <CommandSeparator />
              <CommandGroup>
                <div className='flex items-center justify-between'>
                  {selectedValues.length > 0 && (
                    <>
                      <CommandItem
                        onSelect={handleClear}
                        className='flex-1 justify-center cursor-pointer border-r'
                      >
                        Clear
                      </CommandItem>
                    </>
                  )}
                  <CommandItem
                    onSelect={() => setIsPopoverOpen(false)}
                    className='flex-1 justify-center cursor-pointer max-w-full'
                  >
                    Close
                  </CommandItem>
                </div>
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