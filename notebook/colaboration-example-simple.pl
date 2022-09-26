% source(source_id, file_name, description)
source(0,"employee_demo","OpenRefine Project").
% array(array_id, source_id)
array(0,0).
% column(column_id, array_id)
column(0,0). column(1,0). column(2,0).
% row(row_id, array_id)
row(0,0). row(1,0). row(2,0). row(3,0).
% cell(cell_id, row_id, col_id)
cell(0,0,0). cell(1,1,0). cell(2,2,0). cell(3,3,0). cell(4,0,1). cell(5,1,1). 
cell(6,2,1). cell(7,3,1). cell(8,0,2). cell(9,1,2). cell(10,2,2). cell(11,3,2).
% column_schema(column_schema_id,column_id,state_id,column_type,column_name,prev_column_id,prev_colum_schema_id)
column_schema(0,0,-1,"text","id",-1,-1).
column_schema(1,1,-1,"text","name",0,-1).
column_schema(2,2,-1,"text","birth_date",1,-1).
% value(value_id, cell_id, state_id, value, prev_content_id)
value(0,0,-1,"1",-1). value(1,1,-1,"1",-1). value(2,2,-1,"2",-1). value(3,3,-1,"3",-1).
value(4,4,-1,"John",-1). value(5,5,-1,"Doe",-1). value(6,6,-1,"Alex",-1). value(7,7,-1,"Patricia",-1).
value(8,8,-1,"Aug, 1 1988",-1). value(9,9,-1,"1-Aug-1986",-1).
value(10,10,-1,"20-Jan-1993",-1). value(11,11,-1,"Feb 11,1990",-1).
% state(state_id, array_id, prev_state_id)
state(0,0,-1). 
state(1,0,-1). 
state(2,0,-1).
state(3,0,2). 
state(4,0,2).
% user(user_id, user_name)
user(0,"user_a"). 
user(1,"user_b"). 
user(2,"user_c").
% operation(operation_id, user_id, input_state_id, output_state_id)
operation(0, 0, -1, 0). 
operation(1, 1, -1, 1).
operation(2, 2, -1, 2). 
operation(3, 0, 2, 3).
operation(4, 1, 2, 4).
% changed value
value(10,1,0,null,1). 
value(11,5,0,null,5). 
value(12,9,0,null,9).
value(13,0,1,null,0). 
value(14,4,1,null,4). 
value(15,8,1,null,8).
value(16,1,2,"4",1). 
value(17,9,3,"1986-08-01",9). 
value(19,10,3,"1993-01-20",10).
value(18,8,4,"1988-08-01",8). 
value(20,11,4,"1990-02-11",11).


value_conflict(A1,A2,B1,C1,C2,D1,D2):-value(A1,B1,C1,D1,E1),
            value(A2,B2,C2,D2,E2),
            E1=E2,
            B1=B2,
            D1<D2.

branch_workflow(A1,A2,B1,B2,D1,D2):-operation(A1,B1,C1,D1),
    operation(A2,B2,C2,D2),
    C1=C2,
    A1<A2.


% any endpoint state
operation_edge(A,B) :- operation(_,_,A,B).
operation_node(X) :- operation_edge(X,_).
operation_node(X) :- operation_edge(_,X).

% sink of operation_edge
operation_edge_sink(X,H) :- operation_node(X),H==0,H=#count{C:operation_edge(X,C)}.
operation_edge_start(X,H):- operation_node(X),H==0,H=#count{C:operation_edge(C,X)}.

% combined_path
combined_path(X,X,0,cons(empty)) :- operation_node(X).
combined_path(X,J,C+1,cons(X,T,J,L,N)) :- operation_edge(X,T), combined_path(T,J,C,L), operation(_,U,_,T), user(U, N).

combined_path_sink(A,B,C,D) :- combined_path(A,B,C,D),
    operation_edge_start(A,_),
    operation_edge_sink(B,_).

%#show operation_edge_start/2.
%#show combined_path_sink/4.

% dependency graph for each sink
path(X,X):-operation_edge(X,_).
path(X,X):-operation_edge(_,X).
path(X,Z):-operation_edge(X,Y),path(Y,Z).

% snapshot for each sink
path_sink(A,X) :- path(A,X),
    operation_edge_sink(X,_).


snapshot_value_not(E,X) :- value(A,B,C,D,E),
    path_sink(C,X).
snapshot_value(A,B,X,D,E) :- value(A,B,C,D,E),
    path_sink(C,X),
    not snapshot_value_not(A,X).
snapshot_value_diff(B5,B6,C1,C2,D1,D2) :-
    snapshot_value(A1,B1,C1,D1,E1),
    snapshot_value(A2,B2,C2,D2,E2),
    operation(A3,B3,C3,D3), operation(A4,B4,C4,D4),
    user(A5,B5), user(A6,B6), A5=B3, A6=B4,    
    D3=C1, D4=C2, C1<C2, B1=B2, D1!=D2.
value_diff_count(C1,D1,H) :- snapshot_value_diff(_,_,C1,D1,_,_),
     H=#count{E1,F1: snapshot_value_diff(_,_,C1,D1,E1,F1)}.

%#show snapshot_value_diff/6.
#show value_diff_count/3.


snapshot_value_3_4(A,B,C,D,E,F):-
    snapshot_value_diff(A,B,C,D,E,F),
    C==3,
    D==4.
snapshot_value_3_4(A,B,C,D,E,F):-
    snapshot_value_diff(A,B,C,D,E,F),
    C==4,
    D==3.

snapshot_value_3_4(A,B,C,D,E,F):-
    snapshot_value_diff(A,B,C,D,E,F),
    C==3,
    D==4.

% #show snapshot_value_3_4/6.

% #show operation_edge/2.
% #show operation_edge_sink/2.
% #show path/2.
% #show path4/2.
% #show snapshot_value_not/2.
% #show snapshot_value/5.


%#show value_conflict/7.
%#show branch_workflow/6.


