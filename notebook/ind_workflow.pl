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


splitmerge(X,Y):-path(X,Y),splitpoint(XX,_),edge(XX,X),mergepoint(YY,_),edge(Y,YY),X!=Y,not mergemerge(Y,_),not splitsplit(X,_).
splitsplit(X,Y):-path(X,Y),splitpoint(XX,_),edge(XX,X),splitpoint(Y,_),X!=Y.
splitend(X,Y):-path(X,Y),splitpoint(XX,_),edge(XX,X),endpoint(Y,_),not splitmerge(X,_),not mergeend(_,Y),not splitsplit(X,_).
%splitall(Y):-splitend(Y,_).
%splitall(Y):-splitsplit(_,Y).
startsplit(X,Y):-path(X,Y),startpoint(X,_),splitpoint(Y,_),not splitsplit(_,Y).
mergemerge(X,Y):-path(X,Y),mergepoint(X,_),mergepoint(Y,_),X!=Y.
mergeend(X,Y):-path(X,Y),mergepoint(X,_),endpoint(Y,_),not mergemerge(X,_).
startend(X,Y):-path(X,Y),startpoint(X,_),endpoint(Y,_),not mergeend(_,Y),not splitend(_,Y).

%#show startpoint/2.
%#show endpoint/2.
#show splitpoint/2.
%#show mergepoint/2.
%#show path/2.
#show mergemerge/2.
#show splitmerge/2.
#show startsplit/2.
#show mergeend/2.
#show startend/2.
#show splitend/2.
#show splitsplit/2.
%#show splitall/1.



