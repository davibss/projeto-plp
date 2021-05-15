:- module(menuQuiz, [menuQuiz/1]).

:- use_module('../utils/util.pl',[readLineText/2, printBorderTerminal/0, clearScreen/0]).
:- use_module('../controllers/quizController.pl',
    [createQuiz/3,getAllQuizzes/1,printQuizzes/2,getAllMyQuizzes/2]).

menuQuiz(UserID) :-
    clearScreen,
    printBorderTerminal,
    writeln("1 - Cadastrar Quiz"),
    writeln("2 - Meus Quizzes"),
    writeln("3 - Resolver Quizzes"),
    writeln("4 - Quizzes Respondidos"),
    writeln("5 - Alterar Usuário"),
    writeln("6 - Criar quiz com histórico"),
    writeln("99 - Deslogar"),
    printBorderTerminal,
    readLineText("Opção> ", Opc),
    menuQuizOpc(Opc, UserID),
    Opc \= "99" -> menuQuiz(UserID) ; !.

menuQuizOpc("1", UserId) :- 
    clearScreen,
    printBorderTerminal,
    readLineText("Nome do Quiz> ", Name),
    readLineText("Tópico do Quiz> ", Topic),
    createQuiz(Name,Topic,UserId),
    readLineText("Quiz cadastrado, Enter para voltar...", _).

menuQuizOpc("2",UserId) :-
    clearScreen,
    printBorderTerminal,
    getAllMyQuizzes(UserId,Quizzes),
    printQuizzes(Quizzes,1),
    printBorderTerminal,
    readLineText("Enter para voltar...", _).

menuQuizOpc("99", _) :- !.
menuQuizOpc(_, _) :- readLineText("Opção não encontrada. Enter para voltar...", _).