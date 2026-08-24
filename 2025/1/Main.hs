main :: IO ()
main = do
  content <- readFile "input.txt"
  let instructions = lines content
  print instructions
