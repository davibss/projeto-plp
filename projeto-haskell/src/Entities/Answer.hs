module Entities.Answer where
    newtype NoQuotes = NoQuotes String
    instance Show NoQuotes where show (NoQuotes str) = str

    data Answer = Answer {
        answer_id:: Int,
        text:: String,
        question_id:: String
    }

    getAnswerId :: Answer -> Int 
    getAnswerId = answer_id

    getAnswerQuestionId :: Answer -> String
    getAnswerQuestionId = question_id


    instance Show Answer where
        show (Answer id text question_id) =
            show (NoQuotes text)