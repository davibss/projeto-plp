:- module(userAnswerController, 
    [
        createUserAnswer/6,
        createUserAnswerQuestion/4
    ]).

:- use_module( library(prosqlite) ).

createUserAnswer(UserId,QuizId,Rating,Suggestion,Score,UUID) :-
    uuid(UserAnswerUUID),
    format(atom(Query), "INSERT INTO user_answer (user_answer_id,user_id,quiz_id,rating,suggestion,score,created_at) VALUES ('~w','~w','~w',~d,'~w',~f,datetime('now','localtime'));",
        [UserAnswerUUID,UserId,QuizId,Rating,Suggestion,Score]),
    sqlite_query( db, Query, _),
    UUID = UserAnswerUUID.

createUserAnswerQuestion(UserAnswerId, QuestionId, TimeSpent, Answer) :-
    format(atom(Query), "INSERT INTO user_answer_question (user_answer_id,question_id,timeSpent,markedAnswer) VALUES ('~w','~w',~d,'~w')",
        [UserAnswerId,QuestionId,TimeSpent,Answer]),
    sqlite_query( db, Query, _).
