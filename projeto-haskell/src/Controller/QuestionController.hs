{-# LANGUAGE OverloadedStrings #-}
module Controller.QuestionController where
import Entities.Question
import Database.SQLite.Simple
import Database.SQLite.Simple.FromRow
import Database.SQLite.Simple.ToField
import Utils.Util
import Database.SQLite.Simple.Types
import Entities.Answer
import Data.List (intercalate, intersperse)

instance FromRow Question where
  fromRow = Question <$> field
                     <*> field
                     <*> field
                     <*> field
                     <*> field
                     <*> field
                     <*> field
instance FromRow Answer where
  fromRow = Answer <$> field
                   <*> field
                   <*> field

addQuestion :: String -> Int -> Int -> Int -> String -> IO String
addQuestion formulation difficulty duration typeQuestion quizId = do
    conn <- open dbPath
    uuidQuestion <- getRandomUUID
    execute conn "INSERT INTO question (question_id,formulation,difficulty,\
        \time,type_question,quiz_id) VALUES (?,?,?,?,?,?)"
        [uuidQuestion,formulation,show difficulty,show duration,show typeQuestion,quizId]
    return uuidQuestion

getAllQuestions :: String -> IO [Question]
getAllQuestions quiz_id = do
    conn <- open dbPath
    query conn "SELECT * from question WHERE quiz_id = ?"  (Only quiz_id)
        :: IO [Question]

getAllAnswers :: String -> IO [Answer]
getAllAnswers question_id = do
    conn <- open dbPath
    query conn "SELECT * from answer WHERE question_id = ?"  (Only question_id)
        :: IO [Answer]

updateQuestionRightAnswer:: String -> String -> IO()
updateQuestionRightAnswer question_id right_answer = do
    conn <- open dbPath
    execute conn "UPDATE question SET right_answer = ? WHERE question_id = ?"
        (right_answer, question_id)

updateQuestion:: Question -> IO()
updateQuestion question = do
      conn <- open dbPath
      execute conn "UPDATE question SET formulation = ?, difficulty = ?, time = ?,\
        \ right_answer = ? WHERE question_id = ?" (formulation question,
            difficulty question:: Int, time question:: Int,
            right_answer question, getIdQuestion question)

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

updateAnswer:: Answer -> IO()
updateAnswer answer = do
      conn <- open dbPath
      execute conn "UPDATE answer SET text = ?  WHERE answer_id = ?"
        (text answer, getAnswerId answer)

deleteAnswer :: Int -> IO ()
deleteAnswer answer_id = do
    conn <- open dbPath
    execute_ conn "PRAGMA foreign_keys = ON"
    execute conn "DELETE FROM answer WHERE answer_id = ?" (Only answer_id)