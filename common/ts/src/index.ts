export async function fetchInput(year: number, day: number): Promise<string> {
  const response = await fetch(`http://localhost:8080/input/${year}/${day}`);
  return response.text();
}

export function readStdin(): Promise<string> {
  return Bun.stdin.text();
}
