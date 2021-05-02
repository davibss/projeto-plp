{-# LANGUAGE OverloadedStrings #-}
module Controller.UserController where
import Entities.User ( getId, User(User, name, email) )
import Database.SQLite.Simple
import Database.SQLite.Simple.FromRow
import Utils.Util
import Database.SQLite.Simple.Types
import Data.Maybe (fromMaybe)

newtype TotalScore = TotalScore {points :: Maybe Double}

newtype NoQuotes = NoQuotes String
instance Show NoQuotes where show (NoQuotes str) = str

instance FromRow User where
  fromRow = User  <$> field
                  <*> field
                  <*> field
                  <*> field

instance FromRow TotalScore where
    fromRow = TotalScore <$> field

instance Show TotalScore where
    show (TotalScore points) = show $ NoQuotes $ formatFloatN (fromMaybe 0.0 points) 2

addUser :: String -> String -> String -> IO ()
addUser name email password = do
    conn <- open dbPath
    uuidUser <- getRandomUUID
    passwordHash <- passwordHashString password
    execute conn "INSERT INTO user (user_id,name,email,\
        \password) VALUES (?,?,?,?)"
        [uuidUser,name,email,passwordHash]

getUserById :: String -> IO [User]
getUserById user_id = do
    conn <- open dbPath
    query conn "SELECT * FROM user WHERE user_id = ?"  (Only user_id) :: IO [User]

-- função que retorna lista de usuários com email igual ao passado
getUserByEmail :: String -> IO [User]
getUserByEmail email = do
    conn <- open dbPath
    query conn "SELECT * FROM user WHERE email = ?"  (Only email) :: IO [User]

getUserPointsById :: String -> IO TotalScore
getUserPointsById user_id = do
    conn <- open dbPath
    [result] <- query conn "SELECT SUM(score) FROM user_answer WHERE user_id = ?"
        (Only user_id) :: IO [TotalScore]
    return result

updateUser:: User -> IO()
updateUser user = do
      conn <- open dbPath
      execute conn "UPDATE user SET name = ?, email = ? WHERE user_id = ?"
        (name user :: String,email user,getId user)
