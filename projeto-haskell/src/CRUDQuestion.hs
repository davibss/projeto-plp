module CRUDQuestion where
import System.Console.ANSI
import Utils.Util (printBorderTerminal, getLineWithMessage)
import Controller.QuestionController (addQuestion, addAnswer, updateQuestionRightAnswer, getAllQuestions, deleteQuestion)
import Entities.Question

menuAnswer:: Int -> Int -> String -> IO()
menuAnswer total_answers index question_id =
    if index < total_answers then do
        textAns <- getLineWithMessage $ "Texto da Letra "++
            show (['a'..'z']!!index)++"> "
        addAnswer textAns question_id
        menuAnswer total_answers (index+1) question_id
    else return ()

menuQuestion :: Int -> String -> [Question] -> IO ()
menuQuestion 1 quiz_id questions = do
    printBorderTerminal
    formulation <- getLineWithMessage "Enunciado> "
    duration <- getLineWithMessage "Duração(s)> "
    qtd <- getLineWithMessage "Quantidade de respostas> "
    questionId <- addQuestion formulation (read duration) quiz_id -- cadastrando no bd
    menuAnswer (read qtd) 0 questionId
    rightAnswer <- getLineWithMessage "Resposta correta> "
    updateQuestionRightAnswer questionId rightAnswer -- atualizando resposta
    printBorderTerminal
    resp <- getLineWithMessage "Questão cadastrada! Pressione enter para voltar..."
    mainQuestion quiz_id

menuQuestion 2 quiz_id questions = do
    putStrLn "Alterar questão"
    resp <- getLineWithMessage "Número da questão> "
    resp <- getLineWithMessage "Questão alterada! Pressione enter para voltar..."
    mainQuestion quiz_id

menuQuestion 3 quiz_id questions = do
    putStrLn "Deletar questão"
    printBorderTerminal
    resp <- getLineWithMessage "Número da questão> "
    deleteQuestion (question_id (questions!!(read resp - 1)))
    resp <- getLineWithMessage "Questão deletada! Pressione enter para voltar..."
    mainQuestion quiz_id

menuQuestion cod quiz_id questions = putStrLn "Esta opção de menu não existe!..."
    >> mainQuestion quiz_id

printQuestion:: [Question] -> Int -> String
printQuestion [] count = ""
printQuestion questions count = show count ++ ", "++
                            show (head questions) ++ "\n" ++
                            printQuestion (tail questions) (count+1)


-- Função para executar o CRUD de questões
mainQuestion:: String -> IO()
mainQuestion quiz_id = do
    clearScreen
    putStrLn "Questões"
    printBorderTerminal
    questions <- getAllQuestions quiz_id
    putStrLn $ printQuestion questions 1
    printBorderTerminal
    putStrLn "1 - Cadastrar questão"
    putStrLn "2 - Alterar questão"
    putStrLn "3 - Deletar questão"
    printBorderTerminal
    resp <- getLineWithMessage "Opção> "
    putStrLn resp
    if resp /= "" then
        menuQuestion (read resp) quiz_id questions
    else
        return ()