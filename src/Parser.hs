module Parser
       ( toplevelCmdP
       ) where

import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Expr
import Text.ParserCombinators.Parsec.Number (int)

import Syntax
import Lexer

varP :: Parser Expr
varP = Var <$> identifier

intP :: Parser Expr
intP = Int <$> integer

boolParser :: Parser Expr
boolParser = undefined

timesParser :: Parser Expr
timesParser = undefined

termP :: Parser Expr
termP =     parens exprP
        <|> varP
        <|> intP

opP :: Parser Expr
opP = buildExpressionParser aOperators termP

equalParser :: Parser Expr
equalParser = do
  spaces
  a <- exprP
  between spaces spaces $ string "="
  b <- exprP
  return $ Less a b

lessP :: Parser Expr
lessP = do
  expr1 <- termP
  reserved "<"
  expr2 <- termP
  return $ Less expr1 expr2

ifP :: Parser Expr
ifP = do
  reserved "if"
  cond  <- exprP
  reserved "then"
  expr1 <- exprP
  reserved "else"
  expr2<- exprP
  return $ If cond expr1 expr2

-- add depth restriction for left recursion
-- or chainl1
exprP :: Parser Expr
exprP =     try (parens exprP)
        <|> try ifP
        <|> try lessP
        <|> try opP
        <|> intP

defP :: Parser ToplevelCmd
defP = do
  reserved "let"
  var  <- identifier
  reservedOp "="
  expr <- exprP
  return $ Def var expr

toplevelCmdP :: Parser ToplevelCmd
toplevelCmdP =     defP
               <|> Expr <$> exprP
