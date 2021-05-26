:- module(quizController, 
    [createQuiz/4,
     getAllQuizzes/1,
     printQuizzes/2,
     getAllMyQuizzes/2,
     deleteQuiz/1,
     printQuiz/1,
     updateQuiz/3,
     getAllQuizzesWithQuestions/1,
     getAllUserAnsweredQuizzes/2,
     getAllUserAnsweredQuizzesUnique/2,
     getAllQuizzesAnswers/2,
     printQuizAnswers/2
    ]).

:- use_module( library(prosqlite) ).

% cria um quiz a partir do nome do quiz, tópico do quiz e id do usuário
createQuiz(Name, Topic, UserId, UUIDQuiz) :-
    uuid(QuizUUID),
    format(atom(Query), "INSERT INTO quiz (quiz_id,name,topic,user_id,created_at) VALUES ('~w','~w','~w','~w',datetime('now','localtime'));",
        [QuizUUID,Name,Topic,UserId]),
    sqlite_query( db, Query, _), UUIDQuiz = QuizUUID.

% formato do retorno: row(QuizId,Name,Topic,UserId,CreatedAt)
getAllQuizzes(Quizzes) :-
    format(atom(Query), "SELECT * FROM quiz;",[]),
    findall( Row, sqlite_query(db, Query, Row), Quizzes ).

% formato do retorno: [row(QuizId,Name,Topic,UserId,CreatedAt)]
getAllMyQuizzes(UserId,Quizzes) :-
    format(atom(Query), "SELECT * FROM quiz WHERE user_id = '~w';",[UserId]),
    findall( Row, sqlite_query(db, Query, Row), Quizzes ).

getAllQuizzesWithQuestions(Quizzes) :-
    format(atom(Query), "SELECT DISTINCT qz.quiz_id, qz.name, qz.topic, qz.user_id,qz.created_at 
        FROM quiz qz, question qe WHERE qz.quiz_id = qe.quiz_id;",[]),
    findall( Row, sqlite_query(db, Query, Row), Quizzes ).

getAllUserAnsweredQuizzes(UserId,Quizzes) :-
    format(atom(Query), "SELECT q.quiz_id, q.name, q.topic, ua.user_answer_id,
        ua.score, ua.rating, ua.created_at FROM quiz q, user_answer ua
        WHERE q.quiz_id = ua.quiz_id AND ua.user_id = '~w';",[UserId]),
    findall( Row, sqlite_query(db, Query, Row), Quizzes ).

getAllUserAnsweredQuizzesUnique(UserId,Quizzes) :-
    format(atom(Query), "SELECT DISTINCT q.quiz_id,q.name,q.topic,q.user_id,q.created_at
        FROM quiz q, user_answer ua WHERE q.quiz_id = ua.quiz_id AND
        ua.user_id = '~w';",[UserId]),
    findall( Row, sqlite_query(db, Query, Row), Quizzes ).

getAllQuizzesAnswers(UserId,Quizzes) :-
    format(atom(Query), "SELECT q.quiz_id, q.name, q.topic, ua.user_answer_id,
        ua.score, ua.rating, ua.created_at FROM quiz q, user_answer ua
        WHERE q.quiz_id = ua.quiz_id AND ua.user_id = '~w';",[UserId]),
    findall( Row, sqlite_query(db, Query, Row), Quizzes ).

updateQuiz(QuizId, NewName, NewTopic) :-
    format(atom(Query), "UPDATE quiz SET name = '~w', topic = '~w' WHERE quiz_id = '~w';",
        [NewName,NewTopic,QuizId]),
    sqlite_query(db, Query, _).

deleteQuiz(QuizId) :-
    format(atom(Query), "DELETE FROM quiz WHERE quiz_id = '~w';",[QuizId]),
    sqlite_query(db, Query, _).

printQuiz(Quiz) :- 
    Quiz = row(_,Name,Topic,_,_),
    format('Nome: ~w, Tópico: ~w\n',[Name,Topic]).

% formato da entrada: [row(QuizId,Name,Topic,UserId,CreatedAt)]
printQuizzes([],_).
printQuizzes([H|T],Index) :-
    H = row(_,Name,Topic,_,_),
    format('~d - Nome: ~w, Tópico: ~w\n',[Index,Name,Topic]),
    NIndex is Index + 1, 
    printQuizzes(T, NIndex).

printQuizAnswers([], _).
printQuizAnswers([H|T], Index) :-
    H = row(_,QuizName,QuizTopic,_,Score,Rating,CreatedAt),
    format('~d - Quiz: ~w, Tópico: ~w, Pontuação: ~2f, Avaliação: ~d, Respondeu em: ~w\n',
        [Index,QuizName,QuizTopic,Score,Rating,CreatedAt]),
    NIndex is Index + 1, 
    printQuizAnswers(T, NIndex).
