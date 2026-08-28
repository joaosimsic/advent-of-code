import qualified Data.Set as S

type Position = (Int, Int)
type Grid = S.Set Position

parseGrid :: String -> Grid
parseGrid s =
    S.fromList
        [ (row, col)
        | (row, line) <- zip [0 ..] (lines s)
        , (col, char) <- zip [0 ..] line
        , char == '@'
        ]

directions :: [Position]
directions =
    [ (dr, dc)
    | dr <- [-1, 0, 1]
    , dc <- [-1, 0, 1]
    , (dr, dc) /= (0, 0)
    ]

atNeighbors :: Grid -> Position -> Int
atNeighbors grid (row, col) =
    length
        [ ()
        | (dr, dc) <- directions
        , S.member (row + dr, col + dc) grid
        ]

accessible :: Grid -> [Position]
accessible grid =
    [ position
    | position <- S.toList grid
    , atNeighbors grid position <= 3
    ]

main :: IO ()
main = do
    content <- readFile "2025/4/input.txt"
    let grid = parseGrid content
        result = accessible grid

    print $ length result
