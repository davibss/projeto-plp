module Entities.Quiz where
    import Data.List (sortBy)
    -- import Data.Ord (comparing)
    import Data.Time ()
    import Utils.Util (dateStringToUTCTime)
    newtype NoQuotes = NoQuotes String
    instance Show NoQuotes where show (NoQuotes str) = str

    data Quiz = Quiz {
            quiz_id:: String,
            name:: String,
            topic:: String,
            user_id:: String,
            created_at:: String
    }

    getIdQuiz :: Quiz -> String
    getIdQuiz = quiz_id
    getName :: Quiz -> String
    getName = name
    getTopic :: Quiz -> String
    getTopic = topic


    instance Eq Quiz where
        (==) x y = created_at x Prelude.== created_at y
    instance Ord Quiz where
        compare x y = Prelude.compare (dateStringToUTCTime (created_at x))
            (dateStringToUTCTime (created_at y))

    -- função que ordena um array de quizzes pela data, passando como parametro
    -- o tipo de ordenação, se for ASC ordena ascendente, se não descendente.
    sortByDate :: [Quiz] -> String -> [Quiz]
    sortByDate quizzes ordType = if ordType == "ASC" then
        sortBy compare quizzes else sortBy (flip compare) quizzes

    instance Show Quiz where
        show (Quiz id name topic user_id created_at) = show (NoQuotes name)++
            ", Tópico: "++topic