:- module(answersController, 
    [
        createAnswer/2,
        getAllAnswers/2,
        deleteAnswer/1,
        updateAnswer/2
    ]).

:- use_module( library(prosqlite) ).

createAnswer(Text, QuestionId) :-
    sqlite_connect( 'database/quiz-database.sqlite', db),
    format(atom(Query), "INSERT INTO answer (text,question_id) VALUES ('~w','~w');",
        [Text,QuestionId]),
    sqlite_query( db, Query, _),
    sqlite_disconnect( db ).

getAllAnswers(QuestionId,Answers) :-
    sqlite_connect( 'database/quiz-database.sqlite', db),
    format(atom(Query), "SELECT * from answer WHERE question_id = '~w';",[QuestionId]),
    findall( Row, sqlite_query(db, Query, Row), Answers ),
    sqlite_disconnect( db ).

updateAnswer(AnswerId, Text) :- 
    sqlite_connect( 'database/quiz-database.sqlite', db),
    format(atom(Query), "UPDATE answer SET text = '~w' WHERE answer_id = '~w';",
        [Text,AnswerId]),
    sqlite_query(db, Query, _),
    sqlite_disconnect( db ).

deleteAnswer(AnswerId) :-
    sqlite_connect( 'database/quiz-database.sqlite', db),
    format(atom(Query), "DELETE FROM answer WHERE answer_id = '~w';",[AnswerId]),
    sqlite_query(db, 'PRAGMA foreign_keys = ON;',_),
    sqlite_query(db, Query, _),
    sqlite_disconnect( db ).