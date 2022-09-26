edge(a,b).
edge(b,c).
edge(c,d).
edge(c,e).
edge(c,f).
edge(d,g).
edge(e,h).
edge(f,k).
edge(k,l).
edge(l,p).
edge(l,q).
edge(q,r).
edge(p,s).
edge(s,j).
edge(g,i).
edge(h,i).
edge(i,j).
edge(n,o).
edge(j,t).


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

single_path(X,X,0,cons(empty)) :- node(X).
single_path(X,J,C+1,cons(X,T,J,L)) :- edge(X,T), single_path(T,J,C,L).

point_interest(A):-endpoint(A,_).
point_interest(A):-startpoint(A,_).
point_interest(A):-splitpoint(A,_).
point_interest(A):-mergepoint(A,_).

path_interest(A,B,C,D):-single_path(A,B,C,D),point_interest(A).
path_interest(A,B,C,D):-single_path(A,B,C,D),point_interest(B).

path_count(A,B,H,C,E):-path_interest(A,B,C,E),H=1,A!=B,H=#count{D:path_interest(A,B,_,D)}.

short_pc(A,B,H,C,cons(AA1,AA2,AA3,AA4)):-path_count(A,B,H,C,cons(AA1,AA2,AA3,AA4)),path_count(A2,B2,H2,C2,cons(AA1,AA2,_,_)),C<C2.

%#show path_interest/4.
%#show single_path/4.
%#show path_count/5.
#show short_pc/5.