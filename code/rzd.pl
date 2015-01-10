:- use_module(library(prosqlite)).
:- use_module(library(pairs)).
:- use_module(library(http/http_open)).
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



% route2(A,B, Z,Dist):-
%         station(A,_,CA,_),
%         dist1(СA,СB, Z,_),
%         shortest(CA,CB,Node,Dist),
%         station(B,_,CB,_),
%         station(Z,_,Node,_).


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

transdist(A,B,D):-
        station(A,_,CA,1),
        station(B,_,CB,1),
        route(CA,CB,D).

dfs(N, G, [N], 0,_):- N=G.
dfs(N, G, [Z|T], Dist, Depth):-
        Depth>0,
        N\=G,
        transdist(N,Z,D),
        Depth1 is Depth-1,
        dfs(Z,G,T,DT,Depth1),
        Dist is D+DT.


bfs([[Target|T]|_],Target,[Target|T]):-!.
bfs([[X|T]|Ways], Target, S):-
        Target\=X,
        findall([Y,X|T],
                (transdist(X,Y,_), \+ member(Y,[X|T])), L),
        append(Ways,L, NWays),
        bfs(NWays,Target,S).

bf1([_-s(G,[Target|T]) |_],Target,s(G,[Target|T])):-!.
bf1([_-s(G,[X|T])|Ways], Target, S):-
        Target\=X,
        findall(F1-s(G1,[Y,X|T]), after([X|T],G, Y,G1,F1), L),
        append(L, Ways, NWays),
        keysort(NWays,SNWays),
        bf1(SNWays,Target,S).

after([S|R],SG, T,TG,TG):-
        transdist(S,T,D),
        \+ member(T,[S|R]),
        TG is SG + D.

bf(Start, Target, Sol):-
        bf1([0-s(0,[Start])], Target, Sol).

create_route_table:-
        sqlite_query(db, 'DROP TABLE IF EXISTS route', _),
        sqlite_query(db, 'CREATE TABLE IF NOT EXISTS route (a int REFERENCES station (oid), b int REFERENCES station (oid), dist int)', _).

fill_route_table(clear):-
        sqlite_query(db, 'DELETE FROM route', _).

fill_route_table:-
        findroute(A,B),
        % write('Route: '), write(A), write(' with '), write(B),nl,
        shortest(A,B,_,D),
        addroute(A,B,D),
        format('Added: ~w with ~w dist: ~w\n', [A,B,D]),
        fail.

fill_route_table.

addroute(A,B,D):-
        \+ route(A,B,_),
        sqlite_format_query(db, 'INSERT INTO route (a,b,dist) values (~w,~w,~w)'-[A,B,D],_).

addroute(A,B,D):-
        \+ route(B,A,_),
        sqlite_format_query(db, 'INSERT INTO route (a,b,dist) values (~w,~w,~w)'-[B,A,D],_).

findroute(A,B):-
        station(_,_,A,1),
        dist(N,A,_),
        dist(N,B,_), B\=A,
        station(_,_,B,1).

sqlite_query_f(Conn, S-Args, ROW):-
        swritef(Query, S, Args),
        sqlite_query(Conn, Query, ROW).

gstation(Guess, Name):-
        sqlite_query_f(db, 'SELECT name FROM station where name LIKE \'%w%\''-[Guess], row(Name)). %

gstation(Guess, Name, Transit):-
        sqlite_query_f(db, 'SELECT name FROM station where name LIKE \'%w%\' and transit=%w'-[Guess,Transit], %
                       row(Name)).

        % select name from station where name LIKE 'Краснояр%' and transit=1;


geocode(Name):-
        http_open([host('nominatim.openstreetmap.org'),
                   path('/search.php'),
                   search([ q=Name,
                            lang=ru,
                            format=xml
                           ])
                  ],
                  In,
                  []
                 ),
        copy_stream_data(In, user_output),
        close(In).


% http_open([ host('www.example.com'),
%             path('/my/path'),
%             search([ q='Hello world',
%                      lang=en
%                    ])
%           ])
