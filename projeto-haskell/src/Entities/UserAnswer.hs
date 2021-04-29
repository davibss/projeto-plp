module Entities.UserAnswer where
    import Utils.Util (dateStringToUTCTime)
    import Data.List (sortBy)
    data UserAnswer = UserAnswer {
        user_answer_id:: String,
        user_id:: String,
        quiz_id:: String,
        rating:: Int,
        suggestion:: String,
        score:: Double,
        created_at:: String
    }

    instance Eq UserAnswer where
        (==) x y = created_at x Prelude.== created_at y
    instance Ord UserAnswer where
        compare x y = Prelude.compare (dateStringToUTCTime (created_at x))
            (dateStringToUTCTime (created_at y))

    -- função que ordena um array de quizzes pela data, passando como parametro
    -- o tipo de ordenação, se for ASC ordena ascendente, se não descendente.
    sortAnswerByDate :: [UserAnswer] -> String -> [UserAnswer]
    sortAnswerByDate answers ordType = if ordType == "ASC" then
        sortBy compare answers else sortBy (flip compare) answers

    instance Show UserAnswer where
        show (UserAnswer id user_id quiz_id rating suggestion score created_at) =
            "Avaliação: "++show rating++", Pontuação: "++show score