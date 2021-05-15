:- use_module('utils/util.pl').
:- use_module('menus/menuQuiz.pl',[menuQuiz/1]).

% auxiliar para cadastrar quizzes
user("1","441f76e1-bce8-4c91-a828-bed67696b3a0").
user("2","2adee2d7-b1a9-4568-afa6-bcb248588962").

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
mainMenuOpc("99") :- !.
mainMenuOpc(_) :- readLineText("Opção não encontrada. Enter para voltar...", _).

% predicado temporário para login, código de login válidos: 1 ou 2
login :-
    clearScreen,
    printBorderTerminal,
    readLineText("Código do usuário> ",Cod),
    user(Cod,UUID) -> menuQuiz(UUID) ; 
        readLineText("Usuário não encontrado. Enter para voltar...", _).