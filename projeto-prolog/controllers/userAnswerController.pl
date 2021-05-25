:- module(userAnswerController, 
    [
        createUserAnswer/6,
        createUserAnswerQuestion/4,
        getAllAnswersQuizFromUser/4,
        printAllAnswers/2
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

getAllAnswersQuizFromUser(UserId,QuizId,UserAnswerId, Answers) :-
    format(atom(Query), "SELECT (uaq.user_answer_id || '-' || uaq.question_id) as id,
        q.formulation, q.right_answer,uaq.markedAnswer,
        uaq.timeSpent FROM user_answer ua, question q, user_answer_question uaq
        WHERE ua.user_answer_id=uaq.user_answer_id AND
        uaq.question_id=q.question_id
        AND ua.user_id='~w' AND ua.quiz_id='~w' AND ua.user_answer_id='~w';",
        [UserId,QuizId,UserAnswerId]),
    findall( Row, sqlite_query(db, Query, Row), Answers ).

printAllAnswers([],_).
printAllAnswers([H|T],Index) :-
    H = row(_,Formulation,RightAnswer,MarkedAnswer,TimeSpent),
    format('~d - Enunciado: ~w, Resposta certa: ~w, Resposta marcada: ~w, Tempo Gasto: ~ds\n',
        [Index,Formulation,RightAnswer,MarkedAnswer,TimeSpent]),
    NIndex is Index + 1,
    printAllAnswers(T,NIndex).
