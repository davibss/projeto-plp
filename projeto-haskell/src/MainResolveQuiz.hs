module MainResolveQuiz where

import Utils.Util (printBorderTerminal, getLineWithMessage, charToString, removeIfExists,
    openFormulaInBrowser, calculateScore, getMaybeString, formatFloatN, removeAllSpaces)
import System.Console.ANSI (clearScreen)
import System.Console.Haskeline (getPassword, runInputT, defaultSettings)
import Data.Maybe
import Controller.QuestionController (getAllQuestions, getAllAnswers)
import Entities.Question
import Entities.Quiz
import Data.Char (toLower)
import Control.Monad (when)
import Entities.Answer
import Controller.UserAnswerController (addUserAnswer, addUserAnswerQuestion)
import Data.Time (getCurrentTime)
import Data.Time.Clock (diffUTCTime)

data QuestionResponse = QuestionResponse {
    id_question :: String,
    score:: Double,
    duration:: Int,
    answer:: String
}

instance Show QuestionResponse where
        show (QuestionResponse id_question score duration answer) =
            show score++", "++show duration++", "++answer

data QuizResponse = QuizResponse {
    rating :: Int,
    suggestion :: String,
    totalScore :: Double,
    questionsResponse :: [QuestionResponse]
}

makeHtmlTable:: [Answer] -> String
makeHtmlTable [answers] = ""
makeHtmlTable answers =
    "<p>Alternativas:</p>"++
    "<table style=\"text-align: left;\">"++
    printAnswerHtml answers 0++
    "</table>"

printAnswer:: [Answer] -> Int -> String
printAnswer [] count = ""
printAnswer answers count =
    charToString (['a'..'z']!!count) ++ ") "++
    show (head answers) ++ (if null $ tail answers then "" else "\n") ++
    printAnswer (tail answers) (count+1)

printAnswerHtml:: [Answer] -> Int -> String
printAnswerHtml [] count = ""
printAnswerHtml answers count =
    "<tr>"++
    "<td>"++charToString (['a'..'z']!!count)++") "++"</td>"++
    "<td>"++show (head answers)++"</td>"++
    "</tr>"++
    printAnswerHtml (tail answers) (count+1)

getTypeQuestion:: Int -> String
getTypeQuestion typeQuestion
    | typeQuestion == 0 = "Única alternativa"
    | typeQuestion == 1 = "Verdadeiro/Falso"
    | typeQuestion == 2 = "Múltipla escolha"
    | otherwise = "Tipo não listado"

resolveQuestion:: [Question] -> Int -> IO [QuestionResponse]
resolveQuestion [] index = return []
resolveQuestion questions index = do
    clearScreen
    putStrLn $ "Questão "++show (index+1)
    answers <- getAllAnswers (getId (head questions))
    printBorderTerminal
    openB <- getLineWithMessage "A visualização é melhor no navegador,\
        \ abrir? [S/N]> "
    when (map toLower openB == "s") $
        openFormulaInBrowser (formulation (head questions)++makeHtmlTable answers)
        >> putStrLn "Página no navegador aberta..."
    printBorderTerminal
    putStrLn $ "Você tem "++show (time (head questions))++"s para resolver está questão!!"
    printBorderTerminal
    putStrLn $ "Questão "++show (index+1)++": "++ formulation (head questions)
    putStrLn $ "Tipo de Questão: "++ getTypeQuestion(type_question (head questions))
    printBorderTerminal
    start <- getCurrentTime -- start time here
    putStrLn $ printAnswer answers 0
    answer <- getLineWithMessage "Sua resposta> "
    end <- getCurrentTime -- end time here
    removeIfExists "src/HTMLIO/formulaQuestao.html"
    nextQuestion <- resolveQuestion (tail questions) (index+1)
    let score = if removeAllSpaces answer == 
            removeAllSpaces (getMaybeString (right_answer (head questions))) then
            calculateScore start end (time (head questions))
            (difficulty (head questions)) else 0
    let difference = diffUTCTime end start
    return (QuestionResponse (getId (head questions)) score
        (floor difference) answer:nextQuestion)

startQuiz:: [Question] -> IO QuizResponse
startQuiz questions = do
    questionsResponse <- resolveQuestion questions 0
    printBorderTerminal
    let totalScore = sum $ map score questionsResponse
    putStrLn $ "Sua pontuação: "++formatFloatN totalScore 2
    putStrLn "Agora que terminou de responder, avalie este quiz"
    rating <- getLineWithMessage "Avaliação [0 a 10]> "
    suggestion <- getLineWithMessage "Sugestão> "
    putStrLn "Obrigado por responder!"
    printBorderTerminal
    return (QuizResponse (read rating) suggestion totalScore questionsResponse)

totalTime:: [Question] -> Int
totalTime questions = do
    sum $ map time questions

saveUserAnswersQuestions:: String -> [QuestionResponse] -> IO ()
saveUserAnswersQuestions userAnswerId [] = return ()
saveUserAnswersQuestions userAnswerId questionsResponses = do
    let questionResponse = head questionsResponses
    addUserAnswerQuestion userAnswerId
        (id_question questionResponse) (duration questionResponse)
        (answer questionResponse)
    saveUserAnswersQuestions userAnswerId (tail questionsResponses)

mainResolve:: String -> Quiz -> IO()
mainResolve user_id quiz = do
    clearScreen
    printBorderTerminal
    questions <- getAllQuestions (getIdQuiz quiz)
    putStrLn $ "Nome do Quiz: "++getName quiz
    putStrLn $ "Tópico do Quiz: "++getTopic quiz
    putStrLn $ "Tempo limite para responder o quiz: "++show (totalTime questions)
    printBorderTerminal
    resp <- getLineWithMessage "Deseja responder o quiz agora? [S/N]> "
    when (map toLower resp == "s") $ do
        response <- startQuiz questions
        idAnswer <- addUserAnswer user_id (getIdQuiz quiz) (rating response)
            (suggestion response) (totalScore response)
        saveUserAnswersQuestions idAnswer (questionsResponse response)
