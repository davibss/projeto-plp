module Main where
import CRUDQuiz
import System.Console.ANSI
import System.IO
import Utils.Util
import Controller.UserController


-- Função de cadastro
cadastrar :: IO()
cadastrar = do
    clearScreen
    printBorderTerminal
    name <- getLineWithMessage "Crie o nome do usuário: "
    email <- getLineWithMessage "Crie o email do usuário: "
    password <- getPasswordInput "Crie a senha do usuário: "
    addUser name email password


{-logar :: IO()
logar = do
    clearScreen
    printBorderTerminal
    email <- getLineWithMessage "Digite o email do usuário: "
    passwordUser <- getPasswordInput "Digite a senha do usuário: "
    user <- getUserByEmail email
    let logado = passwordValidate passwordUser password (head user) -}
    
    
    




-- Função principal para executar o sistema
main :: IO ()
main = do
    -- Este não será o menu principal do sistema, a chamada da função é só para debug
    clearScreen
    let uuidLists = ["441f76e1-bce8-4c91-a828-bed67696b3a0",
                    "2adee2d7-b1a9-4568-afa6-bcb248588962"]
    userId <- getLineWithMessage "Código do usuário> "
    mainQuiz $ uuidLists!!read userId
