module CRUDQuestion where
import System.Console.ANSI
import Utils.Util (printBorderTerminal, getLineWithMessage,
    getAlterLine, getMaybeString, getMaybeInt, charToString, charIndex)
import Controller.QuestionController (addQuestion, addAnswer, updateQuestionRightAnswer, getAllQuestions, deleteQuestion, updateQuestion, getAllAnswers, deleteAnswer, updateAnswer)
import Entities.Question
import Data.Maybe (fromMaybe)
import Entities.Answer
import Control.Monad (when)

menuAddAnswer:: Int -> Int -> String -> IO()
menuAddAnswer total_answers index question_id =
    if (index < total_answers) then do
        textAns <- getLineWithMessage $ "Texto da Letra "++
            charToString (['a'..'z']!!index)++"> "
        addAnswer textAns question_id
        menuAddAnswer total_answers (index+1) question_id
    else
        return ()

menuUpdateAnswer:: Int -> Int -> [Answer] -> IO ()
menuUpdateAnswer total_answers index answers =
    if (index < total_answers) then do
        textAns <- getAlterLine ("Nova Letra "++charToString (['a'..'z']!!index)++")> ")
            (text (answers!!index ))
        let answer = answers!!index
        updateAnswer $ Answer (getAnswerId answer) (getMaybeString textAns)
            (getAnswerQuestionId answer)
        menuUpdateAnswer total_answers (index+1) answers
    else
        return ()

getNumberAnswers:: Int -> IO Int
getNumberAnswers typeQuestion = do
    if typeQuestion /= 1 then do
        qtd <- getLineWithMessage "Quantidade de respostas> "
        if qtd /= "" then
            if read qtd < 0 then
                return 0
            else        
                return (read qtd)
        else
            return 0
    else
        return 2

menuQuestion :: Int -> String -> [Question] -> IO ()
-- opção de menu para cadastro de questões
menuQuestion 1 quiz_id questions = do
    clearScreen
    printBorderTerminal
    formulation <- getLineWithMessage "Enunciado> "
    difficulty <- getLineWithMessage "Dificuldade [0-Fácil,1-Média,2-Difícil]> "
    duration <- getLineWithMessage "Duração(s) (Mínimo 10s)> "
    typeQuestion <- getLineWithMessage
        "Tipo de questão ([0]-Alternativa única, [1]-V/F, [2]-Múltipla escolha)> "
    if formulation == "" ||
        (typeQuestion == "") || (difficulty == "") ||
        ((read difficulty < 0) || (read difficulty > 2)) ||
        (read duration < 10) || 
        ((read typeQuestion < 0) || (read typeQuestion > 2)) then
        getLineWithMessage "Algum campo não está correto. Pressione Enter para voltar..."
        >> return ()
    else do
        qtd <- getNumberAnswers (read typeQuestion)
        if (qtd > 0) then do
            questionId <- addQuestion formulation (read difficulty) (read duration) 
                (read typeQuestion) quiz_id -- cadastrando no bd
            menuAddAnswer qtd 0 questionId
            rightAnswer <- getLineWithMessage 
                (if typeQuestion == "2" then "Respostas corretas, separe por vírgula> " 
                    else "Resposta correta> ")
            if typeQuestion /= "2" && rightAnswer == "" then
                getLineWithMessage "Você precisa escolher uma resposta certa! Enter para voltar..."
                >> return ()
            else do
                updateQuestionRightAnswer questionId rightAnswer -- atualizando resposta
                printBorderTerminal
                resp <- getLineWithMessage "Questão cadastrada! Pressione enter para voltar..."
                return ()
        else 
            getLineWithMessage "Algum campo não está correto. Pressione Enter para voltar..."
            >> return ()

-- opção de menu para alterar questão
menuQuestion 2 quiz_id questions = do
    clearScreen
    putStrLn "Alterar questão"
    printBorderTerminal
    putStrLn $ printQuestion questions 1
    printBorderTerminal
    resp <- getLineWithMessage "Número da questão> "
    if resp == "" || (read resp <= 0) || (read resp > length questions) then
        getLineWithMessage "Questão não encontrada. Pressione Enter para voltar..."
        >> return ()
    else do
        let question = questions!!(read resp-1)
        printBorderTerminal
        formulation <- getAlterLine "Novo enunciado> " (formulation question)
        difficulty <- getAlterLine "Nova dificuldade> " (show $ difficulty question)
        duration <- getAlterLine "Nova duração> " (show $ time question)
        rightAnswer <- getAlterLine "Nova resposta correta> " (getMaybeString (right_answer question))
        updateQuestion $ Question (getIdQuestion question) (getMaybeString formulation)
            (getMaybeInt difficulty) (getMaybeInt duration) rightAnswer quiz_id 0
        resp <- getLineWithMessage "Questão alterada! Pressione enter para voltar..."
        return ()

-- opção de menu para entrar no menu de respostas
menuQuestion 3 quiz_id questions = do
    clearScreen
    if length questions == 0 then
        getLineWithMessage "Não há nenhuma questão cadastrada. Pressione Enter para voltar..."
        >> return ()
    else do
        putStrLn $ printQuestion questions 1
        printBorderTerminal
        respQuestion <- getLineWithMessage "Número da questão> "
        if respQuestion == "" || (read respQuestion <= 0) || (read respQuestion > length questions) then
            getLineWithMessage "Questão não encontrada. Pressione Enter para voltar..."
            >> return ()
        else do
            clearScreen
            menuAnswer respQuestion questions quiz_id
            return ()

-- opção de menu para deletar questão
menuQuestion 4 quiz_id questions = do
    putStrLn "Deletar questão"
    printBorderTerminal
    putStrLn $ printQuestion questions 1
    printBorderTerminal
    resp <- getLineWithMessage "Número da questão> "
    if resp == "" || (read resp <= 0) || (read resp > length questions) then
        getLineWithMessage "Questão não encontrada. Pressione Enter para voltar..."
        >> return ()
    else do
        deleteQuestion (getIdQuestion (questions!!(read resp - 1)))
        resp <- getLineWithMessage "Questão deletada! Pressione enter para voltar..."
        return ()

menuQuestion cod quiz_id questions = putStrLn "Esta opção de menu não existe!..."
    >> return ()

menuAnswer :: String -> [Question] -> String -> IO ()
menuAnswer respQuestion questions quiz_id = do
    clearScreen
    putStrLn "Respostas da questão"
    printBorderTerminal
    answers <- getAllAnswers (getIdQuestion (questions!!(read respQuestion -1)))
    putStrLn $ "Resposta correta: "++getMaybeString
        (right_answer (questions!!(read respQuestion - 1)))++")"
    putStrLn "Repostas: "
    putStrLn $ printAnswer answers 0
    printBorderTerminal
    putStrLn "1 - Adicionar resposta"
    putStrLn "2 - Alterar respostas"
    putStrLn "3 - Deletar resposta"
    putStrLn "Enter - Voltar para o menu"
    printBorderTerminal
    resp <- getLineWithMessage "Opção> "
    let questionId = getIdQuestion (questions!!(read respQuestion -1))
    clearScreen
    if resp == "1" then do
        menuAddAnswer (length answers + 1) (length answers) questionId
        putStr "Resposta adicionada! "
        getLineWithMessage "Pressione enter para voltar..."
        menuAnswer respQuestion questions quiz_id
    else if resp == "2" then do
        putStrLn "Alterando todas respostas"
        menuUpdateAnswer (length answers) 0 answers
        getLineWithMessage "Pressione enter para voltar..."
        menuAnswer respQuestion questions quiz_id
    else if resp == "3" then do
        deleteN <- getLineWithMessage "Letra Resposta> "
        if (head deleteN) `elem` take (length answers) ['a'..'z'] then do
            deleteAnswer (getAnswerId (answers!!charIndex deleteN))
            putStr "Resposta deletada! "
            getLineWithMessage "Pressione enter para voltar..."
            menuAnswer respQuestion questions quiz_id
        else
            getLineWithMessage "Resposta não encontrada. Pressione Enter para voltar..."
            >> return ()
    else do
        return ()
    return ()

printAnswer:: [Answer] -> Int -> String
printAnswer [] count = ""
printAnswer answers count =
    charToString (['a'..'z']!!count) ++ ") "++
    show (head answers) ++ (if null $ tail answers then "" else "\n") ++
    printAnswer (tail answers) (count+1)

printQuestion:: [Question] -> Int -> String
printQuestion [] count = ""
printQuestion questions count =
    show count ++ ", "++
    show (head questions) ++ (if null $ tail questions then "" else "\n") ++
    printQuestion (tail questions) (count+1)

-- Função para executar o CRUD de questões
mainQuestion:: String -> IO()
mainQuestion quiz_id = do
    clearScreen
    putStrLn "Nº Questão"
    printBorderTerminal
    questions <- getAllQuestions quiz_id
    if length questions == 0 then
        putStrLn "Nenhum questão cadastrada."
    else putStrLn $ printQuestion questions 1
    printBorderTerminal
    putStrLn "1 - Cadastrar questão"
    putStrLn "2 - Alterar questão"
    putStrLn "3 - Ver respostas"
    putStrLn "4 - Deletar questão"
    putStrLn "Enter - Voltar para o menu de Quizzess"
    printBorderTerminal
    resp <- getLineWithMessage "Opção> "
    putStrLn resp
    if resp /= "" then
        menuQuestion (read resp) quiz_id questions
        >> mainQuestion quiz_id
    else
        return ()