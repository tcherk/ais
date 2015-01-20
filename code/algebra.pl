

d(Y,X,0):-var(Y),var(X),!.
d(X,X,1):-var(X),!.
d(C,_,0):-atom(C),!.
