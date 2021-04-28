{-# LANGUAGE OverloadedStrings #-}
module Controller.QuizController where

import Entities.Quiz
import Database.SQLite.Simple
import Database.SQLite.Simple.FromRow
import Database.SQLite.Simple.ToField
import Utils.Util
instance FromRow Quiz where
  fromRow = Quiz <$> field
                 <*> field
                 <*> field
                 <*> field

instance ToRow Quiz  where
  toRow (Quiz id name topic user_id) = toRow (id, name, topic, user_id)

addQuiz :: String -> String -> String -> IO ()
addQuiz nameQuiz topicQuiz userId = withConn dbPath $
  \conn -> do
      uuidQuiz <- getRandomUUID
      let quiz = Quiz uuidQuiz nameQuiz topicQuiz userId 
      execute conn "INSERT INTO quiz (quiz_id,name,topic,user_id) VALUES (?,?,?,?)" quiz

getMyQuizzes :: String -> IO [Quiz]
getMyQuizzes user_id = do
    conn <- open dbPath
    query conn "SELECT * from quiz WHERE user_id = ?" (Only user_id) :: IO [Quiz]

getAllQuizzes :: IO [Quiz]
getAllQuizzes = do
    conn <- open dbPath
    query_ conn "SELECT * from quiz" :: IO [Quiz]

updateQuiz:: Quiz -> IO()
updateQuiz quiz = do
      conn <- open dbPath
      execute conn "UPDATE quiz SET name = ?, topic = ? WHERE quiz_id = ?" 
        (getName quiz :: String,getTopic quiz, quiz_id quiz :: String)

deleteQuiz :: String -> IO()
deleteQuiz quizId = do
    conn <- open dbPath
    execute_ conn "PRAGMA foreign_keys = ON"
    execute conn "DELETE FROM quiz WHERE quiz_id = ?" (Only quizId)
