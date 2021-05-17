:- module(answersController, 
    [
        createAnswer/2
    ]).

:- use_module( library(prosqlite) ).

createAnswer(Text, QuestionId) :-
    sqlite_connect( 'database/quiz-database.sqlite', db),
    format(atom(Query), "INSERT INTO answer (text,question_id) VALUES ('~w','~w');",
        [Text,QuestionId]),
    sqlite_query( db, Query, _),
    sqlite_disconnect( db ).