:- module(utils, [
            readLineText/2,
            printBorderTerminal/0,
            clearScreen/0,
            updateAttribute/3
            ]).

% predicado para ler o input de um usuário com texto, sem precisar de .
readLineText(Text, Input) :- write(Text), read_string(user_input, "\n", "\t ", _, Input).

% predicado que printa uma borda para o terminal
printBorderTerminal :- repl("-",72,L), atomics_to_string(L, '', A), writeln(A).

% predicado que repete um elemento X, N vezes
repl(X, N, L) :-
    length(L, N),
    maplist(=(X), L).

% predicado para limpar a tela
clearScreen :- write('\e[H\e[2J').

updateAttribute(OldAttribute, "", UpdatedAttribute) :- UpdatedAttribute = OldAttribute.
updateAttribute(_, NewAttribute, UpdatedAttribute) :- UpdatedAttribute = NewAttribute.
