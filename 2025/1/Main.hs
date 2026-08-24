main :: IO ()
main = do
    content <- readFile "input.txt"
    let parsed = map parseInstruction (filter (not . null) (lines content))

    let (_, part1) = foldl movePart1 (50, 0) parsed
    let (_, part2) = foldl movePart2 (50, 0) parsed

    print part1
    print part2

data Direction = L | R
    deriving (Show)

parseInstruction :: String -> (Direction, Int)
parseInstruction ('L' : amount) = (L, read amount)
parseInstruction ('R' : amount) = (R, read amount)

movePart1 :: (Int, Int) -> (Direction, Int) -> (Int, Int)
movePart1 (position, count) (L, amount) =
    let newPosition = (position - amount) `mod` 100
        newCount =
            if newPosition == 0
                then count + 1
                else count
     in (newPosition, newCount)
movePart1 (position, count) (R, amount) =
    let newPosition = (position + amount) `mod` 100
        newCount =
            if newPosition == 0
                then count + 1
                else count
     in (newPosition, newCount)

movePart2 :: (Int, Int) -> (Direction, Int) -> (Int, Int)
movePart2 (position, count) (L, amount) =
    let newPosition = (position - amount) `mod` 100
        crossing = zeroCrossing position L amount
     in (newPosition, count + crossing)
movePart2 (position, count) (R, amount) =
    let newPosition = (position + amount) `mod` 100
        crossing = zeroCrossing position R amount
     in (newPosition, count + crossing)

zeroCrossing :: Int -> Direction -> Int -> Int
zeroCrossing position R amount =
    (position + amount) `div` 100
zeroCrossing position L amount
    | position == 0 = amount `div` 100
    | amount < position = 0
    | otherwise = 1 + (amount - position) `div` 100
