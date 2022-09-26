edge(a,b).
edge(b,c).
edge(b,d).
edge(b,i).
edge(i,j).
edge(j,k).
edge(j,l).
edge(c,e).
edge(d,f).
edge(l,g).
edge(e,g).
edge(f,g).
edge(g,h).


%start_point(a).
%end_point(h).
%end_point(k).


split(B):-edge(B,X),edge(B,Y),X!=Y.
%split(A):-start_point(A).

merge(B):-edge(X,B),edge(Y,B),X!=Y.
%merge(A):-end_point(A).


node(A):-edge(A,_).
node(B):-edge(_,B).

anc(X,Y) :- edge(X,Y). 
anc(X,Y) :- edge(X,Z), anc(Z,Y).

%anc2(X,Y,Y) :- edge(X,Y).
%anc2(X,T,Y) :- edge(X,Z), anc2(Z,T,Y).

%#show anc2/3.

%anc_split(X,Y):-anc(X,Y),split(X).
%anc_merge(X,Y):-anc(Y,X),merge(X).

num(N):- {node(X)} == N. % count nodes
step(1..N) :- num(N). % mark possible steps

path(X,Y,2,cons(X,2,cons(Y,1,empty))) :- edge(X,Y).
path(A,C,NN+1,cons(A,NN+1,L)) :- edge(A,B), path(B,C,NN,L), step(NN+1).

member(X,path(X,Y,N,cons(X,N,L))) :- path(X,Y,N,cons(X,N,L)).
member(Y,path(X,Y,N,cons(X,N,L))) :- path(X,Y,N,cons(X,N,L)).
member(M,path(S,T,NN+1,cons(S,NN+1,cons(Z,NN,L)))) :- member(M,path(Z,T,NN,cons(Z,NN,L))), path(S,T,NN+1,cons(S,NN+1,cons(Z,NN,L))).




track(Y,Z,N,L):- {member(X,path(Y,Z,N,L)):node(X)} == N, path(Y,Z,N,L).
track_split_to_merge(Y,Z,N,L):-track(X,Z,N,L),split(Y),merge(Z).
%track_split_to_merge(Z,Y,N,L):-track(Z,Y,N,L),split(Y),merge(Z).
track_split_to_merge(Y,Z,N,L):-track(Y,Z,N,L),split(Z),start_point(Y).
track_split_to_merge(Y,Z,N,L):-track(Y,Z,N,L),merge(Y),end_point(Z).
track_split_to_merge(Y,Z,N,L):-track(Y,Z,N,L),split(Y),end_point(Z).

%test(Y,Z,A,N) :- track_split_to_merge(Y,Z,N,cons(A,B,C)).


%test_path(X,X) :- node(X).
%test_path(X,J,T,L) :- edge(X,T), single_path(T,J,L).

single_path(X,X,cons(empty)) :- node(X).
single_path(X,J,cons(X,T,J,L)) :- edge(X,T), single_path(T,J,L).

decompose(X,J,T):-single_path(X,J,cons(X,T,J,L)).

compose(A,B,C,E,F):-decompose(A,B,C),decompose(B,E,F).

%thepath(X,J,T,K):-decompose(X,J,T),decompose(T,J,K).
%cons(X,J,K):-cons(X,J,cons(_,J,K)).

test(A,B,C,E,F):-compose(A,B,C,E,F),A=a,E=g.

#show test/5.
#show decompose/3.
#show compose/5.

%#show single_path/3.

possible_path(A,B) :- single_path(A,B,_,_).

min_single_path(A,B,H) :- possible_path(A,B), H = #min{C:single_path(A,B,C,_)}.

test(X,J,Y,L) :- single_path(X,J,Y,L), start_point(X), min_single_path(X,J,Y).

endpoint(X,H):-node(X),H==0,H=#count{C:edge(X,C)}.
startpoint(X,H):-node(X),H==0,H=#count{C:edge(C,X)}.

startend(X,J,L):-single_path(X,J,L),startpoint(X,_),endpoint(J,_).

%intersection(L1,L2):-startend(_,_,L1),startend(_,_,L2),

%#show anc_split/2.
%#show anc_merge/2.
%#show track_split_to_merge/4.
%#show split/1.
%#show merge/1.
%#show test/4.
%#show single_path/3.
%#show test/4.
%#show min_single_path/3.
%#show track/4.
%#show single_path/3.
#show startend/3.
%#show testpath/3.