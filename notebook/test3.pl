edge(1,2). edge(1,3). edge(1,4).
edge(2,4). edge(2,5). edge(2,6).
edge(3,1). edge(3,4). edge(3,5).
edge(4,1). edge(4,2).
edge(5,3). edge(5,4). edge(5,6).
edge(6,2). edge(6,3). edge(6,5).

node(X) :- edge(X,_).
node(X) :- edge(_,X).

col(r). col(g). col(b).

% each node has exactly one color
{ color(X,C) : col(C) } == 1 :- node(X).
% there is exist different color between neighbor
:- edge(X,Y), color(X,C), color(Y,C).

#show color/2.

