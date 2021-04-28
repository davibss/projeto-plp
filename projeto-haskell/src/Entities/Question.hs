module Entities.Question where
    newtype NoQuotes = NoQuotes String
    instance Show NoQuotes where show (NoQuotes str) = str

    data Question = Question {
        question_id:: String,
        formulation:: String,
        difficulty:: Int,
        time:: Int,
        right_answer:: Maybe String,
        quiz_id:: String
    }

    getId :: Question -> String
    getId = question_id
    instance Show Question where
        show (Question id formulation difficulty time rightAnswer quizId) =
            show (NoQuotes formulation)