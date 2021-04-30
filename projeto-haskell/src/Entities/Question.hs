module Entities.Question where
    newtype NoQuotes = NoQuotes String
    instance Show NoQuotes where show (NoQuotes str) = str

    data Question = Question {
        question_id:: String,
        formulation:: String,
        difficulty:: Int,
        time:: Int,
        right_answer:: Maybe String,
        quiz_id:: String,
        type_question:: Int
    }

    getIdQuestion :: Question -> String
    getIdQuestion = question_id
    instance Show Question where
        show (Question id formulation difficulty time rightAnswer type_question quizId) =
            show (NoQuotes formulation)