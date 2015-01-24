d(Y,X,1):-var(X),var(Y),
        Y==X,!.

d(Y,X,0):-
        var(Y),var(X),!.

d(C,_,0):-atomic(C),!.

d(U+V,X,DU+DV):-!,
        d(U,X,DU),
        d(V,X,DV).

d(U-V,X,DU-DV):-!,
        d(U,X,DU),
        d(V,X,DV).

d(U*V,X,DU*V+DV*U):-!,
        d(U,X,DU),
        d(V,X,DV).

d(U/V,X,(DU*V-DV*U)/(V^2)):-!,
        d(U,X,DU),
        d(V,X,DV).

d(E,X, DExpF*DExp):-
        E=..[Atom, Exp],
        atom(Atom),!,
        d(Exp,X,DExp),
        df(Atom, Exp, DExpF).

d(E^N,X, N*E^(N1)*DE):-!,
        d(E,X,DE),
        N1 = N-1.

df(sin,X, cos(X)).
df(cos,X, -sin(X)).
df(ln,X, 1/X).
df(exp,X, exp(X)).

sim(E, R):-
        r(E,E1),!,
        sim(E1,R).

sim(E,E).

r(A+0, A). r(0+A, A). r(A*1, A). r(1*A, A).
r(_*0, 0). r(0*_, 0).

r([],[]):-!.
r([X|T],[SX|ST]):-!,
        sim(X,ST),
        r(T,ST).

r(E,R):-
        compound(E),
        ground(E),!,
        R is E.

r(E,R):-
        compound(E),
        E=..[F|Args],!,
        r(Args,SArgs),
        R=..[F|SArgs].
