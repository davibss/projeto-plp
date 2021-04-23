module CRUDQuiz where
import Controller.QuizController
import Entities.Quiz
import System.Console.ANSI
import Data.Char
import System.Exit
import System.IO
import Utils.Util

-- Função para executar o CRUD de quizes
menuQuiz:: Int -> Int -> IO()
menuQuiz 1 user_id = do
    nameQuiz <- getLineWithMessage "Nome do Quiz> "
    topicQuiz <- getLineWithMessage "Tópico do Quiz> "
    addQuiz nameQuiz topicQuiz user_id
    resp <- getLineWithMessage "Quiz cadastrado! Pressione enter para voltar..."
    -- clearScreen
    mainQuiz user_id

menuQuiz 2 user_id = do
    clearScreen
    quizzes <- getMyQuizzes user_id
    putStrLn $ printQuiz quizzes 1
    cod <- getLineWithMessage "Selecione um quiz pelo número para editar, enter para sair> "
    if cod == "" then
        mainQuiz user_id
    else
        menuSelectedQuiz user_id (quizzes!!(read cod-1))
    resp <- getLineWithMessage "Pressione enter para voltar..."
    mainQuiz user_id

menuQuiz 3 user_id = do
    quizzes <- getAllQuizzes
    putStrLn $ printQuiz quizzes 1
    resp <- getLineWithMessage "Pressione enter para voltar..."
    -- clearScreen
    mainQuiz user_id

menuQuiz cod user_id = do
    resp <- getLineWithMessage "Opção de menu não encontrada. Pressione enter para voltar..."
    mainQuiz user_id

menuSelectedQuiz:: Int -> Quiz -> IO()
menuSelectedQuiz user_id quiz = do
    clearScreen
    putStrLn $ show quiz
    putStrLn "1 - Ver questões"
    putStrLn "2 - Alterar quiz"
    putStrLn "0 - Deletar quiz"
    resp <- getLineWithMessage "Selecione uma opção ou pressione enter para voltar> "
    if resp /= "" then
        if (read resp) == 1 then
            putStrLn "todas questões"
        else if (read resp) == 2 then do
            putStrLn "Alterando quiz... Se não quiser alterar um atributo apenas dê enter"
            name <- getLineWithMessage "Nome> "
            topic <- getLineWithMessage "Tópico> "
            let nameEdited = if name == "" then getName quiz else name
            let topicEdited = if topic == "" then getTopic quiz else name
            if nameEdited /= "" || topicEdited /= "" then do
                updateQuiz $ Quiz (quiz_id quiz) nameEdited topicEdited user_id
                putStrLn "Quiz alterado!"
            else
                putStrLn "Nada a alterar..."

        else if (read resp) == 0 then do
            deleteQuiz $ quiz_id quiz
            putStrLn "Quiz deletado com sucesso!"
        else
            putStrLn "opcao nao listada"
        -- putStrLn "questões"
    else
        menuQuiz 2 user_id

printQuiz:: [Quiz] -> Int -> String
printQuiz [] count = ""
printQuiz quizzes count = show count ++ ", "++
                            show (head quizzes) ++ "\n" ++
                            printQuiz (tail quizzes) (count+1)

mainQuiz:: Int -> IO()
mainQuiz user_id = do
    clearScreen
    putStrLn "1 - Cadastrar Quiz"
    putStrLn "2 - Meus Quizzes"
    putStrLn "3 - Listar Quizzes"
    putStrLn "4 - Resolver Quizzes"
    putStrLn "99 - Sair"
    resp <- getLineWithMessage "Opção> "
    clearScreen
    if read resp /= 99 then
        menuQuiz (read resp) user_id
    else
        exitSuccess