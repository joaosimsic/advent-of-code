main :: IO ()
main = do
    content <- readFile "input.txt"
    let instructions = filter (not . null) (lines content)
    let parsed = map parseInstruction instructions
    let (finalPosition, zeroCount) = foldl move (50, 0) parsed
    print zeroCount

parseInstruction :: String -> Int
parseInstruction ('L' : amount) = -(read amount)
parseInstruction ('R' : amount) = read amount

move :: (Int, Int) -> Int -> (Int, Int)
move (position, count) amount =
    let newPosition = (position + amount) `mod` 100
        newCount =
            if newPosition == 0
                then count + 1
                else count
     in (newPosition, newCount)
