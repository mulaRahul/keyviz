import { useKeyEvent } from "../stores/key_event";

export const Overlay = () => {
    const { pressedKeys, pressedMouseButton, mouse } = useKeyEvent();

    return <div>
        <div>Pressed Keys: {[...pressedKeys].join(" + ")}</div>
        <div>Pressed Mouse Button: {pressedMouseButton ?? "None"}</div>
        <div>Mouse Position: ({mouse.x}, {mouse.y})</div>
        <div>Mouse Wheel Delta: {mouse.wheel}</div>
    </div>;
}