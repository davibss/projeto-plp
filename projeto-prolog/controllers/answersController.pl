:- module(answersController, 
    [
        createAnswer/2,
        getAllAnswers/2,
        deleteAnswer/1,
        updateAnswer/2
    ]).

:- use_module( library(prosqlite) ).

createAnswer(Text, QuestionId) :-
    format(atom(Query), "INSERT INTO answer (text,question_id) VALUES ('~w','~w');",
        [Text,QuestionId]),
    sqlite_query( db, Query, _).

getAllAnswers(QuestionId,Answers) :-
    format(atom(Query), "SELECT * from answer WHERE question_id = '~w';",[QuestionId]),
    findall( Row, sqlite_query(db, Query, Row), Answers ).

updateAnswer(AnswerId, Text) :- 
    format(atom(Query), "UPDATE answer SET text = '~w' WHERE answer_id = '~w';",
        [Text,AnswerId]),
    sqlite_query(db, Query, _).

deleteAnswer(AnswerId) :-
    format(atom(Query), "DELETE FROM answer WHERE answer_id = '~w';",[AnswerId]),
    sqlite_query(db, Query, _).