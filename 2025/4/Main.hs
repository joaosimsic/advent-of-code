main :: IO ()
main = do
    content <- readFile "input.txt"
    let x = filter (not . null) (lines content)
    print x
