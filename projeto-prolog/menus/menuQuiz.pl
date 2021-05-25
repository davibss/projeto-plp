:- module(menuQuiz, [menuQuiz/1]).

:- use_module('../utils/util.pl',
    [readLineText/2, 
    printBorderTerminal/0, 
    clearScreen/0,
    updateAttribute/3,
    take/3
    ]).
:- use_module('../controllers/quizController.pl',
    [createQuiz/4,
    getAllQuizzes/1,
    printQuizzes/2,
    getAllMyQuizzes/2,
    deleteQuiz/1,
    printQuiz/1,
    updateQuiz/3,
    getAllQuizzesWithQuestions/1,
    getAllUserAnsweredQuizzes/2,
    getAllUserAnsweredQuizzesUnique/2
    ]).

:- use_module('../controllers/userController.pl',
    [
        getUserById/2,
        updateUser/3,
        getUserPointsById/2
    ]).

:- use_module('../controllers/questionController.pl',
    [
        createQuestion/6,
        updateQuestionRightAnswer/2,
        getAllQuestions/2,
        printQuestions/2
    ]).

:- use_module('../controllers/answersController.pl',
    [
        createAnswer/2,
        getAllAnswers/2
    ]).

:- use_module('./menuQuestion.pl',[menuQuestion/1]).

:- use_module('./menuResolveQuiz.pl',[menuResolveQuiz/2]).

menuQuiz(UserID) :-
    clearScreen,
    printBorderTerminal,
    getUserById(UserID,User),
    User = row(_,Name,_,_),
    getUserPointsById(UserID,Row), Row = row(Points),
    (Points \= '' -> UserPoints = Points ; UserPoints = 0),
    format('~w, ~1f pontos\n',[Name,UserPoints]),
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
    menuQuizOpc(Opc, UserID), !,
    Opc \= "99" -> menuQuiz(UserID) ; !.

menuQuizOpc("1", UserId) :- 
    clearScreen,
    printBorderTerminal,
    readLineText("Nome do Quiz> ", Name),
    readLineText("Tópico do Quiz> ", Topic),
    createQuiz(Name,Topic,UserId,_),
    readLineText("Quiz cadastrado, Enter para voltar...", _).

menuQuizOpc("2",UserId) :-
    clearScreen,
    printBorderTerminal,
    getAllMyQuizzes(UserId,Quizzes),
    length(Quizzes, Length),
    (Length =:= 0 -> writeln("Não há quizzes cadastrados.") ; printQuizzes(Quizzes,1)),
    printBorderTerminal,
    readLineText("Selecione um quiz pelo número para editar, Enter para sair> ", QOpc),
    (QOpc \= "" -> 
        length(Quizzes, QSize), number_codes(NOpc, QOpc), 
        checkQuizInterval(NOpc,QSize,Quizzes)
        ) ; !.

menuQuizOpc("3",UserId) :-
    clearScreen,
    printBorderTerminal,
    getAllQuizzesWithQuestions(Quizzes),
    printQuizzes(Quizzes,1),
    printBorderTerminal,
    readLineText("Selecione um quiz pelo número para resolver, Enter para sair> ", QOpc),
    (QOpc \= "" -> 
        number_codes(NOpc, QOpc), QuizIndex is NOpc - 1,
        (nth0(QuizIndex, Quizzes, Quiz) -> menuResolveQuiz(Quiz,UserId); 
            readLineText("Quiz não encontrado. Enter para voltar...", _))
        ) ; !.

menuQuizOpc("5",UserId) :- 
    getUserById(UserId,User),
    User = row(_,Name,Email,_),
    writeln("Digite novos atributos, se não quiser alterar, aperte Enter"),
    readLineText("Novo Nome> ",NewName),
    readLineText("Novo Email> ",NewEmail),
    ((NewName \= "" ; NewEmail \= "") ->
        updateAttribute(Name,NewName,UpdatedName),
        updateAttribute(Email,NewEmail,UpdatedEmail),
        updateUser(UserId,UpdatedName,UpdatedEmail),
        readLineText("Usuário alterado. Enter para voltar...",_)) ; 
        readLineText("Nada a alterar. Enter para voltar...",_).

menuQuizOpc("6",UserId) :-
    clearScreen,
    printBorderTerminal,
    readLineText("Tópico que deseja buscar> ",Topic),
    printBorderTerminal,
    getAllUserAnsweredQuizzesUnique(UserId,Quizzes),
    appendQuestions(Quizzes,AllQuestions),
    printQuestions(AllQuestions,1),
    length(AllQuestions, TotalQuestions),
    printBorderTerminal,
    readLineText("Quantas questões deve ter o seu quiz?> ", NQuestions),
    number_string(NQuestionsInt, NQuestions),
    ((NQuestionsInt > 0, NQuestionsInt =< TotalQuestions) -> 
        creatingSuperQuiz(AllQuestions,NQuestionsInt,Topic,UserId) ; 
        readLineText("Número fora do intervalo. Enter para voltar...",_)).

menuQuizOpc("99", _) :- !.
menuQuizOpc(_, _) :- readLineText("Opção não encontrada. Enter para voltar...", _).

checkQuizInterval(NOpc, Size, Quizzes) :- 
    NOpc > 0, NOpc =< Size, 
    Index is NOpc -1, nth0(Index, Quizzes, Quiz),
    menuQuizSelected(Quiz).
checkQuizInterval(_, _, _, _, _) :- readLineText("Quiz fora do intervalo, Enter para voltar...",_).

menuQuizSelected(Quiz) :-
    clearScreen,
    printQuiz(Quiz),
    printBorderTerminal,
    writeln("1 - Ver questões"),
    writeln("2 - Alterar quiz"),
    writeln("0 - Deletar quiz"),
    printBorderTerminal,
    readLineText("Selecione uma opção ou pressione Enter para voltar> ", Opc),
    menuQuizSelectedOpt(Opc,Quiz).

menuQuizSelectedOpt("1",Quiz) :- 
    Quiz = row(QuizId,_,_,_,_),
    menuQuestion(QuizId).

menuQuizSelectedOpt("2",Quiz) :-
    Quiz = row(QuizId,Name,Topic,_,_), 
    clearScreen,
    printQuiz(Quiz),
    printBorderTerminal,
    writeln("Digite um novo atributo se quiser alterar, se não apenas dê enter..."),
    printBorderTerminal,
    readLineText("Nome> ",NewName),
    readLineText("Tópico> ",NewTopic),
    updateAttribute(Name,NewName,UpdatedName),
    updateAttribute(Topic,NewTopic,UpdatedTopic),
    ((NewName \= "" ; NewTopic \= "") ->
        updateQuiz(QuizId, UpdatedName, UpdatedTopic), 
        readLineText("Quiz alterado. Enter para voltar...",_)) ; 
        readLineText("Nada a alterar. Enter para voltar...",_). 

menuQuizSelectedOpt("0",Quiz) :- 
    Quiz = row(QuizId,_,_,_,_),
    deleteQuiz(QuizId),
    readLineText("Quiz deletado. Enter para voltar...",_).

menuQuizSelectedOpt("",_) :- !.
menuQuizSelectedOpt(_,_) :- readLineText("Opção não encontrada. Enter para voltar...", _).

appendQuestions([],[]).
appendQuestions([H|T],TotalQuestions) :-
    H = row(QuizId,_,_,_,_),
    getAllQuestions(QuizId,Questions),
    appendQuestions(T,TotalQuestionsN),
    append(Questions,TotalQuestionsN,TotalQuestions).

creatingSuperQuiz(Questions,TotalQuestionsN,Topic,UserId) :- 
    random_permutation(Questions, Permutation),
    take(TotalQuestionsN,Permutation,NewQuestions),
    readLineText("Nome do seu Super Quiz> ",NameQuiz),
    writeln("Criando super quiz, aguarde..."),
    createQuiz(NameQuiz,Topic,UserId,UUIDQuiz),
    creatingQuestionsSuperQuiz(UUIDQuiz,NewQuestions),
    readLineText("Super quiz cadastrado! Enter para voltar...",_).

creatingQuestionsSuperQuiz(_,[]).
creatingQuestionsSuperQuiz(QuizId,[H|T]) :-
    H = row(OldQuestionId,Formulation,DifficultyN,Duration,RightAnswer,_,TypeQuestion),
    createQuestion(Formulation, DifficultyN, Duration, TypeQuestion, QuizId, QuestionId),
    updateQuestionRightAnswer(QuestionId,RightAnswer),
    getAllAnswers(OldQuestionId,Answers),
    creatingAnswersSuperQuiz(Answers,QuestionId),
    creatingQuestionsSuperQuiz(QuizId,T).   

creatingAnswersSuperQuiz([], _).
creatingAnswersSuperQuiz([H|T], NewQuestionId) :-
    H = row(_,Text,_),
    createAnswer(Text,NewQuestionId),
    creatingAnswersSuperQuiz(T,NewQuestionId).
