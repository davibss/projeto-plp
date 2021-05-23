:- module(userController, 
    [
        createUser/3,
        getUserById/2,
        getUserByEmail/2,
        updateUser/3
    ]).

:- use_module( library(prosqlite) ).

createUser(Name,Email,Password) :- 
    uuid(UserUUID),
    crypto_password_hash(Password,HashPassword),
    format(atom(Query), "INSERT INTO user (user_id,name,email,password) VALUES ('~w','~w','~w','~w');",
    [UserUUID,Name,Email,HashPassword]),
    sqlite_query( db, Query, _).

getUserById(UserId, User) :- 
    format(atom(Query), "SELECT * FROM user WHERE user_id = '~w';",[UserId]),
    sqlite_query(db, Query, Row),
    User = Row.
    

getUserByEmail(Email, User) :-
    format(atom(Query), "SELECT * FROM user WHERE email = '~w';",[Email]),
    sqlite_query(db, Query, User).

updateUser(UserId,Name,Email) :-
    format(atom(Query), "UPDATE user SET name = '~w', email = '~w' WHERE user_id = '~w';",
        [Name, Email, UserId]),
    sqlite_query(db, Query, _).

