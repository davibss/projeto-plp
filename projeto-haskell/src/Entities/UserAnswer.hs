module Entities.UserAnswer where
    data UserAnswer = UserAnswer {
        user_answer_id:: String,
        user_id:: String,
        quiz_id:: String,
        rating:: Int,
        suggestion:: String,
        score:: Double
    }

    instance Show UserAnswer where
        show (UserAnswer id user_id quiz_id rating suggestion score) =
            "Avaliação: "++show rating++", Pontuação: "++show score