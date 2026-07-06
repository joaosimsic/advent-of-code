import axios from "axios";

type Direction = "L" | "R";

interface Instruction {
    direction: Direction;
    amount: number;
}

type Pos<N extends number, Acc extends number[] = []> = Acc["length"] extends N
    ? Acc[number]
    : Pos<N, [...Acc, Acc["length"]]>;

type DialPos = Pos<100>;

const fetchInput = async (): Promise<string> => {
    const response = await axios.get<string>(
        "http://localhost:8080/input/2025/1",
    );

    return response.data;
};

const isDirection = (char: string): char is Direction => {
    return char === "L" || char === "R";
};

const extractInstructions = (list: string[]): Instruction[] => {
    let instructions: Instruction[] = [];

    list.forEach((s) => {
        const cleaned = s.trim();

        if (cleaned.length === 0) return;

        const direction: string = cleaned.charAt(0);

        if (!isDirection(direction)) throw Error("Invalid direction char");

        const amount = parseInt(cleaned.slice(1), 10);

        instructions.push({ direction, amount });
    });

    return instructions;
};

const safeMod = (n: number, m: number): DialPos => {
    return (((n % m) + m) % m) as DialPos;
};

const doInstruction = (dial: DialPos, i: Instruction): DialPos => {
    if (i.direction === "L") {
        return safeMod(dial + i.amount, 100);
    }

    return safeMod(dial - i.amount, 100);
};

const main = async () => {
    let dial: DialPos = 50;

    let atZeroTimes = 0;

    const input = await fetchInput();

    const inputList: string[] = input.split("\n");

    const instructions = extractInstructions(inputList);

    instructions.forEach((i) => {
        dial = doInstruction(dial, i);

        if (dial === 0) atZeroTimes++;
    });

    console.log(atZeroTimes);
};

main();

