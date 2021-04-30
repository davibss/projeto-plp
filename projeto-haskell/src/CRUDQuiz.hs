module CRUDQuiz where
import Controller.QuizController
    ( deleteQuiz, updateQuiz, getAllQuizzes, getMyQuizzes, addQuiz, getAllQuizzesWithQuestions,
        getAllQuizzesWithAnswers, getAllQuizzesAnswers, QuizAnswer (userAnswerId, topic), getQuizAnswerId, getAllQuizzesAnswersUnique)
import Entities.Quiz ( getTopic, getName, Quiz(Quiz, quiz_id, user_id), getIdQuiz )
-- import Entities.UserAnswerQuiz
import System.Console.ANSI ( clearScreen )
import Data.Char ()
import System.Exit ( exitSuccess )
import System.IO ()
import Utils.Util ( getLineWithMessage, printBorderTerminal, getAlterLine, getMaybeString, lowerString, shuffleList )
import CRUDQuestion
import Data.Maybe (fromMaybe)
import MainResolveQuiz (mainResolve, QuestionResponse (duration))
import Controller.UserAnswerController (getAllAnswersQuizFromUser,
    getAllAnswersFromUser, UserAnswerForQuiz)
import Controller.UserController
import Entities.User
import Entities.Question
import Controller.QuestionController ( getAllQuestions, addQuestion )
import Control.Monad (when)

-- menu para cadastrar quizzes
menuQuiz:: Int -> String -> IO()
menuQuiz 1 user_id = do
    printBorderTerminal
    nameQuiz <- getLineWithMessage "Nome do Quiz> "
    topicQuiz <- getLineWithMessage "Tópico do Quiz> "
    addQuiz nameQuiz topicQuiz user_id
    printBorderTerminal
    resp <- getLineWithMessage "Quiz cadastrado! Pressione enter para voltar..."
    return ()

-- menu para listar os quizzes do usuário
menuQuiz 2 user_id = do
    clearScreen
    printBorderTerminal
    quizzes <- getMyQuizzes user_id
    putStrLn $ printWithIndex quizzes 1
    printBorderTerminal
    cod <- getLineWithMessage "Selecione um quiz pelo número para editar, enter para sair> "
    if cod == "" then do
        return ()
    else do
        menuSelectedQuiz user_id (quizzes!!(read cod-1))
        return ()

menuQuiz 3 user_id = do
    printBorderTerminal
    quizzes <- getAllQuizzes
    topicInput <- getLineWithMessage "Qual tópico deseja procurar?>"
    let quizzesFiltered = filter (`filterQuiz` topicInput) quizzes
    putStrLn $ printWithIndex quizzesFiltered 1
    printBorderTerminal
    resp <- getLineWithMessage "Escolha um quiz pelo número> "
    if resp /= "" then
        if read resp <= length quizzesFiltered && read resp > 0 then
            mainResolve user_id (quizzesFiltered!!(read resp - 1))
            >> getLineWithMessage "Enter para voltar ao menu principal..." >>
            return ()
        else do
            getLineWithMessage "Quiz não encontrado! Pressione Enter para voltar ao menu principal..."
            return ()
    else do
        getLineWithMessage "Opção não encontrada. Pressione Enter para voltar..."
        return ()

-- quizes respondidos
menuQuiz 4 user_id = do
    printBorderTerminal
    quizzes <- getAllQuizzesAnswers user_id
    putStrLn $ printWithIndex quizzes 1
    printBorderTerminal
    resp <- getLineWithMessage "Escolha um quiz pelo número> "
    printBorderTerminal
    putStrLn "Respostas:"
    if read resp <= length quizzes && read resp > 0 then do
        allAnswersFromQuiz <- getAllAnswersQuizFromUser user_id
            (getQuizAnswerId (quizzes!!(read resp-1))) (userAnswerId (quizzes!!(read resp-1)))
        putStrLn $ printWithIndex allAnswersFromQuiz 1
        getLineWithMessage "Pressione Enter para voltar ao menu principal..."
        return ()
    else do
        getLineWithMessage "Quiz não encontrado! Pressione Enter para voltar ao menu principal..."
        return ()

-- menu de alteracao de usuario
menuQuiz 5 user_id = do
    printBorderTerminal
    user <- getUserById user_id
    nome <- getAlterLine "Nome> " (name (head user))
    email <- getAlterLine "Email> " (email (head user))
    updateUser $ User user_id (getMaybeString nome) (getMaybeString email) ""
    getLineWithMessage "Pressione Enter para voltar ao menu principal..."
    return ()

menuQuiz 6 user_id = do
    printBorderTerminal
    topicInput <- getLineWithMessage "Qual tópico deseja procurar por questões?> "
    printBorderTerminal
    quizzes <- getAllQuizzesAnswersUnique user_id
    let quizzesFiltered = filter (`filterQuiz` topicInput) quizzes
    allQuestions <- concatenateQuestions quizzesFiltered
    if (length allQuestions == 0) then do
        putStrLn "Não há questões..."
        getLineWithMessage "Pressione enter para voltar..."
        return ()
    else do
        putStrLn "Essas são as questões que você respondeu recentemente sobre este tópico:"
        putStrLn $ printWithIndex allQuestions 1
        printBorderTerminal
        qtdQuest <- getLineWithMessage "Quantas questões quer no seu quiz?> "
        if read qtdQuest > (length allQuestions) then do
            getLineWithMessage "Número de questões em excesso... pressione enter para voltar..."
            return ()
        else do
            questionsRandomized <- shuffleList allQuestions
            newQuiz <- getLineWithMessage "Digite o nome do seu Super Quiz>"
            uuidQuiz <- addQuiz newQuiz topicInput user_id -- cadastrando super quiz
            creatingQuestions uuidQuiz (take (read qtdQuest) questionsRandomized)
            putStrLn "Quiz e suas Questões criadas!"
        resp <- getLineWithMessage "Pressione enter para voltar..."
        return ()

menuQuiz cod user_id = do
    printBorderTerminal
    resp <- getLineWithMessage "Opção de menu não encontrada. Pressione enter para voltar..."
    return ()

creatingQuestions:: String -> [Question] -> IO()
creatingQuestions quiz_id [] = return ()
creatingQuestions quiz_id questions = do
    let question = head questions
    addQuestion (formulation question) (difficulty question) (time question)
        (type_question question) quiz_id
    creatingQuestions quiz_id (tail questions)

concatenateQuestions:: [Quiz] -> IO [Question]
concatenateQuestions [] = return []
concatenateQuestions quizzes = do
    questions <- getAllQuestions (getIdQuiz (head quizzes))
    nextQuestions <- concatenateQuestions $ tail quizzes
    return (questions++nextQuestions)

-- verifica se o topico do quiz eh o mesmo topico digitado pelo usuario
filterQuiz:: Quiz -> String -> Bool
filterQuiz quiz topicInput = lowerString(getTopic quiz) == lowerString topicInput

filterQuizAnswer:: QuizAnswer -> String -> Bool
filterQuizAnswer quiz topicInput = lowerString(topic quiz) == lowerString topicInput

-- menu para editar o quiz
menuSelectedQuiz:: String -> Quiz -> IO()
menuSelectedQuiz user_id quiz = do
    clearScreen
    print quiz
    printBorderTerminal
    putStrLn "1 - Ver questões"
    putStrLn "2 - Alterar quiz"
    putStrLn "0 - Deletar quiz"
    printBorderTerminal
    resp <- getLineWithMessage "Selecione uma opção ou pressione enter para voltar> "
    if resp /= "" then
        if read resp == 1 then
            mainQuestion (getIdQuiz quiz)
        else if read resp == 2 then do
            putStrLn "Alterando quiz... Se não quiser alterar um atributo apenas dê enter"
            name <- getAlterLine "Nome> " (getName quiz)
            topic <- getAlterLine "Tópico> " (getTopic quiz)
            let nameEdited = fromMaybe "Not Found" name
            let topicEdited = fromMaybe "Not Found" topic
            updateQuiz $ Quiz (getIdQuiz quiz) nameEdited topicEdited user_id ""
            putStrLn $ if nameEdited == getName quiz &&
                topicEdited == getTopic quiz then "Nada a alterar..." else "Quiz alterado!"
        else if read resp == 0 then do
            deleteQuiz $ getIdQuiz quiz
            putStrLn "Quiz deletado com sucesso!"
        else
            putStrLn "Opção não listada"
    else
        menuQuiz 2 user_id

printWithIndex :: Show a => [a] -> Int -> String
printWithIndex [] index = ""
printWithIndex array index = show index ++ ", "++
                            show (head array) ++ "\n" ++
                            printWithIndex (tail array) (index+1)

-- Função para executar o CRUD de quizes
mainQuiz:: String -> IO()
mainQuiz user_id = do
    clearScreen
    printBorderTerminal
    putStrLn "1 - Cadastrar Quiz"
    putStrLn "2 - Meus Quizzes"
    putStrLn "3 - Resolver Quizzes"
    putStrLn "4 - Quizzes Respondidos"
    putStrLn "5 - Alterar Usuário"
    putStrLn "6 - Criar quiz com histórico"
    putStrLn "99 - Deslogar"
    printBorderTerminal
    resp <- getLineWithMessage "Opção> "
    clearScreen
    if read resp /= 99 then do
        menuQuiz (read resp) user_id
        mainQuiz user_id
    else do
        clearScreen
        return ()