:- module(getPassword,[getPassword/1]).

getPassword(Password) :-
    passwordLoop(0,'',ListCodes),
    filterPass(ListCodes,FilteredListCodes),
    string_codes(String, FilteredListCodes),
    Password = String.

printMask(0). 
printMask(N) :- NN is N-1, write("*"), printMask(NN).

newNumber(0,_,1).
newNumber(N,127,NewN) :- NewN is N - 1.
newNumber(N,_,NewN) :- NewN is N + 1.

passwordLoop(_, 13, []).
passwordLoop(N, _, List) :-
    tty_clear, write("Senha> "),
    (N =\= 0 -> printMask(N) ; !),
    get_single_char(CharCode), 
    newNumber(N,CharCode,NewN),
    passwordLoop(NewN,CharCode,ListN),
    append([CharCode], ListN, NewList), (CharCode =:= 13 -> List = [] ; List = NewList).

filterPass([],[]).
filterPass(EntryList,List) :-
    (nth0(Index,EntryList,127) ->
        RealIndex is Index + 1, 
        nth1(RealIndex,EntryList,_,DeletedList),
        PreviousIndex is Index,
        nth1(PreviousIndex,DeletedList,_,NewDeletedList),
        filterPass(NewDeletedList,ListN), List = ListN
        ; List = EntryList).