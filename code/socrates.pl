h(s).
m(X):-h(X).

e(a,b). e(b,c). e(c,f).
e(f,e). e(e,d). e(d,h).
e(f,g). e(g,i). e(i,h).

path(A,B) :- e(A,B).
path(A,B) :- e(A,C), path(C,B).

path(A,B, [A-B]) :- e(A,B).
path(A,B, [A-C|T]) :- e(A,C), path(C,B,T).

path2(A,B, [A,B]) :- e(A,B).
path2(A,B, [A|T]) :- e(A,C), path2(C,B,T).

dfs(V, []):-p(V).
dfs(V, [V-N|T]):- \+ p(V), after(V,N), dfs(N,T).

p(h).
after(X,Y):-e(X,Y); e(Y,X).

dfsl(V, [], _):-p(V).
dfsl(V, [V-N|T], D):- D>0, after(V,N), D1 is D-1, dfsl(N,T, D1).

dfsr(V, [], _):-p(V).
dfsr(V, [V-N|T], Q):- after(V,N), \+ member(N,Q), dfsr(N,T, [N|Q]).

mem(X,[X|_]).
mem(X,[_|T]):-mem(X,T).

bfs([[X|T]|_],[X|T]):-p(X),!.
bfs([[X|T]|Ways], S):-
        findall([Y,X|T],
                (after(X,Y), \+ member(Y,[X|T])), L),
        append(Ways,L, NWays),
        bfs(NWays,S).
