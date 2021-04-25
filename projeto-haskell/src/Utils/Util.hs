module Utils.Util where
import System.IO
import Data.UUID
import Data.UUID.V4
import Database.SQLite.Simple
import Control.Monad.IO.Class
import System.Console.Haskeline
import Data.Maybe
import qualified Control.Monad.Catch

-- caminho para a base de dados
dbPath :: String
dbPath = "database/quiz-database.db"

-- função de conexão com o banco de dados
withConn :: String -> (Connection -> IO ()) -> IO ()
withConn dbName action = do
   conn <- open dbName
   action conn
   close conn

-- função para obter um UUID aleatório
getRandomUUID :: IO String
getRandomUUID = nextRandom >>= (return . toString)

-- função para receber input do usuário após um output
getLineWithMessage:: String -> IO String
getLineWithMessage message = do
    putStr message
    hFlush stdout
    getLine

-- função para desenhar as bordas do menu
printBorderTerminal:: IO ()
printBorderTerminal = putStrLn $ concat (replicate 72 "-")

-- função que implementa um getLine com permissão para alterar um conteúdo passado
-- getAlterLine :: (MonadIO m, Control.Monad.Catch.MonadMask m) => String -> String -> m (Maybe String)
getAlterLine attr value = runInputT defaultSettings $ getInputLineWithInitial attr (value, "")
