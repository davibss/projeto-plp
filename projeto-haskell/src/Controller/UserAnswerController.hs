{-# LANGUAGE OverloadedStrings #-}
module Controller.UserAnswerController where
import Entities.UserAnswer
import Utils.Util
import Database.SQLite.Simple

instance FromRow UserAnswer where
  fromRow = UserAnswer <$> field
                       <*> field
                       <*> field
                       <*> field
                       <*> field
                       <*> field

addUserAnswer:: String -> String -> Int -> String -> Double -> IO String
addUserAnswer user_id quiz_id rating suggestion score = do
    conn <- open dbPath
    uuidUserAnswer <- getRandomUUID
    execute conn "INSERT INTO user_answer (user_answer_id,user_id,quiz_id,rating,\
    \suggestion,score) VALUES (?,?,?,?,?,?)" [uuidUserAnswer,user_id,quiz_id,show rating,
        suggestion,show score]
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
    \ ua.suggestion, ua.score FROM user_answer ua, quiz q WHERE \
    \q.quiz_id = ua.quiz_id AND ua.user_id = ?"  (Only user_id) :: IO [UserAnswer]
