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
