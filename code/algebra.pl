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
