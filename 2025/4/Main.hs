import qualified Data.Vector as V

main :: IO ()
main = do
    content <- readFile "2025/4/input.txt"
    let x = V.fromList $ filter (not . null) (lines content)
    print x
