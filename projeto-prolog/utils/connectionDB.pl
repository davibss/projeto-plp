:- module(connectionDB, [db/0]).

:- use_module( library(prosqlite) ).

db :- sqlite_connect('database/quiz-database.sqlite',db).

:- initialization(db).
