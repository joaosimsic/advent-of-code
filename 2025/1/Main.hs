main :: IO ()
main = do
    content <- readFile "input.txt"
    let parsed = map parseInstruction (filter (not . null) (lines content))

    let (_, part1) = foldl movePart1 (50, 0) parsed
    let (_, part2) = foldl movePart2 (50, 0) parsed

    print part1
    print part2

parseInstruction :: String -> (Char, Int)
parseInstruction ('L' : amount) = ('L', read amount)
parseInstruction ('R' : amount) = ('R', read amount)

movePart1 :: (Int, Int) -> (Char, Int) -> (Int, Int)
movePart1 (position, count) (direction, amount) =
    let movement =
            if direction == 'L'
                then -amount
                else amount
        newPosition = (position + movement) `mod` 100
        newCount =
            if newPosition == 0
                then count + 1
                else count
     in (newPosition, newCount)

movePart2 :: (Int, Int) -> (Char, Int) -> (Int, Int)
movePart2 (position, count) (direction, amount) =
    let newPosition =
            if direction == 'L'
                then (position - amount) `mod` 100
                else (position + amount) `mod` 100
        crossing = zeroCrossing position (direction, amount)
     in (newPosition, count + crossing)

zeroCrossing :: Int -> (Char, Int) -> Int
zeroCrossing position (direction, amount)
    | direction == 'R' = (position + amount) `div` 100
    | position == 0 = amount `div` 100
    | amount < position = 0
    | otherwise = 1 + (amount - position) `div` 100
