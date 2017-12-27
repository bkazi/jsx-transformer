import Text.Megaparsec
import Text.Megaparsec.String
import System.Environment
import Data.List
import Data.Char

pragma = "React.createElement"

printPragma :: String -> Attributes -> [String] -> String
printPragma tagName [] [] = concat [pragma, "(", tagName, ")"]
printPragma tagName attrs [] = concat [pragma, "(", correctTagName tagName, ",", stringifyAttributes attrs, ")"]
printPragma tagName attrs childArr = concat [pragma, "(", correctTagName tagName, ",", stringifyAttributes attrs, ",", flattenChildren childArr, ")"]

correctTagName :: String -> String
correctTagName tagName = if isLower (head tagName)
    then "\"" ++ tagName ++ "\""
    else tagName

stringifyAttribute :: AttrPair -> String
stringifyAttribute (n ,v) = n ++ ":" ++ v

stringifyAttributes :: Attributes -> String
stringifyAttributes [] = "null"
stringifyAttributes as = "{" ++ intercalate "," (map stringifyAttribute as) ++ "}"

flattenChildren :: [String] -> String
flattenChildren childArr = intercalate "," childArr

main = do
    filePath <- fmap head getArgs
    file <- readFile filePath
    putStrLn $ case runParser node filePath file of
        Left err -> parseErrorPretty err 
        Right x -> x

cr :: Parser [Char]
cr = many (oneOf "\r\n")

tok :: String -> Parser String
tok t = string t <* whitespace

whitespace :: Parser ()
whitespace = many (oneOf " \t\n") *> pure ()

node :: Parser String
node = do
        e <- eitherP jsx anyChar
        let x = either (\s -> s) (\c -> [c]) e
        rest <- node
        return $ x ++ rest
    <|> eof *> pure ""

jsx :: Parser String
jsx = try (multiTag) <|> selfClosing

selfClosing :: Parser String
selfClosing = do
    tok "<"
    tagName <- some alphaNumChar <* whitespace
    attrs <- attr <* whitespace
    tok "/>"
    return $ printPragma tagName attrs []

multiTag :: Parser String
multiTag = do
    tok "<"
    tagName <- some alphaNumChar <* whitespace
    attrs <- attr <* whitespace
    tok ">"
    childArr <- manyTill ((try jsx) <|> textString) (tok ("</" ++ tagName ++ ">"))
    return $ printPragma tagName attrs childArr

codeP :: Parser String
codeP = do
    tok "{"
    code <- manyTill anyChar (tok "}")
    return $ code

type AttrName = String
type AttrValue = String
type AttrPair = (AttrName, AttrValue)
type Attributes = [AttrPair]

attrName :: Parser AttrName
attrName = manyTill letterChar (tok "=")

attrValue :: Parser AttrValue
attrValue = stringAttrP

stringAttrP :: Parser AttrValue
stringAttrP = do
    tok "\""
    val <- manyTill (alphaNumChar <|> oneOf "-") (tok "\"")
    return $ "\"" ++ val ++ "\""

attr :: Parser Attributes
attr = attr' `sepEndBy` whitespace
    where
    attr' = (,) <$> attrName <*> attrValue <* whitespace

textString :: Parser String
textString = whitespace *> many (alphaNumChar <|> oneOf " \t\r\n") <* whitespace
