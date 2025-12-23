import { AnimatePresence, motion } from "motion/react";
import { useKeyEvent } from "../stores/key_event";

const variants = {
    visible: { opacity: 1, y: 0 },
    hidden: { opacity: 0, y: 10 }
};

export const Overlay = () => {
    const { pressedKeys, pressedMouseButton, mouse, groups } = useKeyEvent();

    return <div>
        <div>Pressed Keys: {[...pressedKeys].join(" + ")}</div>
        <div>Pressed Mouse Button: {pressedMouseButton ?? "None"}</div>
        <div>Mouse Position: ({mouse.x}, {mouse.y})</div>
        <div>Mouse Wheel Delta: {mouse.wheel}</div>

        <div className="container">
            {/* {groups.map((group, index) => (
                <li key={index}>
                    Group {index + 1}: {group.map(key => key.name).join(" + ")}
                </li>
            ))} */}
            <AnimatePresence>{
                groups.map((group, index) => (
                    <motion.div
                        key={index}
                        className="keygroup"
                        variants={variants}
                        initial="hidden"
                        animate="visible"
                        exit="hidden"
                        transition={{ duration: 0.2 }}
                    >
                        <AnimatePresence>{
                            group.map(key => (
                                <motion.div 
                                    key={key.name} 
                                    variants={variants} 
                                    initial="hidden" 
                                    animate="visible" 
                                    exit="hidden" 
                                    transition={{ duration: 0.2 }} 
                                    className="keycap"
                                >
                                    {key.name}
                                </motion.div>
                            ))
                        }</AnimatePresence>
                    </motion.div>
                ))   
            }</AnimatePresence>
        </div>
    </div>;
}