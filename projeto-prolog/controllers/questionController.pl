:- module(questionController, 
    [
        createQuestion/6,
        updateQuestionRightAnswer/2,
        getAllQuestions/2,
        updateQuestion/5,
        deleteQuestion/1,
        printQuestions/2,
        printQuestion/1
    ]).

:- use_module( library(prosqlite) ).

% dificuldade
difficulty(0,"Fácil").
difficulty(1,"Média").
difficulty(2,"Difícil").

createQuestion(Formulation, Difficulty, Duration, TypeQuestion, QuizId, QuestionId) :-
    uuid(QuestionUUID),
    format(atom(Query), "INSERT INTO question (question_id,formulation,difficulty,time,type_question,quiz_id) VALUES ('~w','~w',~d,~d,~d,'~w');",
        [QuestionUUID,Formulation,Difficulty,Duration,TypeQuestion,QuizId]),
    sqlite_query( db, Query, _),
    QuestionId = QuestionUUID.

updateQuestionRightAnswer(QuestionId, RightAnswer) :-
    format(atom(Query), "UPDATE question SET right_answer = '~w' WHERE question_id = '~w'",
        [RightAnswer, QuestionId]),
    sqlite_query( db, Query, _).

getAllQuestions(QuizId,Questions) :-
    format(atom(Query), "SELECT * from question WHERE quiz_id = '~w';",[QuizId]),
    findall( Row, sqlite_query(db, Query, Row), Questions ).

updateQuestion(QuestionId, Formulation, Difficulty, Duration, RightAnswer) :-
    format(atom(Query), "UPDATE question SET formulation = '~w', difficulty = ~d, time = ~d, right_answer = '~w' WHERE question_id = '~w';",
        [Formulation,Difficulty,Duration,RightAnswer,QuestionId]),
    sqlite_query(db, Query, _).

deleteQuestion(QuestionId) :-
    format(atom(Query), "DELETE FROM question WHERE question_id = '~w';",[QuestionId]),
    sqlite_query(db, 'PRAGMA foreign_keys = ON;',_),
    sqlite_query(db, Query, _).

printQuestion(Question) :- 
    Question = row(_,Formulation,DifficultyN,Duration,_,_,_),
    difficulty(DifficultyN,Difficulty),
    format('Enunciado: ~w, Dificuldade: ~w, Duração: ~ds\n',
        [Formulation,Difficulty,Duration]).

% formato da entrada: [row(QuestionId,Formulation,Difficulty,Duration,RightAnswer,QuizId,Type)]
printQuestions([],_).
printQuestions([H|T],Index) :-
    H = row(_,Formulation,DifficultyN,Duration,_,_,_),
    difficulty(DifficultyN,Difficulty),
    format('~d - Enunciado: ~w, Dificuldade: ~w, Duração: ~ds\n',
        [Index,Formulation,Difficulty,Duration]),
    NIndex is Index + 1, 
    printQuestions(T, NIndex).
