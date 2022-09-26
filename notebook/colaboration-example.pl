% source(source_id, file_name, description)
source(0,"bibliography_demo","OpenRefine Project").
% array(array_id, source_id)
array(0,0).
% column(column_id, array_id)
column(0,0).
column(1,0).
% row(row_id, array_id)
row(0,0).
row(1,0).
% cell(cell_id, row_id, col_id)
cell(0,0,0).
cell(1,1,0).
cell(2,0,1).
cell(3,1,1).
% value(value_id, cell_id, state_id, value, prev_content_id)
value(0,0,-1,"Against Method",-1).
value(1,1,-1,"Feyerabend, P.",-1).
value(2,2,-1,"Changing Order",-1).
value(3,3,-1,"Collins, H.M.",-1).
% column_schema(column_schema_id,column_id,state_id,column_type,column_name,prev_column_id,prev_colum_schema_id)
column_schema(0,0,-1,"text","Book Title",-1,-1).
column_schema(1,1,-1,"text","Author",0,-1).
% state(state_id, array_id, prev_state_id)
state(0,0,-1).
state(1,0,0).
state(2,0,0).
% user(user_id, user_name)
user(0, "user_a").
user(1, "user_b").
% operation(operation_id, user_id, input_state_id, output_state_id)
operation(0, 0, 0, 1).
operation(1, 1, 0, 2).
% column_at_state(operation_id, input_column, output_column)
column_at_state(0,0,0).
column_at_state(1,0,0).
% changed value
value(4,1,1,"Feyerabend",1).
value(5,1,2,"P. Feyerabend",1).


value_conflict(A1,A2,B1,C1,C2,D1,D2):-value(A1,B1,C1,D1,E1),
            value(A2,B2,C2,D2,E2),
            E1=E2,
            B1=B2,
            D1<D2.

branch_workflow(A1,A2,B1,B2,D1,D2):-operation(A1,B1,C1,D1),
    operation(A2,B2,C2,D2),
    C1=C2,
    A1<A2.

#show value_conflict/7.
#show branch_workflow/6.




