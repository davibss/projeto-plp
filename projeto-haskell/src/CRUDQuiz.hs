module CRUDQuiz where
import Controller.QuizController
    ( deleteQuiz, updateQuiz, getAllQuizzes, getMyQuizzes, addQuiz, getAllQuizzesWithQuestions, getAllQuizzesWithAnswers )
import Entities.Quiz ( getTopic, getName, Quiz(Quiz, quiz_id, user_id), getIdQuiz )
-- import Entities.UserAnswerQuiz
import System.Console.ANSI ( clearScreen )
import Data.Char ()
import System.Exit ( exitSuccess )
import System.IO ()
import Utils.Util ( getLineWithMessage, printBorderTerminal, getAlterLine, getMaybeString, lowerString )
import CRUDQuestion
import Data.Maybe (fromMaybe)
import MainResolveQuiz (mainResolve)
import Controller.UserAnswerController (getAllAnswersQuizFromUser,
    getAllAnswersFromUser, UserAnswerForQuiz)
import Controller.UserController
import Entities.User

-- menu para cadastrar quizzes
menuQuiz:: Int -> String -> IO()
menuQuiz 1 user_id = do
    printBorderTerminal
    nameQuiz <- getLineWithMessage "Nome do Quiz> "
    topicQuiz <- getLineWithMessage "Tópico do Quiz> "
    addQuiz nameQuiz topicQuiz user_id
    printBorderTerminal
    resp <- getLineWithMessage "Quiz cadastrado! Pressione enter para voltar..."
    mainQuiz user_id

-- menu para listar os quizzes do usuário
menuQuiz 2 user_id = do
    clearScreen
    printBorderTerminal
    quizzes <- getMyQuizzes user_id
    putStrLn $ printQuiz quizzes 1
    printBorderTerminal
    cod <- getLineWithMessage "Selecione um quiz pelo número para editar, enter para sair> "
    if cod == "" then
        mainQuiz user_id
    else
        menuSelectedQuiz user_id (quizzes!!(read cod-1))
    resp <- getLineWithMessage "Pressione enter para voltar..."
    mainQuiz user_id

-- menu para listar todos os quizzes
menuQuiz 3 user_id = do
    printBorderTerminal
    quizzes <- getAllQuizzes
    putStrLn $ printQuiz quizzes 1
    printBorderTerminal
    resp <- getLineWithMessage "Pressione enter para voltar..."
    mainQuiz user_id

-- menu para resolver um quiz
menuQuiz 4 user_id = do
    printBorderTerminal
    quizzes <- getAllQuizzesWithQuestions
    putStrLn $ printQuiz quizzes 1
    printBorderTerminal
    resp <- getLineWithMessage "Escolha um quiz pelo número> "
    if read resp <= length quizzes && read resp > 0 then
        mainResolve user_id (quizzes!!(read resp - 1))
        >> getLineWithMessage "Enter para voltar ao menu principal..." >>
        mainQuiz user_id
    else do
        getLineWithMessage "Quiz não encontrado! Pressione Enter para voltar ao menu principal..."
        mainQuiz user_id

menuQuiz 5 user_id = do
    printBorderTerminal
    quizzes <- getAllQuizzesWithAnswers user_id
    putStrLn $ printQuiz quizzes 1
    printBorderTerminal
    resp <- getLineWithMessage "Escolha um quiz pelo número> "
    printBorderTerminal
    putStrLn "Respostas:"
    if read resp <= length quizzes && read resp > 0 then do
        allAnswersFromQuiz <- getAllAnswersQuizFromUser user_id 
            (getIdQuiz (quizzes!!(read resp-1)))
        putStrLn $ printAnswersQuiz allAnswersFromQuiz 1
        getLineWithMessage "Pressione Enter para voltar ao menu principal..."
        mainQuiz user_id
    else do
        getLineWithMessage "Quiz não encontrado! Pressione Enter para voltar ao menu principal..."
        mainQuiz user_id
-- menu de alteracao de usuario
menuQuiz 6 user_id = do
    printBorderTerminal
    user <- getUserById user_id
    nome <- getAlterLine "Nome> " (name (head user))
    email <- getAlterLine "Email> " (email (head user))
    updateUser $ User user_id (getMaybeString nome) (getMaybeString email) ""
    getLineWithMessage "Pressione Enter para voltar ao menu principal..."
    mainQuiz user_id
-- menu para listar os quizzes por topico
menuQuiz 7 user_id = do
    printBorderTerminal
    quizzes <- getAllQuizzes
    topicInput <- getLineWithMessage "Qual tópico deseja procurar?>"
    let quizzesFiltered = filter (flip filterQuiz topicInput) quizzes
    putStrLn $ printQuiz quizzesFiltered 1
    printBorderTerminal
    resp <- getLineWithMessage "Pressione enter para voltar..."
    mainQuiz user_id
menuQuiz cod user_id = do
    printBorderTerminal
    resp <- getLineWithMessage "Opção de menu não encontrada. Pressione enter para voltar..."
    mainQuiz user_id

-- verifica se o topico do quiz eh o mesmo topico digitado pelo usuario
filterQuiz:: Quiz -> String -> Bool
filterQuiz quiz topicInput = lowerString(getTopic quiz) == lowerString topicInput
-- menu para editar o quiz
menuSelectedQuiz:: String -> Quiz -> IO()
menuSelectedQuiz user_id quiz = do
    clearScreen
    putStrLn $ show quiz
    printBorderTerminal
    putStrLn "1 - Ver questões"
    putStrLn "2 - Alterar quiz"
    putStrLn "0 - Deletar quiz"
    printBorderTerminal
    resp <- getLineWithMessage "Selecione uma opção ou pressione enter para voltar> "
    if resp /= "" then
        if read resp == 1 then
            mainQuestion (quiz_id quiz)
        else if read resp == 2 then do
            putStrLn "Alterando quiz... Se não quiser alterar um atributo apenas dê enter"
            name <- getAlterLine "Nome> " (getName quiz)
            topic <- getAlterLine "Tópico> " (getTopic quiz)
            let nameEdited = fromMaybe "Not Found" name
            let topicEdited = fromMaybe "Not Found" topic
            updateQuiz $ Quiz (quiz_id quiz) nameEdited topicEdited user_id ""
            putStrLn $ if (nameEdited == getName quiz) &&
                (topicEdited == getTopic quiz) then "Nada a alterar..." else "Quiz alterado!"
        else if read resp == 0 then do
            deleteQuiz $ quiz_id quiz
            putStrLn "Quiz deletado com sucesso!"
        else
            putStrLn "Opção não listada"
    else
        menuQuiz 2 user_id

printQuiz:: [Quiz] -> Int -> String
printQuiz [] count = ""
printQuiz quizzes count = show count ++ ", "++
                            show (head quizzes) ++ "\n" ++
                            printQuiz (tail quizzes) (count+1)

printAnswersQuiz:: [UserAnswerForQuiz] -> Int -> String
printAnswersQuiz [] count = ""
printAnswersQuiz answers count = show count ++ ", "++
                            show (head answers) ++ "\n" ++
                            printAnswersQuiz (tail answers) (count+1)

-- Função para executar o CRUD de quizes
mainQuiz:: String -> IO()
mainQuiz user_id = do
    clearScreen
    printBorderTerminal
    putStrLn "1 - Cadastrar Quiz"
    putStrLn "2 - Meus Quizzes"
    putStrLn "3 - Listar Quizzes"
    putStrLn "4 - Resolver Quizzes"
    putStrLn "5 - Quizzes Respondidos"
    putStrLn "6 - Alterar Usuário"
    putStrLn "7 - Quizzes por Tópico"
    putStrLn "99 - Sair"
    printBorderTerminal
    resp <- getLineWithMessage "Opção> "
    clearScreen
    if read resp /= 99 then
        menuQuiz (read resp) user_id
    else
        exitSuccess