:- module(menuAnswer, [menuAnswer/1]).

:- use_module('../utils/util.pl',
    [
        readLineText/2, 
        printBorderTerminal/0, 
        clearScreen/0,
        updateAttribute/3
    ]).

:- use_module('../controllers/questionController.pl',
    [
        printQuestion/1
    ]).

:- use_module('../controllers/answersController.pl',
    [
        createAnswer/2,
        getAllAnswers/2,
        deleteAnswer/1,
        updateAnswer/2
    ]).

menuAnswer(Question) :-
    Question = row(QuestionId,_,_,_,RightAnswer,_,_),
    getAllAnswers(QuestionId,Answers),
    clearScreen,
    printQuestion(Question),
    printBorderTerminal,
    format('Resposta correta: ~w\n',[RightAnswer]),
    printBorderTerminal,
    writeln("Respostas:"),
    length(Answers, SizeAnswers),
    printAnswers(0,SizeAnswers,Answers),
    printBorderTerminal,
    writeln("1 - Adicionar resposta"),
    writeln("2 - Alterar respostas"),
    writeln("3 - Deletar resposta"),
    writeln("Enter - Voltar para o menu"),
    printBorderTerminal,
    readLineText("Opção> ",Opc),
    menuAnswerOpc(Opc,Answers,QuestionId),
    Opc \= "" -> menuAnswer(Question) ; !.

menuAnswerOpc("1",Answers,QuestionId) :- 
    clearScreen,
    writeln("Digite o texto da resposta"),
    printBorderTerminal,
    length(Answers, SizeList),
    IndexChar is SizeList + 97, char_code(Letter,IndexChar),
    format(atom(A),'~w) ',[Letter]),
    readLineText(A,TextAnswer),
    createAnswer(TextAnswer,QuestionId),
    readLineText("Resposta criada. Enter para voltar...",_).

menuAnswerOpc("2",Answers,_) :- 
    clearScreen,
    length(Answers, SizeAnswers),
    printAnswers(0,SizeAnswers,Answers),
    printBorderTerminal,
    readLineText("Selecione uma resposta para alterar> ",AnswerIndex),
    char_code(AnswerIndex,IndexChar), IndexAnswer is IndexChar - 97,
    (nth0(IndexAnswer,Answers,Answer) -> 
        Answer = row(AnswerId,_,_),
        printBorderTerminal,
        readLineText("Nova resposta> ",NewText),
        updateAnswer(AnswerId,NewText),
        readLineText("Resposta alterada. Enter para voltar...",_)) ; 
        readLineText("Número fora do intervalo. Enter para voltar...",_).

menuAnswerOpc("3",Answers,_) :- 
    clearScreen,
    length(Answers, SizeAnswers),
    printAnswers(0,SizeAnswers,Answers),
    printBorderTerminal,
    readLineText("Selecione uma resposta para deletar> ",AnswerIndex),
    char_code(AnswerIndex,IndexChar), IndexAnswer is IndexChar - 97,
    (nth0(IndexAnswer,Answers,Answer) -> 
        Answer = row(AnswerId,_,_),
        deleteAnswer(AnswerId),
        readLineText("Resposta deletada. Enter para voltar...",_)) ; 
        readLineText("Número fora do intervalo. Enter para voltar...",_).

menuAnswerOpc("",_,_) :- !.
menuAnswerOpc(_,_,_) :- readLineText("Opção não encontrada. Enter para voltar...", _).

printAnswers(Total,Total,[]).
printAnswers(Index,Total,[H|T]) :- 
    H = row(_,AnswerText,_),
    IndexChar is Index + 97,char_code(Letter,IndexChar),
    format('~w) ~w\n',[Letter,AnswerText]),
    NIndex is Index + 1, 
    printAnswers(NIndex,Total,T).