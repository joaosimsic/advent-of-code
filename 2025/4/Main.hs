import qualified Data.Vector as V

type Grid = V.Vector (V.Vector Char)

parseGrid :: String -> Grid
parseGrid s =
    V.fromList
        . map V.fromList
        . filter (not . null)
        $ lines s

coordinates :: Grid -> [(Int, Int)]
coordinates grid =
    [ (row, col)
    | row <- [0 .. V.length grid - 1]
    , col <- [0 .. V.length (grid V.! 0) - 1]
    ]

main :: IO ()
main = do
    content <- readFile "2025/4/input.txt"
    let grid = parseGrid content
    print $ V.length grid
    print $ V.length (grid V.! 0)
