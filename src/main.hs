import Text.Megaparsec
import Text.Megaparsec.String
import System.Environment
import Data.List

pragma = "React.createElement"

main = do
    fileName <- fmap head getArgs
    fileContents <- readFile fileName
    parseTest node fileContents

cr :: Parser [Char]
cr = many (oneOf "\r\n")

tok :: String -> Parser String
tok t = string t <* whitespace

whitespace :: Parser ()
whitespace = many (oneOf " \t\n") *> pure ()

node :: Parser String
node = try (jsx)
    <|> textString

jsx :: Parser String
jsx = do
    tok "<"
    tagName <- some alphaNumChar <* whitespace
    attrs <- attr <* whitespace
    tok ">"
    childArr <- manyTill (node) (tok ("</" ++ tagName ++ ">"))
    return $ concat [pragma, "(", tagName, ",", stringifyAttributes attrs, ",", flattenChildren childArr, ")"]

stringifyAttribute :: AttrPair -> String
stringifyAttribute (n ,v) = n ++ ":" ++ v

stringifyAttributes :: Attributes -> String
stringifyAttributes [] = "null"
stringifyAttributes as = "{" ++ intercalate "," (map stringifyAttribute as) ++ "}"

flattenChildren :: [String] -> String
flattenChildren childArr = intercalate "," childArr

type AttrName = String
type AttrValue = String
type AttrPair = (AttrName, AttrValue)
type Attributes = [AttrPair]

attrName :: Parser AttrName
attrName = manyTill letterChar (tok "=")

attrValue :: Parser AttrValue
attrValue = tok "\"" *> manyTill (alphaNumChar <|> oneOf "-") (tok "\"")

attr :: Parser Attributes
attr = attr' `sepEndBy` whitespace
    where
    attr' = (,) <$> attrName <*> attrValue <* whitespace

textString :: Parser String
textString = whitespace *> many (alphaNumChar <|> oneOf " \t\r\n") <* whitespace

parseFile :: FilePath -> IO ()
parseFile filePath = do
  file <- readFile filePath
  putStrLn $ case runParser node filePath file of
      Left err -> parseErrorPretty err
      Right x -> x
