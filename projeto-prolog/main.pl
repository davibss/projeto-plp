:- use_module('utils/util.pl').
:- use_module('utils/password.pl',[getPassword/1]).
:- use_module('menus/menuQuiz.pl',[menuQuiz/1]).

:- use_module('controllers/userController.pl', 
    [
        createUser/3,
        getUserById/2,
        getUserByEmail/2,
        updateUser/3
    ]).

:- use_module('./utils/connectionDB.pl', [db/0]).

% predicado de entrada para o programa
main :-
    clearScreen,
    printBorderTerminal,
    writeln("1 - Login"),
    writeln("2 - Cadastrar usuário"),
    writeln("99 - Sair"),
    printBorderTerminal,
    readLineText("Opção> ",Opc),
    mainMenuOpc(Opc),
    Opc \= "99" -> main ; halt.

mainMenuOpc("1") :- login, !.
mainMenuOpc("2") :- 
    clearScreen,
    printBorderTerminal,
    writeln("Digite os dados do usuário"),
    printBorderTerminal,
    readLineText("Nome> ",Name),
    readLineText("Email> ",Email),
    getPassword(Password),
    createUser(Name,Email,Password),
    readLineText("\nUsuário cadastrado. Enter para voltar...",_).

mainMenuOpc("99") :- !.
mainMenuOpc(_) :- readLineText("Opção não encontrada. Enter para voltar...", _).

login :-
    clearScreen,
    printBorderTerminal,
    readLineText("Email> ",Email),
    getPassword(Password),
    (getUserByEmail(Email,User) -> 
        User = row(UserId,_,_,HashedPassword), validatePassword(Password,HashedPassword,UserId) ; 
        readLineText("\nUsuário não encontrado. Enter para voltar...", _)).

validatePassword(Password,HashedPassword,UserId) :-
    (crypto_password_hash(Password,HashedPassword) -> menuQuiz(UserId)) ; 
    readLineText("\nSenha incorreta. Enter para voltar...", _).