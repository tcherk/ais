:- use_module(library(prosqlite)).
:- use_module(library(pairs)).

conn:-
        sqlite_connect(rzd, db,
                       [as_predicates(true),table_as(city,city,arity)]).
test(_):-conn,
        fail.

test(1):-
        % sqlite_connect(rzd, db, [as_predicates(true),table_as(city,city,4)]),

        % sqlite_query(db, 'SELECT * FROM city', Row),
        %city(Name, _, _, Coun),
        %write([Name,Coun]),
        nl, fail.

test(2):-
        cityst(Name, Code, Dist),
        station(SName,_,Code,1),
        write([Name,SName,Dist]),nl,fail.

test(route):-
        route('Тайшет', To,Z,Dist),
        write([To,Dist,Z]),nl,fail.

test(tai):-
        station('Тайшет',_,Code, Tp),
        write([Code,Tp]),nl,fail.

test(_):-
        write('Test run!'),nl.

disconn:-
        sqlite_disconnect(db).



route(A,B, Z,Dist):-
        station(A,_,CA,_),
        write('A:'),write(CA),nl,
        dist1(СA,СB, Z,_),
        write('B:'),write(CB),nl,
        shortest(CA,CB,Node,Dist),
        station(B,_,CB,_),
        station(Z,_,Node,_).


dist1(A,B, Node,Dist):-
        dist(Node,A,DA),
        dist(Node,B,DB),
        A\=B,
        Dist is DA+DB.

shortest(A,B, Node,Dist):-
        nonvar(A),nonvar(B),
        findall(D-N, dist1(A,B,N,D), L),!,
        keysort(L, [Dist-Node|_]),!.

% 920002 Тайшет
