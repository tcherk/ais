num(X):- member(X, [0,1,2,3,4,5,6,7,8,9]).
gen([]).
gen([X|T]) :- num(X), gen(T).

p([A,B,C, D,E,F]):-
        A + B + C =:= D + E + F.

lucky([A,B,C, D,E,F]) :-
        gen([A,B,C, D,E,F]),
        p([A,B,C, D,E,F]).

count(N) :- findall(Ticket,
            lucky(Ticket), Tickets),
        length(Tickets, N).

lucky2([A,B,C, D,E,F]) :-
        gen([A,B,C, D,E]),
        F is A+B+C-D-E,
        num(F).

count2(N) :- findall(Ticket,
            lucky2(Ticket), Tickets),
        length(Tickets, N).

c2(N) :- findall([A,B,C, D,E,F], (gen([A,B,C, D,E]),F is A+B+C-D-E), L),
        length(L, N).

lucky3([A,B,C, D,E,F]) :-
        gen([A,B,C, D]),
        S is A+B+C-D,
        S >= 0, S=<18,
        gen2(S, E,F).

count3(N) :- findall(Ticket, lucky3(Ticket), Tickets),
        length(Tickets, N).

gen2(0,0,0):-!.
gen2(18,9,9):-!.
gen2(N,A,B):-N<10, !, igen(N,A), B is N - A.
gen2(N,A,B):-D is N - 9, Z is 9 - D,
        igen(Z, A1), A is A1 + D, B is N - A.

igen(N,A) :- N>=1, M is N - 1, igen(M, A).
igen(N,N).
