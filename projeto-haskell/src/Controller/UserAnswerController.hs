{-# LANGUAGE OverloadedStrings #-}
module Controller.UserAnswerController where
import Entities.UserAnswer
import Utils.Util
import Database.SQLite.Simple

data UserAnswerForQuiz = UserAnswerForQuiz{
    id:: String,
    formulation:: String,
    right_answer:: String,
    marked_answer:: String,
    timeSpent:: Int
}

instance Show UserAnswerForQuiz where
    show (UserAnswerForQuiz id formulation right_answer marked_answer timeSpent) =
        "Enunciado: "++formulation++", Resposta certa: "++right_answer++", "++
        "Resposta marcada: "++marked_answer++", Tempo Gasto: "++show timeSpent++"s "
instance FromRow UserAnswer where
  fromRow = UserAnswer <$> field
                       <*> field
                       <*> field
                       <*> field
                       <*> field
                       <*> field
                       <*> field
instance FromRow UserAnswerForQuiz where
    fromRow = UserAnswerForQuiz <$> field
                                <*> field
                                <*> field
                                <*> field
                                <*> field

addUserAnswer:: String -> String -> Int -> String -> Double -> IO String
addUserAnswer user_id quiz_id rating suggestion score = do
    conn <- open dbPath
    uuidUserAnswer <- getRandomUUID
    execute conn "INSERT INTO user_answer (user_answer_id,user_id,quiz_id,rating,\
    \suggestion,score,created_at) VALUES (?,?,?,?,?,?,datetime('now','localtime'))"
        [uuidUserAnswer,user_id,quiz_id,show rating,suggestion,show score]
    return uuidUserAnswer

addUserAnswerQuestion:: String -> String -> Int -> String -> IO ()
addUserAnswerQuestion userAnswerId questionId timeSpent markedAnswer = do
    conn <- open dbPath
    execute conn "INSERT INTO user_answer_question (user_answer_id,question_id,timeSpent,\
    \markedAnswer) VALUES (?,?,?,?)" [userAnswerId,questionId,show timeSpent,markedAnswer]

getAllAnswersFromUser:: String -> IO [UserAnswer]
getAllAnswersFromUser user_id = do
    conn <- open dbPath
    query conn "SELECT ua.user_answer_id, ua.user_id, ua.quiz_id, ua.rating,\
    \ ua.suggestion, ua.score, ua.created_at FROM user_answer ua, quiz q WHERE \
    \q.quiz_id = ua.quiz_id AND ua.user_id = ?"  (Only user_id) :: IO [UserAnswer]

getAllAnswersQuizFromUser:: String -> String -> String -> IO [UserAnswerForQuiz]
getAllAnswersQuizFromUser user_id quiz_id user_answer_id = do
    conn <- open dbPath
    query conn "SELECT (uaq.user_answer_id || '-' || uaq.question_id) as id, \
    \q.formulation, q.right_answer,uaq.markedAnswer,\
    \ uaq.timeSpent FROM user_answer ua, question q, user_answer_question uaq\
    \ WHERE ua.user_answer_id=uaq.user_answer_id AND\
    \ uaq.question_id=q.question_id\
    \ AND ua.user_id=? AND ua.quiz_id=? AND ua.user_answer_id=?"
        (user_id:: String, quiz_id :: String, user_answer_id :: String)
            :: IO [UserAnswerForQuiz]