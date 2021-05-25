:- module(utils, [
            readLineText/2,
            printBorderTerminal/0,
            clearScreen/0,
            updateAttribute/3,
            openFormulaInBrowser/1,
            calculateScore/5,
            take/3
            ]).

:- use_module('./customizedOpenBrowser.pl',[www_open_url/1]).

% predicado para ler o input de um usuário com texto, sem precisar de .
readLineText(Text, Input) :- 
    write(Text),
    read_string(user_input, "\n", "\t ", _, Input).

% predicado que printa uma borda para o terminal
printBorderTerminal :- repl("-",72,L), atomics_to_string(L, '', A), writeln(A).

% predicado que repete um elemento X, N vezes
repl(X, N, L) :-
    length(L, N),
    maplist(=(X), L).

% predicado para limpar a tela
clearScreen :- write('\e[H\e[2J').

updateAttribute(OldAttribute, "", UpdatedAttribute) :- 
    (\+ string(OldAttribute) -> 
        atom_string(OldAttribute,OldAttrString),
        UpdatedAttribute = OldAttrString ; UpdatedAttribute = OldAttribute).
updateAttribute(_, NewAttribute, UpdatedAttribute) :- UpdatedAttribute = NewAttribute.

openFormulaInBrowser(Formula) :-
    open('./htmlIO/inputHTML.txt', read, Str),
    read_file(Str,Lines),
    close(Str),
    nth0(0, Lines, Text),
    format(atom(HTML),'~w~w</p></body></html>',[Text,Formula]),
    open('./htmlIO/formula.html',write,Stream),
    write(Stream,HTML), nl(Stream),
    close(Stream),
    www_open_url('./htmlIO/formula.html').

read_file(Stream,[]) :-
    at_end_of_stream(Stream).

read_file(Stream,[X|L]) :-
    \+ at_end_of_stream(Stream),
    read(Stream,X),
    read_file(Stream,L).

calculateScore(StartTime,EndTime, Difficulty, MaxSeconds, Score) :-
    Diff is EndTime - StartTime,
    DifficultyInt is 10*(Difficulty + 1),
    Division is Diff/MaxSeconds, 
    Division =< 1 -> Score is DifficultyInt * ((1 - Division) + 1) ; Score = 0.

% copiado da biblioteca hprolog, autores: Tom Schrijvers, Bart Demoen, Jan Wielemaker
take(0, _, []) :- !.
take(N, [H|TA], [H|TB]) :-
    N > 0,
    N2 is N - 1,
    take(N2, TA, TB).