module Entities.Question where
    newtype NoQuotes = NoQuotes String
    instance Show NoQuotes where show (NoQuotes str) = str

    data Question = Question {
        question_id:: String,
        formulation:: String,
        time:: Int,
        right_answer:: Maybe String,
        quiz_id:: String
    }

    instance Show Question where
        show (Question id formulation time rightAnswer quizId) =
            show (NoQuotes formulation)