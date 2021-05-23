:- module(menuResolveQuiz, [menuResolveQuiz/2]).

:- use_module('../utils/util.pl',
    [
        readLineText/2, 
        printBorderTerminal/0, 
        clearScreen/0,
        updateAttribute/3,
        openFormulaInBrowser/1,
        calculateScore/5
    ]).

:- use_module('../controllers/quizController.pl',
    [
        printQuiz/1
    ]).

:- use_module('../controllers/questionController.pl',
    [
        getAllQuestions/2,
        printQuestions/2,
        printQuestion/1
    ]).

:- use_module('../controllers/answersController.pl',
    [
        getAllAnswers/2
    ]).

:- use_module('../controllers/userAnswerController.pl',
    [
        createUserAnswer/6,
        createUserAnswerQuestion/4
    ]).

typeQuestion(0,"Alternativa  única").
typeQuestion(1,"Verdadeiro/Falso").
typeQuestion(2,"Múltiplas alternativas").

menuResolveQuiz(Quiz,UserId) :-
    Quiz = row(QuizId,_,_,_,_),
    getAllQuestions(QuizId,Questions),
    totalTime(Questions,Total),
    clearScreen,
    printBorderTerminal,
    printQuiz(Quiz),
    format('Duração total: ~ds\n',[Total]),
    printBorderTerminal,
    readLineText("Deseja resolver agora? [s/n]> ",Opc),
    menuResolveQuizOpc(Opc,Questions,QuizId,UserId).

menuResolveQuizOpc("s",Questions, QuizId, UserId) :- 
    menuQuestionResolve(Questions,Response),
    delete_file('./htmlIO/formula.html'),
    clearScreen,
    printBorderTerminal,
    totalScore(Response,TotalScore),
    format('Sua pontuação foi ~1f.\n',[TotalScore]),
    printBorderTerminal,
    readLineText("De 0 a 10, como você avalia o quiz?> ",Rating),
    readLineText("Dê alguma sugestão para poder melhorar o quiz> ",Suggestion),
    number_string(RatingInt, Rating),
    createUserAnswer(UserId,QuizId,RatingInt,Suggestion,TotalScore,UUID),
    createAnswersFromResponse(Response,UUID),
    readLineText("Obrigado pela avaliação. Enter para voltar...",_).
menuResolveQuizOpc(_,_,_,_) :- !.

createAnswersFromResponse([],_).
createAnswersFromResponse([H|T],UserAnswerId) :-
    H = questionAnswer(QuestionId,TimeSpent,Answer,_),
    createUserAnswerQuestion(UserAnswerId,QuestionId,TimeSpent,Answer),
    createAnswersFromResponse(T,UserAnswerId).

menuQuestionResolve([],Response) :- Response = [].
menuQuestionResolve([H|T], Response) :-
    H = row(QuestionId,_,Difficulty,Duration,RightAnswer,_,TypeQuestion),
    term_string(RightAnswer, RightAnswerString),
    clearScreen,
    printBorderTerminal,
    readLineText("Deseja abrir a questão no navegador? [s/n]> ",Opc),
    openQuestion(Opc,H),
    printBorderTerminal,
    printQuestion(H),
    printBorderTerminal,
    typeQuestion(TypeQuestion,TypeQuestionString),
    format('Tipo da questão: ~w\n',[TypeQuestionString]),
    printBorderTerminal,
    get_time(InitTime),
    writeln("Respostas:"),
    getAllAnswers(QuestionId,Answers),
    printAnswers(Answers,0),
    printBorderTerminal,
    readLineText("Sua resposta> ",Answer),
    get_time(EndTime),
    (Answer = RightAnswerString -> calculateScore(InitTime,EndTime,Difficulty,Duration,Score) ; Score = 0),
    Diff is EndTime - InitTime, FloorDiff is floor(Diff),
    ResponseQuestion = questionAnswer(QuestionId,FloorDiff,Answer,Score),
    clearScreen,
    menuQuestionResolve(T, ResponseN),
    append([ResponseQuestion], ResponseN, Response).

totalScore([], TotalScore) :- TotalScore = 0.
totalScore([H|T], TotalScore) :-
    H = questionAnswer(_,_,_,Score),
    totalScore(T,TotalScoreN),
    TotalScore is TotalScoreN + Score.

totalTime([],Total) :- Total = 0.
totalTime([H|T],Total) :- 
    H = row(_,_,_,Duration,_,_,_),
    totalTime(T,TotalN),
    Total is TotalN + Duration.

openQuestion("s",Question) :- 
    Question = row(QuestionId,Formulation,_,_,_,_,_),
    getAllAnswers(QuestionId,Answers),
    makeHtmlTable(Answers,HtmlText),
    format(atom(Formula),'~w~w',[Formulation,HtmlText]),
    openFormulaInBrowser(Formula),
    writeln("Questão aberta no navegador!").
openQuestion(_,_) :- !.

printAnswers([], _).
printAnswers([H|T], Index) :- 
    H = row(_,AnswerText,_),
    IndexChar is Index + 97,char_code(Letter,IndexChar),
    format('~w) ~w\n',[Letter,AnswerText]),
    IndexN is Index + 1,
    printAnswers(T,IndexN).

makeHtmlTable(Answers,HtmlTable) :-
    printAnswerHtml(Answers,0,Text),
    format(atom(HtmlTable),'<p>Alternativas:</p><table style=\"text-align: left;\">~w</table>',
        [Text]).

printAnswerHtml([],_ ,Text) :- Text = "".
printAnswerHtml([H|T], Index ,Text) :-
    H = row(_,AnswerText,_),
    IndexChar is Index + 97,char_code(Letter,IndexChar),
    format(atom(Html),'<tr><td>~w)</td><td>~w</td></tr>',[Letter,AnswerText]),
    IndexN is Index + 1,
    printAnswerHtml(T,IndexN,TextN),
    format(atom(HtmlTotal),'~w~w',[Html,TextN]),
    Text = HtmlTotal.