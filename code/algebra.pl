

d(Y,X,0):-
        var(Y),var(X),
        numbervars(aTerm(Y,X), 0, _),
        Y\=X,!.
d(X,X,1):-var(X),!.
d(C,_,0):-atom(C),!.
d(N,_,0):-number(N),!.

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
