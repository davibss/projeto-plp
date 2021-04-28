module Entities.User where
    newtype NoQuotes = NoQuotes String
    instance Show NoQuotes where show (NoQuotes str) = str

    data User = User {
        user_id:: String,
        name:: String,
        email:: String,
        password:: String
    }

    getId :: User -> String
    getId = user_id
    instance Show User where
        show (User userId name email password) =
            show (NoQuotes name)++", "++email