module Main where
import CRUDQuiz
import System.Console.ANSI
import System.IO
import Utils.Util

-- Função principal para executar o sistema
main :: IO ()
main = do
    -- Este não será o menu principal do sistema, a chamada da função é só para debug
    clearScreen
    userId <- getLineWithMessage "Código do usuário> "
    mainQuiz (read userId)