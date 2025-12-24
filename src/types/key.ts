export class Key {
    name: string;
    pressedCount: number;
    lastPressedAt: number;

    constructor(name: string) {
        this.name = name;
        this.pressedCount = 1;
        this.lastPressedAt = Date.now();
    }

    press() {
        this.pressedCount += 1;
        this.lastPressedAt = Date.now();
    }

    in(set: string[]): boolean {
        return set.includes(this.name);
    }
}