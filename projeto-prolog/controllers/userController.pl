:- module(userController, 
    [
        createUser/3,
        getUserById/2,
        getUserByEmail/2,
        updateUser/3
    ]).

:- use_module( library(prosqlite) ).

createUser(Name,Email,Password) :- 
    sqlite_connect( 'database/quiz-database.sqlite', db),
    uuid(UserUUID),
    crypto_password_hash(Password,HashPassword),
    format(atom(Query), "INSERT INTO user (user_id,name,email,password) VALUES ('~w','~w','~w','~w');",
    [UserUUID,Name,Email,HashPassword]),
    sqlite_query( db, Query, _),
    sqlite_disconnect( db ).

getUserById(UserId, User) :- 
    sqlite_connect( 'database/quiz-database.sqlite', db),
    format(atom(Query), "SELECT * FROM user WHERE user_id = '~w';",[UserId]),
    sqlite_query(db, Query, User),
    sqlite_disconnect( db ).

getUserByEmail(Email, User) :-
    sqlite_connect( 'database/quiz-database.sqlite', db),
    format(atom(Query), "SELECT * FROM user WHERE email = '~w';",[Email]),
    sqlite_query(db, Query, User),
    sqlite_disconnect( db ).

updateUser(UserId,Name,Email) :-
    sqlite_connect( 'database/quiz-database.sqlite', db),
    format(atom(Query), "UPDATE user SET name = '~w', email = '~w' WHERE user_id = '~w';",
        [Name, Email, UserId]),
    sqlite_query(db, Query, _),
    sqlite_disconnect( db ).
