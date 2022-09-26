edge(a,b).
edge(b,c).
edge(c,d).
edge(c,e).
edge(c,f).
edge(d,g).
edge(e,h).
edge(f,k).
edge(k,l).
edge(g,i).
edge(h,i).
edge(i,j).
edge(n,o).


node(A):-edge(A,_).
node(B):-edge(_,B).

single_path(X,X,cons(empty)) :- node(X).
single_path(X,J,cons(X,T,J,L)) :- edge(X,T), single_path(T,J,L).

decompose(X,J,T):-single_path(X,J,cons(X,T,J,L)).

track(X,J,A,B):-decompose(X,J,T),decompose(A,J,B).
%track(X,J,A,B):-decompose(X,J,T),track(),

test(X,J,A,B) :- track(X,J,A,B),X=a,J=g.
test2(X,J,A) :- single_path(X,J,A),X=a,J=g.

endpoint(X,H):-node(X),H==0,H=#count{C:edge(X,C)}.
startpoint(X,H):-node(X),H==0,H=#count{C:edge(C,X)}.

startend(X,J,A,B) :- track(X,J,A,B),startpoint(X,_),endpoint(J,_).

intersection(A,B,C,D,E,F):-startend(A,B,C,D),startend(E,F,C,D),A!=E.
intersection(A,B,C,D,E,F):-startend(A,B,C,D),startend(E,F,C,D),B!=F.
%intersection(A,B,C,D,A,B):-startend(A,B,C,D),startend(A,B,C,D).

independent(X,J,A,B):-startend(X,J,A,B), not intersection(_,_,A,B,_,_).

%independent_node(X):-independent(_,_,X,_).
%independent_node(X):-independent(_,_,_,X).
%independent_edge(X,Y):-independent(_,_,X,Y).



independent_cluster(X,X,cons(empty)) :- independent_node(X).
independent_cluster(X,J,cons(X,T,J,L)) :- independent_edge(X,T), independent_cluster(T,J,L).

%intersection_node(X):-intersection(_,_,X,_,_,_).
%intersection_node(X):-intersection(_,_,_,X,_,_).
intersection_edge(X,Y):-intersection(_,_,X,Y,_,_).

intersection_cluster(X,X,cons(empty)) :- intersection_node(X).
intersection_cluster(X,J,cons(X,T,J,L)) :- intersection_edge(X,T), intersection_cluster(T,J,L).


ancestor(Y,X) :- edge(X,Y).
ancestor(X,Z) :- ancestor(X,Y),ancestor(Y,Z).

ca(X,Y,Z) :- ancestor(X,Z),ancestor(Y,Z),X<Y.

merge(X):-edge(X,B),edge(Y,B),X!=Y.

test3(X,Y,Z):-ca(X,Y,Z),X=a.

common_ancestor(X,X,Y) :- edge(X, Y), X != Y.
common_ancestor(Y,X,Y) :- edge(Y, X), X != Y.
common_ancestor(Z,X,Y) :- edge(Z, X), edge(Z, Y), X != Y.

intersect_end(X,Y,Z) :- endpoint(X,_),endpoint(Y,_),X<Y,ca(X,Y,Z).
%intersect_end(A,B,B):-decompose(A,B,C),merge(B).
intersect_end(X,Y,Z) :- merge(X),merge(Y),X!=Y,ca(X,Y,Z).
intersect_end(X,Y,Z) :- endpoint(X,_),merge(Y),X!=Y,ca(X,Y,Z).


intersection_node(X):-intersect_end(_,_,X).

independent_node(N):-node(N), not intersect_end(_,_,N).

independent_edge(X,Y):-edge(X,Y),independent_node(X),independent_node(Y),X!=Y.

%test(A,B,C):-ca(A,B,C),A=g,B=j.
#show test/3.
all_ca_node(A):-ca(A,_,_).
all_ca_node(A):-ca(_,A,_).
not_ca(A):-node(A),not all_ca_node(A).
#show not_ca/1.


endpoint(X,H):-node(X),H==0,H=#count{C:edge(X,C)}.
startpoint(X,H):-node(X),H==0,H=#count{C:edge(C,X)}.
splitpoint(X,H):-node(X),H>1,H=#count{C:edge(X,C)}.
mergepoint(X,H):-node(X),H>1,H=#count{C:edge(C,X)}.

test(A,B,C):-ca(A,B,C),splitpoint(A,_),endpoint(B,_).
test(A,B,C):-ca(A,B,C),splitpoint(A,_),splitpoint(B,_).

#show startpoint/2.
#show endpoint/2.
#show splitpoint/2.


%#show common_ancestor/3.
%#show intersect_end/3.
%#show merge/1.
%#show independent_node/1.
%#show independent_edge/2.
%#show intersection_node/1.
%#show ancestor/2.
#show ca/3.
%#show test3/3.

%#show track/4.
%#show test/4.
%#show test2/3.
%#show startend/4.
%#show intersection/6.
%#show independent/4.
%#show endpoint/2.
%#show startpoint/2.
%#show independent_cluster/3.
%#show intersection_cluster/3.
%#show single_path/3.

