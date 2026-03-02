import { useKeyEvent } from "@/stores/key_event";
import { useKeyStyle } from "@/stores/key_style";
import { JSX } from "react";


const mouseIcons: Record<string, JSX.Element> = {
    Default: (
        <svg className="w-full h-full" width="33" height="43" viewBox="0 0 33 43" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M16.5 9.5V1.5" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
            <path d="M16.5 41.5C28.5 41.5 31.5 32.48 31.5 21.5C31.5 10.52 28.5 1.5 16.5 1.5C4.49986 1.5 1.5 10.5199 1.5 21.5C1.5 32.48 4.49986 41.5 16.5 41.5Z" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
            <path d="M13.5 12.5C13.5 11.5681 13.5 11.1022 13.6522 10.7346C13.8552 10.2446 14.2446 9.85522 14.7346 9.65224C15.1022 9.5 15.5682 9.5 16.5 9.5C17.4318 9.5 17.8978 9.5 18.2654 9.65224C18.7554 9.85522 19.1448 10.2446 19.3478 10.7346C19.5 11.1022 19.5 11.5681 19.5 12.5V16.5C19.5 17.4319 19.5 17.8978 19.3478 18.2654C19.1448 18.7554 18.7554 19.1448 18.2654 19.3478C17.8978 19.5 17.4318 19.5 16.5 19.5C15.5682 19.5 15.1022 19.5 14.7346 19.3478C14.2446 19.1448 13.8552 18.7554 13.6522 18.2654C13.5 17.8978 13.5 17.4319 13.5 16.5V12.5Z" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
        </svg>

    ),
    Left: (
        <svg className="w-full h-full" width="37" height="43" viewBox="0 0 37 43" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M15.5 2.13688C16.9612 1.72134 18.6202 1.5 20.5 1.5C32.5 1.5 35.5 10.52 35.5 21.5C35.5 32.48 32.5 41.5 20.5 41.5C8.49986 41.5 5.5 32.48 5.5 21.5C5.5 20.4812 5.52582 19.4794 5.58226 18.5" stroke="white" stroke-width="3" stroke-linecap="round" />
            <path d="M6.5 13.5C9.26142 13.5 11.5 11.2614 11.5 8.5C11.5 5.73858 9.26142 3.5 6.5 3.5C3.73858 3.5 1.5 5.73858 1.5 8.5C1.5 11.2614 3.73858 13.5 6.5 13.5Z" stroke="#00FF6A" stroke-width="3" stroke-linecap="round" />
            <path d="M20.5 9.5V1.5" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
            <path d="M17.5 12.5C17.5 11.5681 17.5 11.1022 17.6522 10.7346C17.8552 10.2446 18.2446 9.85522 18.7346 9.65224C19.1022 9.5 19.5682 9.5 20.5 9.5C21.4318 9.5 21.8978 9.5 22.2654 9.65224C22.7554 9.85522 23.1448 10.2446 23.3478 10.7346C23.5 11.1022 23.5 11.5681 23.5 12.5V16.5C23.5 17.4319 23.5 17.8978 23.3478 18.2654C23.1448 18.7554 22.7554 19.1448 22.2654 19.3478C21.8978 19.5 21.4318 19.5 20.5 19.5C19.5682 19.5 19.1022 19.5 18.7346 19.3478C18.2446 19.1448 17.8552 18.7554 17.6522 18.2654C17.5 17.8978 17.5 17.4319 17.5 16.5V12.5Z" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
    ),
    Middle: (
        <svg className="w-full h-full" width="33" height="43" viewBox="0 0 33 43" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M16.5 9.5V1.5" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
            <path d="M16.5 41.5C28.5 41.5 31.5 32.48 31.5 21.5C31.5 10.52 28.5 1.5 16.5 1.5C4.49986 1.5 1.5 10.5199 1.5 21.5C1.5 32.48 4.49986 41.5 16.5 41.5Z" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
            <path d="M13.5 12.5C13.5 11.5681 13.5 11.1022 13.6522 10.7346C13.8552 10.2446 14.2446 9.85522 14.7346 9.65224C15.1022 9.5 15.5682 9.5 16.5 9.5C17.4318 9.5 17.8978 9.5 18.2654 9.65224C18.7554 9.85522 19.1448 10.2446 19.3478 10.7346C19.5 11.1022 19.5 11.5681 19.5 12.5V16.5C19.5 17.4319 19.5 17.8978 19.3478 18.2654C19.1448 18.7554 18.7554 19.1448 18.2654 19.3478C17.8978 19.5 17.4318 19.5 16.5 19.5C15.5682 19.5 15.1022 19.5 14.7346 19.3478C14.2446 19.1448 13.8552 18.7554 13.6522 18.2654C13.5 17.8978 13.5 17.4319 13.5 16.5V12.5Z" stroke="#00FF6A" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
    ),
    Right: (
        <svg className="w-full h-full" width="37" height="43" viewBox="0 0 37 43" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M21.5 2.13688C20.0388 1.72134 18.3798 1.5 16.5 1.5C4.5 1.5 1.5 10.52 1.5 21.5C1.5 32.48 4.5 41.5 16.5 41.5C28.5002 41.5 31.5 32.48 31.5 21.5C31.5 20.4812 31.4742 19.4794 31.4178 18.5" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
            <path d="M30.5 13.5C33.2614 13.5 35.5 11.2614 35.5 8.5C35.5 5.73858 33.2614 3.5 30.5 3.5C27.7386 3.5 25.5 5.73858 25.5 8.5C25.5 11.2614 27.7386 13.5 30.5 13.5Z" stroke="#00FF6A" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
            <path d="M16.5 9.5V1.5" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
            <path d="M13.5 12.5C13.5 11.5681 13.5 11.1022 13.6522 10.7346C13.8552 10.2446 14.2446 9.85522 14.7346 9.65224C15.1022 9.5 15.5682 9.5 16.5 9.5C17.4318 9.5 17.8978 9.5 18.2654 9.65224C18.7554 9.85522 19.1448 10.2446 19.3478 10.7346C19.5 11.1022 19.5 11.5681 19.5 12.5V16.5C19.5 17.4319 19.5 17.8978 19.3478 18.2654C19.1448 18.7554 18.7554 19.1448 18.2654 19.3478C17.8978 19.5 17.4318 19.5 16.5 19.5C15.5682 19.5 15.1022 19.5 14.7346 19.3478C14.2446 19.1448 13.8552 18.7554 13.6522 18.2654C13.5 17.8978 13.5 17.4319 13.5 16.5V12.5Z" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
    ),
    ScrollDown: (
        <svg className="w-full h-full" width="33" height="43" viewBox="0 0 33 43" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M16.5 41.5C28.5 41.5 31.5 32.48 31.5 21.5C31.5 10.52 28.5 1.5 16.5 1.5C4.49986 1.5 1.5 10.5199 1.5 21.5C1.5 32.48 4.49986 41.5 16.5 41.5Z" stroke="white" stroke-width="3" />
            <path d="M16.4766 11.1772V21.0173" stroke="#00FF6A" stroke-width="3" stroke-linecap="round" />
            <path d="M20.5082 19.7812C18.5402 21.8212 17.3402 23.6212 16.4282 23.4918C15.6602 23.4982 14.9402 22.3012 12.4922 19.7812" stroke="#00FF6A" stroke-width="3" stroke-linecap="round" />
        </svg>
    ),
    ScrollUp: (
        <svg className="w-full h-full" width="33" height="43" viewBox="0 0 33 43" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M16.5 41.5C28.5 41.5 31.5 32.48 31.5 21.5C31.5 10.52 28.5 1.5 16.5 1.5C4.49986 1.5 1.5 10.5199 1.5 21.5C1.5 32.48 4.49986 41.5 16.5 41.5Z" stroke="white" stroke-width="3" />
            <path d="M16.4766 11.1772V21.0173" stroke="#00FF6A" stroke-width="3" stroke-linecap="round" />
            <path d="M12.4922 13.2172C14.4602 11.1772 15.6602 9.37719 16.5722 9.50657C17.3402 9.50019 18.0602 10.6972 20.5082 13.2172" stroke="#00FF6A" stroke-width="3" stroke-linecap="round" />
        </svg>
    )
};
export const MouseIndicator = () => {
    const pressedButton = useKeyEvent(state => state.pressedMouseButton);
    const wheel = useKeyEvent(state => state.mouse.wheel);
    const style = useKeyStyle(state => state.mouse);

    let icon = "Default";

    if (pressedButton && mouseIcons[pressedButton]) {
        icon = pressedButton;
    } else if (wheel > 0) {
        icon = "ScrollUp";
    } else if (wheel < 0) {
        icon = "ScrollDown";
    }

    return (
        <div
            className="bg-black/50 text-white"
            style={{
                width: style.indicatorSize * 0.92,
                height: style.indicatorSize,
                marginTop: style.indicatorOffsetY,
                marginLeft: style.indicatorOffsetX,
                borderRadius: "45%",
                padding: style.indicatorSize * 0.2,
            }}
        >
            {mouseIcons[icon]}
        </div>
    );
}