#include "align_test_replace_undo_changes.pl".

%generate edges for derived value
value_edge(B,A):-cell_values(A,_,_,_,B), B!="-1".

value_path(X,X):-value_edge(X,_).
value_path(X,X):-value_edge(_,X).
value_path(X,Z):-value_edge(X,Y),value_path(Y,Z),Z>X.

%exclude self/circular path 
value_path_no_self(X,Y):-value_path(X,Y),Y>X.

%look for possibility of undo value where there are value on the derived path that revert back  
undo_value(A1,A2,B1,C1,C2,D1) :- cell_values(A1,B1,C1,D1,E1),
            cell_values(A2,B1,C2,D1,E2),
            value_path_no_self(A1,A2).

change_value(A1,A2,B1,C1,C2,D1,D2) :- cell_values(A1,B1,C1,D1,E1),
            cell_values(A2,B1,C2,D2,E2),
            value_path_no_self(A1,A2),
            D2>D1.

undo_possible_state(A1,A2) :- undo_value(A1,A2,_,_,_,_).

%check possible path within the domain of the undoed value
undo_possible_path(X,Y) :- undo_possible_state(_,Y), value_path_no_self(X, Y), Y > X.

%if any of the value on path is not equal to the undo value
cell_values_undoed(A1,A2,Y,V2,V1):-undo_possible_path(Y,A2),
            cell_values(Y,_,_,V1,_),
            undo_value(A1,A2,_,_,_,V2),
            V1>V2.

%#show value_edge/2.
%#show value_path_no_self/2.
%#show undo_possible_state/2.
%#show undo_possible_path/2.
#show cell_values_undoed/5.
%#show change_value/7.
#show undo_value/6.

