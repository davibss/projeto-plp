module Main where
import CRUDQuiz
import System.Console.ANSI
import System.IO
import Utils.Util
import Controller.UserController


-- Função de cadastro
cadastrar :: String -> String -> String -> IO()
cadastrar name email password = do
    clearScreen
    name <- getLine
    email <- getLine
    password <- getLine
    addUser name email password

logar :: String -> String -> IO()
logar email password = do
    clearScreen
    email <- getLine
    password <- getLine
    return ()
    
    
    




-- Função principal para executar o sistema
main :: IO ()
main = do
    -- Este não será o menu principal do sistema, a chamada da função é só para debug
    clearScreen
    let uuidLists = ["441f76e1-bce8-4c91-a828-bed67696b3a0",
                    "2adee2d7-b1a9-4568-afa6-bcb248588962"]
    userId <- getLineWithMessage "Código do usuário> "
    mainQuiz $ uuidLists!!read userId