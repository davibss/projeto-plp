module Utils.Util where
import System.IO
import Data.UUID
import Data.UUID.V4
import Database.SQLite.Simple
import Control.Monad.IO.Class ()
import System.Console.Haskeline
    ( defaultSettings,
      getInputLineWithInitial,
      getPassword,
      runInputT )
import Data.Maybe
import qualified Control.Monad.Catch
import Data.Char (ord)
import Crypto.BCrypt
import Data.ByteString.Char8 (unpack,pack)
import qualified Data.ByteString as BL
import qualified Data.String as BLU
import Data.Time.Clock
import Data.Time
import Prelude hiding (catch)
import System.Directory
import Control.Exception
import System.IO.Error hiding (catch)
import Web.Browser (openBrowser)
import Numeric

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

-- função para retornar uma string de uma Maybe
getMaybeString :: Maybe String -> String
getMaybeString = fromMaybe "Not Found"

-- função para retornar um Int de uma Maybe String
getMaybeInt :: Maybe String -> Int
getMaybeInt maybe = read $ fromMaybe "0" maybe

-- função para retornar um string com 1 caractere
-- isso o Char aparecer como 'a' no output
charToString :: Char -> String
charToString c = [c]

-- retorna a posição de um caractere tomando como base a lista ['a'..'z']
charIndex :: String -> Int
charIndex c = ord (head c) - 97

-- função para desenhar as bordas do menu
printBorderTerminal:: IO ()
printBorderTerminal = putStrLn $ concat (replicate 72 "-")

-- função que implementa um getLine com permissão para alterar um conteúdo passado
-- getAlterLine :: (MonadIO m, Control.Monad.Catch.MonadMask m) => String -> String -> m (Maybe String)
getAlterLine attr value = runInputT defaultSettings $ getInputLineWithInitial attr (value, "")

-- getline para senha com máscara '*'
getPasswordInput :: String -> IO String
getPasswordInput message = run where
    run :: IO String
    run = do
        password <- runInputT defaultSettings $ do
            getPassword (Just '*') message
        return $ fromMaybe "Not found" password

-- função para retornar um ByteString de uma string
lazyByteString :: String -> BL.ByteString
lazyByteString = BLU.fromString

-- função para criar um hash a partir de uma string
passwordHashString :: String -> IO String
passwordHashString password = do
    let p = Data.ByteString.Char8.pack
    hash <- hashPasswordUsingPolicy fastBcryptHashingPolicy  (p password)
    return $ unpack $ fromMaybe (lazyByteString "Not found") hash

-- função que valida um hash e uma string qualquer
passwordValidate :: String -> String -> Bool
passwordValidate password hashedPassword =
    validatePassword (pack hashedPassword) (pack password)

-- calcula a pontuação total a partir de uma data inicial,
-- data final, total de segundos e dificuldade
calculateScore :: UTCTime -> UTCTime -> Int -> Int -> Double
calculateScore startTime endTime totalSeconds difficulty = do
    let difference = realToFrac (diffUTCTime endTime startTime)
    let difficultyScore = fromIntegral $ 10 * (difficulty + 1)
    let division = difference/fromIntegral totalSeconds
    if division <= 1 then
        difficultyScore * ((1 - division) + 1)
    else 0

openFormulaInBrowser :: String -> IO ()
openFormulaInBrowser formula = do
    file <- getCurrentDirectory
    let filePath = file++"/src/HTMLIO/formulaQuestao.html"
    handle <- openFile (file++"/src/HTMLIO/inputHtml.txt") ReadMode
    contents <- hGetContents handle
    let firstHtml = contents
    let secondHtml = "</p></body></html>"
    let result = firstHtml++formula++secondHtml
    writeFile filePath result
    let urlOutput = "file:///"++file++"/src/HTMLIO/formulaQuestao.html"
    result <- openBrowser urlOutput
    hClose handle
    return ()

removeIfExists :: FilePath -> IO ()
removeIfExists fileName = removeFile fileName `catch` handleExists
  where handleExists e
          | isDoesNotExistError e = return ()
          | otherwise = Control.Exception.throwIO e


formatFloatN :: RealFloat a => a -> Int -> String
formatFloatN floatNum numOfDecimals = showFFloat (Just numOfDecimals) floatNum ""
