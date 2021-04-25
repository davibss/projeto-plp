{-# LANGUAGE OverloadedStrings #-}
module Controller.QuestionController where
import Entities.Question
import Database.SQLite.Simple
import Database.SQLite.Simple.FromRow
import Database.SQLite.Simple.ToField
import Utils.Util
import Database.SQLite.Simple.Types

instance FromRow Question where
  fromRow = Question <$> field
                     <*> field
                     <*> field
                     <*> field
                     <*> field

addQuestion :: String -> Int -> String -> IO String
addQuestion formulation duration quizId = do
    conn <- open dbPath 
    uuidQuestion <- getRandomUUID
    execute conn "INSERT INTO question (question_id,formulation,\
        \time,quiz_id) VALUES (?,?,?,?)"
        [uuidQuestion,formulation,show duration,quizId]
    return uuidQuestion

getAllQuestions :: String -> IO [Question]
getAllQuestions quiz_id = do
    conn <- open dbPath
    query conn "SELECT * from question WHERE quiz_id = ?"  (Only quiz_id)
        :: IO [Question]

updateQuestionRightAnswer:: String -> String -> IO()
updateQuestionRightAnswer question_id right_answer = do
    conn <- open dbPath
    execute conn "UPDATE question SET right_answer = ? WHERE question_id = ?"
        (right_answer, question_id)

deleteQuestion :: String -> IO ()
deleteQuestion question_id = do
    conn <- open dbPath
    execute_ conn "PRAGMA foreign_keys = ON"
    execute conn "DELETE FROM question WHERE question_id = ?" (Only question_id)

addAnswer :: String -> String -> IO ()
addAnswer textAnswer question_id = withConn dbPath $
  \conn -> do
      execute conn "INSERT INTO answer (text,question_id) \
        \VALUES (?,?)" [textAnswer,question_id]