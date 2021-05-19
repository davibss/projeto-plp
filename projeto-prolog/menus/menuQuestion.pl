:- module(menuQuestion, [menuQuestion/1]).

:- use_module('../utils/util.pl',
    [
        readLineText/2, 
        printBorderTerminal/0, 
        clearScreen/0,
        updateAttribute/3
    ]).

:- use_module('../controllers/questionController.pl',
    [
        createQuestion/6,
        updateQuestionRightAnswer/2,
        getAllQuestions/2,
        updateQuestion/5,
        deleteQuestion/1,
        printQuestions/2,
        printQuestion/1
    ]).

:- use_module('../controllers/answersController.pl',
    [
        createAnswer/2
    ]).

:- use_module('./menuAnswer.pl', [menuAnswer/1]).

menuQuestion(QuizId) :-
    clearScreen,
    printBorderTerminal,
    getAllQuestions(QuizId,Questions),
    length(Questions, Length),
    (Length =:= 0 -> writeln("Não há questões cadastradas.") ; printQuestions(Questions,1)),
    printBorderTerminal,
    writeln("1 - Cadastrar questão"),
    writeln("2 - Alterar questão"),
    writeln("3 - Ver respostas"),
    writeln("4 - Deletar questão"),
    writeln("Enter - Voltar para o menu de Quizzess"),
    printBorderTerminal,
    readLineText("Opção> ", Opc),
    menuQuestionOpc(Opc,QuizId, Questions),
    Opc \= "" -> menuQuestion(QuizId) ; !.

menuQuestionOpc("1",QuizId, _) :-
    clearScreen,
    printBorderTerminal,
    readLineText("Enunciado> ", Formulation),
    readLineText("Dificuldade [0-Fácil,1-Média,2-Difícil]> ", Difficulty),
    readLineText("Duração(s) (Mínimo 10s)> ", Duration),
    readLineText("Tipo de questão ([0]-Alternativa única, [1]-V/F, [2]-Múltipla escolha)> ", TypeQuestion),
    number_codes(IntDiff,Difficulty),
    number_codes(IntDuration,Duration),
    number_codes(IntTypeQuestion,TypeQuestion),
    createQuestion(Formulation,IntDiff,IntDuration,IntTypeQuestion,QuizId,QuestionId),
    qtdAnswers(IntTypeQuestion, RightAnswer, QuestionId),
    updateQuestionRightAnswer(QuestionId,RightAnswer),
    readLineText("Questão cadastrada! Enter para voltar...",_).
        
menuQuestionOpc("2",_, Questions):-
    clearScreen,
    printBorderTerminal,
    printQuestions(Questions,1),
    printBorderTerminal,
    readLineText("Selecione uma questão para alterar> ", QIndex), 
    number_codes(IntQIndex, QIndex),
    IndexQuestion is IntQIndex - 1,
    (nth0(IndexQuestion,Questions,Question) -> 
    updateQuestionMenu(Question),
    readLineText("Questão alterada. Enter para voltar...",_)) ; 
    readLineText("Número fora do intervalo. Enter para voltar...",_).

menuQuestionOpc("3",_, Questions) :- 
    clearScreen,
    printBorderTerminal,
    printQuestions(Questions,1),
    printBorderTerminal,
    readLineText("Selecione uma questão para ver as respostas> ", QIndex), 
    number_codes(IntQIndex, QIndex),
    IndexQuestion is IntQIndex - 1,
    (nth0(IndexQuestion,Questions,Question) -> 
    menuAnswer(Question)) ; 
    readLineText("Número fora do intervalo. Enter para voltar...",_).

menuQuestionOpc("4",_, Questions) :- 
    clearScreen,
    printBorderTerminal,
    printQuestions(Questions,1),
    printBorderTerminal,
    readLineText("Selecione uma questão para deletar> ", QIndex), 
    number_codes(IntQIndex, QIndex),
    IndexQuestion is IntQIndex - 1,
    (nth0(IndexQuestion,Questions,Question) -> 
        Question = row(QuestionId,_,_,_,_,_,_),
        deleteQuestion(QuestionId),
        readLineText("Questão deletada. Enter para voltar...",_)) ; 
        readLineText("Número fora do intervalo. Enter para voltar...",_).

menuQuestionOpc("",_, _) :- !.
menuQuestionOpc(_,_,_) :- readLineText("Opção não encontrada. Enter para voltar...", _).

qtdAnswers(0,RightAnswer, QuestionId) :- 
    readLineText("Quantidade de respostas> ",QttAnswers), number_codes(Qtt,QttAnswers),
    createAnswers(0,Qtt, QuestionId),
    readLineText("Resposta correta> ", RightAnswer).
qtdAnswers(1,RightAnswer, QuestionId) :- 
    createAnswers(0,2, QuestionId),
    readLineText("Resposta correta> ", RightAnswer).
qtdAnswers(2,RightAnswer, QuestionId) :- 
    readLineText("Quantidade de respostas> ",QttAnswers), number_codes(Qtt,QttAnswers),
    createAnswers(0,Qtt,QuestionId),
    readLineText("Respostas corretas> ", RightAnswer).

createAnswers(Total,Total,_) :- !.
createAnswers(Index,Total,QuestionId) :- 
    IndexChar is Index + 97,char_code(Letter,IndexChar),
    format(atom(A),'~w) ',[Letter]),
    readLineText(A,AnswerText),
    createAnswer(AnswerText,QuestionId),
    NIndex is Index + 1, 
    createAnswers(NIndex,Total,QuestionId).

updateQuestionMenu(Question) :-
    Question = row(QuestionId,Formulation,Difficulty,Duration,RightAnswer,_,_),
    clearScreen,
    printQuestion(Question),
    printBorderTerminal,
    writeln("Digite um novo atributo se quiser alterar, se não apenas dê enter..."),
    printBorderTerminal,
    readLineText("Enunciado> ", NewFormulation),
    readLineText("Dificuldade [0-Fácil,1-Média,2-Difícil]> ", NewDifficulty),
    readLineText("Duração(s) (Mínimo 10s)> ", NewDuration),
    readLineText("Resposta correta> ", NewRightAnswer),
    updateAttribute(Formulation,NewFormulation,UpdatedFormulation),
    updateAttribute(Difficulty,NewDifficulty,UpdatedDifficulty),
    updateAttribute(Duration,NewDuration,UpdatedDuration),
    updateAttribute(RightAnswer,NewRightAnswer,UpdatedRightAnswer),
    (NewDifficulty \= "" -> number_codes(NDifficulty,UpdatedDifficulty); NDifficulty = Difficulty),
    (NewDuration \= "" -> number_codes(NDuration,UpdatedDuration) ; NDuration = Duration),
    updateQuestion(QuestionId,UpdatedFormulation,NDifficulty,NDuration,UpdatedRightAnswer).
