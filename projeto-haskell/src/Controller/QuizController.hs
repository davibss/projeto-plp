{-# LANGUAGE OverloadedStrings #-}
module Controller.QuizController where

import Entities.Quiz
import Database.SQLite.Simple
import Database.SQLite.Simple.FromRow
import Database.SQLite.Simple.ToField
import Utils.Util

data QuizAnswer = QuizAnswer {
  quizId:: String,
  name:: String,
  topic:: String,
  userAnswerId:: String,
  score:: Double,
  rating:: Int,
  created_at:: String
}

getQuizAnswerId:: QuizAnswer -> String
getQuizAnswerId = quizId
instance Show QuizAnswer where
    show (QuizAnswer quizId name topic user_answer_id score rating created_at) =
        "Quiz: "++name++", Tópico: "++topic++", "++
        "Pontuação: "++formatFloatN score 2++", Avaliação: "++show rating++
        ", Respondeu em: "++created_at
instance FromRow Quiz where
  fromRow = Quiz <$> field
                 <*> field
                 <*> field
                 <*> field
                 <*> field

instance FromRow QuizAnswer where
  fromRow = QuizAnswer <$> field
                       <*> field
                       <*> field
                       <*> field
                       <*> field
                       <*> field
                       <*> field
instance ToRow Quiz  where
  toRow (Quiz id name topic user_id created_at) = toRow (id, name, topic, user_id)                      

addQuiz :: String -> String -> String -> IO String
addQuiz nameQuiz topicQuiz userId = do
    conn <- open dbPath
    uuidQuiz <- getRandomUUID
    let quiz = Quiz uuidQuiz nameQuiz topicQuiz userId ""
    execute conn "INSERT INTO quiz (quiz_id,name,topic,user_id,created_at)\
    \ VALUES (?,?,?,?,datetime('now','localtime'))" quiz
    return uuidQuiz
      
getMyQuizzes :: String -> IO [Quiz]
getMyQuizzes user_id = do
    conn <- open dbPath
    query conn "SELECT * from quiz WHERE user_id = ?" (Only user_id) :: IO [Quiz]

getAllQuizzes :: IO [Quiz]
getAllQuizzes = do
    conn <- open dbPath
    query_ conn "SELECT * from quiz" :: IO [Quiz]

getAllQuizzesWithQuestions :: IO [Quiz]
getAllQuizzesWithQuestions = do
    conn <- open dbPath
    query_ conn "SELECT DISTINCT qz.quiz_id, qz.name, qz.topic, qz.user_id,qz.created_at\
    \ FROM quiz qz, question qe WHERE qz.quiz_id = qe.quiz_id" :: IO [Quiz]

getAllQuizzesWithAnswers :: String -> IO [Quiz]
getAllQuizzesWithAnswers user_id = do
    conn <- open dbPath
    query conn "SELECT DISTINCT qz.quiz_id, qz.name, qz.topic, qz.user_id,qz.created_at\
      \ FROM quiz qz, user_answer ua WHERE qz.quiz_id = ua.quiz_id\
      \ AND ua.user_id=?" (Only user_id) :: IO [Quiz]
    
getAllQuizzesAnswers :: String -> IO [QuizAnswer]
getAllQuizzesAnswers user_id = do
    conn <- open dbPath
    query conn "SELECT q.quiz_id, q.name, q.topic, ua.user_answer_id, \
    \ua.score, ua.rating, ua.created_at FROM quiz q, user_answer ua \
    \WHERE q.quiz_id = ua.quiz_id AND ua.user_id = ?" (Only user_id) :: IO [QuizAnswer]

-- retorna todos os quizzes que o usuário respondeu, porém sem repetir o quiz
getAllQuizzesAnswersUnique :: String -> IO [Quiz]
getAllQuizzesAnswersUnique user_id = do
    conn <- open dbPath
    query conn "SELECT DISTINCT q.quiz_id,q.name,q.topic,q.user_id,q.created_at \
      \FROM quiz q, user_answer ua WHERE q.quiz_id = ua.quiz_id AND \
      \ua.user_id = ?" (Only user_id) :: IO [Quiz]

updateQuiz:: Quiz -> IO()
updateQuiz quiz = do
      conn <- open dbPath
      execute conn "UPDATE quiz SET name = ?, topic = ? WHERE quiz_id = ?"
        (getName quiz :: String,getTopic quiz, getIdQuiz quiz :: String)

deleteQuiz :: String -> IO()
deleteQuiz quizId = do
    conn <- open dbPath
    execute_ conn "PRAGMA foreign_keys = ON"
    execute conn "DELETE FROM quiz WHERE quiz_id = ?" (Only quizId)
