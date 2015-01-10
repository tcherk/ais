:- use_module(library(prosqlite)).
:- use_module(library(pairs)).
:- use_module(library(http/http_open)).
:- use_module(library(sgml)).
:- use_module(library(option)).

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




geocodequery(Name, Lon, Lat, ID):-
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
        load_xml(In, S, []),
        S=[element(searchresults,_,[_|L])],
        %L=S,
        %copy_stream_data(In, user_output),
        close(In),
        geoplace(L, Lon,Lat,ID).

geoplace(element(place,Attrs,_), Lon, Lat, Id):-
        option(lon(Lon1),Attrs), atom_number(Lon1,Lon),
        option(lat(Lat1),Attrs), atom_number(Lat1,Lat),
        option(place_id(Id),Attrs).

geoplace([X|_], Lon, Lat, Id):-
        geoplace(X, Lon, Lat, Id).
geoplace([_|T], Lon, Lat, Id):-
        geoplace(T, Lon, Lat, Id).

geocode(Station, Lon, Lat, Id):-
        \+ number(Station),
        station(Station, _, Code, _),
        geocode(Code, Lon, Lat, Id).

geocode(Station, Lon, Lat, Id):-
        number(Station),
        geocache(Station, Lon, Lat, Id),!.

geocode(Station, Lon, Lat, Id):-
        number(Station),
        station(Name, _, Station, _),
        geocodequery(Name, Lon, Lat, Id),
        sqlite_query_f(db,
                       'INSERT INTO geocache (station, lon, lat, place_id) values (%w,%w,%w,%w)'-[Station,Lon,Lat,Id],
                       _),!.

create_geocache_table:-
        sqlite_query(db, 'DROP TABLE IF EXISTS geocache', _),
        sqlite_query(db, 'CREATE TABLE IF NOT EXISTS geocache (station int REFERENCES station (oid), lon real, lat real, place_id text)', _).

to_radians(Grad,Rad):-
        Rad is Grad * 3.1415926536/180.0.

geodist(Lon1, Lat1, Lon2, Lat2, Dist):-
        R=6371.0,
        to_radians(Lat1,Phi1), to_radians(Lat2,Phi2),
        DLat is Lat2-Lat1, to_radians(DLat, DPhi),
        DLon is Lon2-Lon1, to_radians(DLon, DLamb),
        DPhi2 is DPhi/2.0,
        DLamb2 is DLamb/2.0,
        A is sin(DPhi2)^2+cos(Phi1)*cos(Phi2)*sin(DLamb2)^2,
        C is 2*atan2(sqrt(A),sqrt(1-A)),
        Dist is R*C.

% var R = 6371; // km
% var φ1 = lat1.toRadians();
% var φ2 = lat2.toRadians();
% var Δφ = (lat2-lat1).toRadians();
% var Δλ = (lon2-lon1).toRadians();

% var a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
%         Math.cos(φ1) * Math.cos(φ2) *
%         Math.sin(Δλ/2) * Math.sin(Δλ/2);
% var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

% var d = R * c;


% run111:-p([element(searchresults,
%                    [timestamp=Sat, 10 Jan 15 08:09:40 +0000,attribution=Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright,querystring=Иркутск-Пассажирский,polygon=false,exclude_place_ids=2635309604,2635309603,more_url=http://nominatim.openstreetmap.org/search?format=xml&exclude_place_ids=2635309604,2635309603&q= %D0%98%D1%80%D0%BA%D1%83%D1%82%D1%81%D0%BA-%D0%9F%D0%B0%D1%81%D1%81%D0%B0%D0%B6%D0%B8%D1%80%D1%81%D0%BA%D0%B8%D0%B9
%                    ],
%                    [,
%                     element(place,
%                             [place_id=2635309604,osm_type=node,osm_id=1500960952,place_rank=30,boundingbox=52.2825847,52.2826847,104.2604838,104.2605838,lat=52.2826347,lon=104.2605338,display_name=Иркутск-Пассажирский, улица Челнокова, Глазково, Иркутск, городской округ Иркутск, Иркутская область, СФО, 664004, Россия,class=railway,type=halt,importance=0.211],
%                             [])
%                    ])
%           ]).




% http_open([ host('www.example.com'),
%             path('/my/path'),
%             search([ q='Hello world',
%                      lang=en
%                    ])
%           ])
