module Utils.Util where

import System.IO

getLineWithMessage:: String -> IO String
getLineWithMessage message = do
    putStr message
    hFlush stdout
    getLine