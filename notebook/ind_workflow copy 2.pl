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
edge(m,n).
%edge(l,p).
%edge(l,q).
%edge(q,r).
%edge(p,s).
%edge(s,j).
%edge(g,gg).
%edge(gg,i).
%edge(h,i).
%edge(i,j).
%edge(n,o).
%dge(j,t).


node(X):-edge(X,_).
node(X):-edge(_,X).

%{ start_point(X): edge(X,_) } == 1.
%{ end_point(X): edge(_,X) } == 1.

%:- start_point(X), #count{C:edge(X,_)} == 1.


endpoint(X,H):-node(X),H==0,H=#count{C:edge(X,C)}.
startpoint(X,H):-node(X),H==0,H=#count{C:edge(C,X)}.
splitpoint(X,H):-node(X),H>1,H=#count{C:edge(X,C)}.
mergepoint(X,H):-node(X),H>1,H=#count{C:edge(C,X)}.

path(X,X):-edge(X,_).
path(X,X):-edge(_,X).
path(X,Z):-edge(X,Y),path(Y,Z).

path_count(X,X,0,cons(empty)) :- node(X).
path_count(X,J,C+1,cons(X,T,J,C,L)) :- edge(X,T), path_count(T,J,C,L).

%cons(A,X,B,C,D,E):-single_path(A,X,_,cons(A,B,C,D,E)).
%cons(A,X,B,C,D,E):-cons(A,X,_,_,_,cons(B,C,_,D,E)).

%decompose(A,J,B,C,D) :- cons(A,J,B,C,D,_).

%test(A,J,B,C,D) :- decompose(A,J,B,C,D),A=c,J=i.

single_path(X,X,cons(empty)) :- node(X).
single_path(X,J,cons(X,T,J,L)) :- edge(X,T), single_path(T,J,L).

cons(A,X,A,B,E,E):-single_path(A,X,cons(A,B,C,E)).
cons(A,X,B,C,E1,E2):-cons(A,X,_,_,cons(B,C,_,E1),E2).

decompose(A,J,B,C,D,E) :- cons(A,J,B,C,D,E).
%decompose_path(A,J,A,C,D) :- decompose(A,J,A,C,D).

%test(A,J,B,C,D,E) :- decompose(A,J,B,C,D,E),A=c,J=i.

%test2(A,B,C,D,X,E) :- decompose(A,B,_,_,X,E),decompose(C,D,_,_,X,E),A<C,X!=cons(empty).

%int_nodes(A) :- test2(A,_,_,_,_).
%int_nodes(A) :- test2(_,_,A,_,_).


%self_intersection(A,B,C,D,E1,E2,E3) :- decompose(A,B,C,D,E1,E2),decompose(A,B,C,D,_,E3),E2<E3.
%cross_intersection(A,B,C,D,E1,E2,E3) :- decompose(A,B,C,D,E1,E2),decompose(A2,B2,C,D,_,E3),E2<E3,A<A2,not path(A,A2).

%intersection(C,D):-cross_intersection(A,B,C,D,E1,E2,E3).
%intersection(C,D):-self_intersection(A,B,C,D,E1,E2,E3).

intersection(A,B,G,H,C,D,F,J):-decompose(A,B,C,D,E,F),decompose(G,H,C,D,I,J),F<J,F!=cons(empty),J!=cons(empty).

intersection_nodes(A,B,F,J):-intersection(_,_,_,_,A,B,F,J).

int_nodes(A,B):-intersection_nodes(A,B,_,_).

start_point_interest(X):-startpoint(X,_).
start_point_interest(Y):-splitpoint(X,_),edge(X,Y).
start_point_interest(X):-mergepoint(X,_).
%point_interest(X):-splitpoint(X,_).
stop_point_interest(X):-endpoint(X,_).
stop_point_interest(X):-splitpoint(X,_).
stop_point_interest(Y):-mergepoint(X,_),edge(Y,X).

point_path(A,B,C,D):-start_point_interest(A),stop_point_interest(B),path_count(A,B,C,D).

sub_workflow(A,B,C1,D):-point_path(A,B,C1,D),C1=H,H=#min{C:point_path(_,B,C,_)}.
%short_point_path(A,B,C1,D1):-point_path(A,B,C1,D1),point_path(A,B,C2,D2),D1<D2.
%short_point_path(A,B,C2,D2):-point_path(A,B,C1,D1),point_path(A,B,C2,D2),D1<D2.


#show sub_workflow/4.
%#show start_point_interest/1.
%#show stop_point_interest/1.



%#show int_nodes/1.
%#show test/5.
%#show test2/5.
%#show decompose/6.
%#show cross_intersection/7.
%#show intersection/8.
%#show intersection_nodes/4.
%#show int_nodes/2.
%#show cons/6.
%#show single_path/4.