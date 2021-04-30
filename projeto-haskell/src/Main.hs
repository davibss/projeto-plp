module Main where
import CRUDQuiz
import System.Console.ANSI
import System.IO
import Utils.Util
import Controller.UserController
import Entities.User
import System.Exit ( exitSuccess )

-- Função de cadastro
cadastrar :: IO()
cadastrar = do
    clearScreen
    printBorderTerminal
    name <- getLineWithMessage "Crie o nome do usuário: "
    email <- getLineWithMessage "Crie o email do usuário: "
    password <- getPasswordInput "Crie a senha do usuário: "
    user <- getUserByEmail email
    if length user == 1 then do
        getLineWithMessage "Email já existe. Pressione enter para voltar...."
        return ()
    else do
        addUser name email password
        getLineWithMessage "Usuário cadastrado. Pressione Enter para voltar..."
        return ()

logar :: IO()
logar = do
    clearScreen
    printBorderTerminal
    email <- getLineWithMessage "Digite o email do usuário: "
    user <- getUserByEmail email
    if null user then do
        getLineWithMessage "Email não encontrado. Pressione enter para voltar...."
        return () 
    else do
        passwordUser <- getPasswordInput "Digite a senha do usuário: "
        let logado = passwordValidate passwordUser (password(head user))
        if logado then mainQuiz (getId  (head user)) else do
            getLineWithMessage "Senha errada, tente novamente!..."
            return ()
    return ()    

-- Função principal para executar o sistema
main :: IO ()
main = do
    clearScreen
    putStrLn "Quiz de Cálculo I e II!"
    printBorderTerminal
    putStrLn "1 - Login"
    putStrLn "2 - Cadastrar usuário"
    putStrLn "99 - Sair"
    printBorderTerminal
    resp <- getLineWithMessage "Opção> "
    if resp /= "99" then
        if resp == "1" then
            logar >> main
        else if resp == "2" then
            cadastrar >> main
        else do
            clearScreen
            getLineWithMessage "Opção não encontrada. Enter para voltar ao menu principal..."
            main
    else
        exitSuccess
