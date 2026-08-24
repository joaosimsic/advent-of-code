main :: IO ()
main = do
    content <- readFile "input.txt"
    let instructions = filter (not . null) (lines content)
    let parsed = map parseInstruction instructions

    let (_, part1) = foldl movePart1 (50, 0) parsed
    let (_, part2) = foldl movePart2 (50, 0) parsed

    print part1
    print part2

parseInstruction :: String -> Int
parseInstruction ('L' : amount) = -(read amount)
parseInstruction ('R' : amount) = read amount

movePart1 :: (Int, Int) -> Int -> (Int, Int)
movePart1 (position, count) amount =
    let newPosition = (position + amount) `mod` 100
        newCount =
            if newPosition == 0
                then count + 1
                else count
     in (newPosition, newCount)

movePart2 :: (Int, Int) -> Int -> (Int, Int)
movePart2 (position, count) amount =
    foldl step (position, count) (replicate (abs amount) direction)
  where
    direction = if amount < 0 then -1 else 1

    step (pos, count) dir =
        let newPosition = (pos + dir) `mod` 100
            newCount =
                if newPosition == 0
                    then count + 1
                    else count
         in (newPosition, newCount)
