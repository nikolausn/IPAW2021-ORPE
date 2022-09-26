% column_schema(id,name,data_type).
column_schema(1,name,text).
column_schema(2,birth_date,text).
column_schema(3,department,number).
column_schema(4,first_name,text).
column_schema(5,last_name,text).
column_schema(6,full_name,text).
column_schema(7,merge_name,text).

% process(id,name).
process(1,split_name).
process(2,upper_case).
process(3,rename_col).
process(4,merge_col).

% column_state(col_schema_id,id)

% workflow(column_state,pid)
workflow(column_state(1,1),1,column_state(1,2)).
workflow(column_state(1,1),1,column_state(4,1)).
workflow(column_state(1,1),1,column_state(5,1)).
workflow(column_state(1,2),2,column_state(1,3)).
workflow(column_state(4,1),2,column_state(4,2)).
workflow(column_state(5,1),2,column_state(5,2)).
workflow(column_state(4,2),4,column_state(7,1)).
workflow(column_state(5,2),4,column_state(7,1)).
workflow(column_state(1,3),4,column_state(1,4)).

% define another process with rename column_name (update problem)
%workflow(column_state(1,2),3,column_state(6,1)).
% inject workflow(workflow)
inject_workflow(workflow(column_state(1,2),3,column_state(6,1))).

% inject workflow violation
% what process will break

% gather input parameter (pre-condition) for process state
workflow_input(P,column_state(CIId,CIState),column_state(COId,COState),CIName,COName) :- 
    workflow(column_state(CIId,CIState),P,column_state(COId,COState)),
    column_schema(CIId,CIName,_),
    column_schema(COId,COName,_).

inject_violation(P,OriginalP,AffectedP,CO,COName,CIAffectedName) :- 
    inject_workflow(workflow(column_state(CIId,CIState),P,column_state(COId,COState))),
    column_schema(COId,COName,_),
    workflow_input(OriginalP,column_state(CIId,CIState),CO,_,_),
    workflow_input(AffectedP,CO,_,CIAffectedName,_),
    CIAffectedName!=COName.

%inject_violation(P,OriginalP,AffectedP,CO,COName,CIAffectedName) :- 
%    injected_parameter(P,column_state(CIId,CIState),column_state(COId,COState),COName),
%    workflow_input(OriginalP,column_state(CIId,CIState),CO,_,_),
%    workflow_input(AffectedP,CO,_,CIAffectedName,_),
%    CIAffectedName!=COName.

%inject_violation(P,OriginalP,AffectedP,CO,COName,CIAffectedName) :- 
%    injected_parameter(P,column_state(CIId,CIState),column_state(COId,COState),COName),
%    select_workflow(OriginalP,column_state(CIId,CIState),CO,CIAffectedName),
%    COName!=CIAffectedName.


select_workflow(OriginalP,CI,CO,CIAffectedName) :-
    workflow_input(OriginalP,CI,CO,_,_),
    workflow_input(AffectedP,CO,_,CIAffectedName,_).

injected_parameter(P,column_state(CIId,CIState),column_state(COId,COState),COName) :-
    inject_workflow(workflow(column_state(CIId,CIState),P,column_state(COId,COState))),
    column_schema(COId,COName,_).

%#show select_workflow/4.
%#show inject_workflow/1.
#show inject_violation/6.
%#show injected_parameter/4.


% parameter(id,process_id,name,type).
parameter(1,1,column_name,text).
parameter(2,1,separator,text).

% input_process(process_id,col_schema_id)
input_process(1,1).
input_process(2,1).
input_process(3,1).


% output_process(process_id,column_name)
output_process(1,1).
output_process(1,4).
output_process(1,5).
output_process(2,1).
output_process(3,6).


% process_input_output(process_id,col_input_id,col_input_name,col_output_id,col_output_name)
process_schema(Pid,ColInputId,ColInputName,ColOutputId,ColOutputName):-
    process(Pid,_),
    input_process(Pid,ColInputId),
    column_schema(ColInputId,ColInputName,_),
    output_process(Pid,ColOutputId),
    column_schema(ColOutputId,ColOutputName,_).


% workflow graph
workflow_path(Source,Target,2,cons(Source,2,cons(Target,1,empty))) :- workflow(Source,_,Target).
workflow_path(Source,Target,NN+1,cons(Source,NN+1,L)) :- workflow(Source,_,Temp), workflow_path(Temp,Target,NN,L).


%path(X,Y,2,cons(X,2,cons(Y,1,empty))) :- edge(X,Y).
%path(A,C,NN+1,cons(A,NN+1,L)) :- edge(A,B), path(B,C,NN,L), step(NN+1).

% example_flow
example_flow(A,B,C,D) :- workflow_path(A,B,C,D),
    A = column_state(1,1),
    B = column_state(7,1).

%#show process_schema/5.
%#show workflow_path/4.
%#show example_flow/4.
#show workflow_input/5.
