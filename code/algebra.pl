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

sim(X, X):-
        var(X),!.
sim(E, R):-
        r(E,E1),!,
        sim(E1,R).

sim(E,E).

r(A+B, A):-B=@=0,!.
r(B+A, A):-B=@=0,!.
r(A*B, A):-B=@=1,!.
r(B*A, A):-B=@=1,!.
r(_*B, 0):-B=@=0,!.
r(B*_, 0):-B=@=0,!.
r(A^B, A):-B=@=1,!.
r(A^B, 1):-B=@=0,A\=@=0,!.
r(A/B, A):-B=@=1,!.
r(B/A, A^(-1)):-B=@=1,!.

r([],[]):-!.
r([X|T],[SX|ST]):-!,
        sim(X,SX),
        r(T,ST).

r(E,R):-
        compound(E),
        ground(E),!,
        R is E.

r(E, R):-
        E=..[Op, A, B],
        number(B),
        member(Op, [+,*]),!,
        R=..[Op,B,A].

r(E, R):-
        E=..[Op, E2, C],
        E2=..[Op, A,B],
        number(A), number(B),
        member(Op, [+,*]),!,
        AB is E2,
        R=..[Op,AB,C].

r(E,R):-
        compound(E),
        E=..[F|Args],!,
        r(Args,SArgs),
        R=..[F|SArgs],
                                %\+ unify_with_occurs_check(E,R).
        E\=@=R.

%r(A*B*C, AB*C):-number(A),number(B),AB is !.
