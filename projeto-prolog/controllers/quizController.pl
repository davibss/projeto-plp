:- module(quizController, 
    [createQuiz/3,
     getAllQuizzes/1,
     printQuizzes/2,
     getAllMyQuizzes/2,
     deleteQuiz/1,
     printQuiz/1,
     updateQuiz/3
    ]).

:- use_module( library(prosqlite) ).

% cria um quiz a partir do nome do quiz, tópico do quiz e id do usuário
createQuiz(Name, Topic, UserId) :-
    sqlite_connect( 'database/quiz-database.sqlite', db),
    uuid(QuizUUID),
    format(atom(Query), "INSERT INTO quiz (quiz_id,name,topic,user_id,created_at) VALUES ('~w','~w','~w','~w',datetime('now','localtime'));",
        [QuizUUID,Name,Topic,UserId]),
    sqlite_query( db, Query, _),
    sqlite_disconnect( db ).

% formato do retorno: row(QuizId,Name,Topic,UserId,CreatedAt)
getAllQuizzes(Quizzes) :-
    sqlite_connect( 'database/quiz-database.sqlite', db),
    format(atom(Query), "SELECT * FROM quiz;",[]),
    findall( Row, sqlite_query(db, Query, Row), Quizzes ),
    sqlite_disconnect( db ).

% formato do retorno: [row(QuizId,Name,Topic,UserId,CreatedAt)]
getAllMyQuizzes(UserId,Quizzes) :-
    sqlite_connect( 'database/quiz-database.sqlite', db),
    format(atom(Query), "SELECT * FROM quiz WHERE user_id = '~w';",[UserId]),
    findall( Row, sqlite_query(db, Query, Row), Quizzes ),
    sqlite_disconnect( db ).

updateQuiz(QuizId, NewName, NewTopic) :-
    sqlite_connect( 'database/quiz-database.sqlite', db),
    format(atom(Query), "UPDATE quiz SET name = '~w', topic = '~w' WHERE quiz_id = '~w';",
        [NewName,NewTopic,QuizId]),
    sqlite_query(db, Query, _),
    sqlite_disconnect( db ).

deleteQuiz(QuizId) :-
    sqlite_connect( 'database/quiz-database.sqlite', db),
    format(atom(Query), "DELETE FROM quiz WHERE quiz_id = '~w';",[QuizId]),
    sqlite_query(db, 'PRAGMA foreign_keys = ON;',_),
    sqlite_query(db, Query, _),
    sqlite_disconnect( db ).

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
