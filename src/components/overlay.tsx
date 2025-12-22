import { useKeyEvent } from "../stores/key_event";

export const Overlay = () => {
    const { pressedKeys, pressedMouseButton, mouse, groups } = useKeyEvent();

    return <div>
        <div>Pressed Keys: {[...pressedKeys].join(" + ")}</div>
        <div>Pressed Mouse Button: {pressedMouseButton ?? "None"}</div>
        <div>Mouse Position: ({mouse.x}, {mouse.y})</div>
        <div>Mouse Wheel Delta: {mouse.wheel}</div>

        <ul>
            {groups.map((group, index) => (
                <li key={index}>
                    Group {index + 1}: {group.map(key => key.name).join(" + ")}
                </li>
            ))}
        </ul>
    </div>;
}