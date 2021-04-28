module Entities.Quiz where
    newtype NoQuotes = NoQuotes String
    instance Show NoQuotes where show (NoQuotes str) = str

    data Quiz = Quiz {
            quiz_id:: String,
            name:: String,
            topic:: String,
            user_id:: String
    }

    getName :: Quiz -> String
    getName = name
    getTopic :: Quiz -> String
    getTopic = topic

    instance Show Quiz where
        show (Quiz id name topic user_id) = show (NoQuotes name)++", Tópico: "++topic