% column_schema(id,name,data_type).
% a column is presented as "name", with "date_type"
column_schema(cs1,name,full_name). column_schema(cs1,data_type,text).

% process(id,name).
% process is presented as name
process(p1,lower_case).
process(p2,lemmatize_char).

% input parameter of process blueprint
% entity of input_parameter for a process pid where parameter_name has parameter_value 
input_process(p1,1,cs1).
output_process(p1,1,cs1).
% input_parameter(pid,param_id,parameter_name,parameter_value).
% dq_problem can be represented as a parameter: goal of a process
parameter(p1,1,dq_problem,lower_case).


input_process(p2,1,cs1).
output_process(p2,1,cs1).
parameter(p2,1,dq_problem,lemmatize_char).

% instantiate column
column(c1,a1,cs1,0).

% dq_problem(ColumnId,DQIdName,DQIndex)
dq_problem(c1,mixed_case,0.1).
dq_problem(c1,non_standard_text,0.1).
% metrics_after > metrics_before

% dq_problem(ColumnId,DQIdName)
dq_problem(c1,lower_case)

workflow_step(1,column_state(c1,1),p1,column_state(c1,2)).
% remark these two lines to test output workflow violation
workflow_step(2,column_state(c1,2),p2,column_state(c1,3)).


% example for assigning output with name and number but the process only care about data type

% checking violation on missing input of workflow_step

% workflow input schema
step_input_schema(Sid,column_state(CIid,SIid),Pid,column_schema(CSIid,Key,Value)) :-
    workflow_step(Sid,column_state(CIid,SIid),Pid,column_state(COid,SOid)),
    column(CIid,_,CSIid,_),
    column_schema(CSIid,Key,Value).


%#show step_input_schema/3.

workflow_input_violation(Sid,missing,Pid,column_schema(CSPid,Key,Value)) :-
    input_process(Pid,_,CSPid),
    column_schema(CSPid,Key,Value),
    workflow_step(Sid,_,Pid,_),
    not step_input_schema(Sid,_,Pid,column_schema(_,Key,Value)).

% step input blueprint
step_input_blueprint(Pid,CSPid,Key,Value) :-
    input_process(Pid,_,CSPid),
    column_schema(CSPid,Key,Value).

% not satisfy input (others doesnt matter)
step_input_satisfiable(Sid,column_state(CIid,SIid),Pid,CSPid,Key,Value) :-
    step_input_blueprint(Pid,CSPid,Key,Value),
    step_input_schema(Sid,column_state(CIid,SIid),Pid,column_schema(_,Key,Value)).

workflow_input_violation(Sid,unexpected,Pid,column_state(CIid,SIid)) :-
    step_input_schema(Sid,column_state(CIid,SIid),Pid,column_schema(_,Key,Value)),
    not step_input_satisfiable(Sid,column_state(CIid,SIid),Pid,_,Key,Value).

%#show workflow_input_violation/3.

% checking violation on missing output of workflow step

% workflow output schema
step_output_schema(Sid,column_state(CIid,SIid),Pid,column_schema(CSIid,Key,Value)) :-
    workflow_step(Sid,column_state(CIid,SIid),Pid,column_state(COid,SOid)),
    column(COid,_,CSIid,_),
    column_schema(CSIid,Key,Value).
          
%#show step_output_schema/3.

workflow_output_violation(Sid,missing,Pid,column_schema(CSPid,Key,Value)) :-
    output_process(Pid,_,CSPid),
    column_schema(CSPid,Key,Value),
    workflow_step(Sid,_,Pid,_),
    not step_output_schema(Sid,_,Pid,column_schema(_,Key,Value)).

%workflow_output_violation(Sid,column_state(CIid,SIid),Pid,column_schema(CSPid,Key,Value)) :-
%    output_process(Pid,_,CSPid),
%    column_schema(CSPid,Key,Value),
%    workflow_step(Sid,column_state(CIid,SIid),Pid,column_state(COid,SOid)),
%    not step_output_schema(Sid,column_state(CIid,SIid),Pid,column_schema(_,Key,Value)).

%#show workflow_output_violation/3.

% dq problem violation
% constraint rule for checking if data quality is in the domain of the process / recipe


% workflow step assignment to the data quality problem
step_dq_problem(column_state(CIid,SIid),Pid,dq_problem(CIid,DQValue)) :-
    workflow_step(_,column_state(CIid,SIid),Pid,_),
    dq_problem(CIid,DQValue).

%#show step_dq_problem/3.

% DQProblem violation
dq_problem_violation(column_state(CIid,SIid),Pid,DQValue) :-
    parameter(Pid,_,dq_problem,DQValue),
    workflow_step(_,column_state(CIid,SIid),Pid,_),
    not step_dq_problem(column_state(CIid,SIid),Pid,dq_problem(_,DQValue)).

%#show dq_problem_violation/3.

dq_proxy(Pid,Name,DQ) :- process(Pid,Name),
                parameter(Pid,_,dq_problem,DQ).

recipe_edge(Rid,X,Y) :- workflow_step(Rid,Y,_,X).
recipe_path(Rid,X,Y,via(X,1)) :- recipe_edge(Rid,X,Y).
recipe_path(Rid,X,Z,via(M,N+1)) :- recipe_edge(Rid,X,Y), recipe_path(Rid,Y,Z,via(M,N)).

%#show recipe_path/4.

% process path
process_edge(Sid1,Pid1,Sid2,Pid2) :- workflow_step(Sid1,X,Pid1,Y),
                workflow_step(Sid2,Y,Pid2,Z).

column_edge(X,Y,Pid1) :- workflow_step(Sid1,X,Pid1,Y).               
column_path(C1,C2,Pid) :- column_edge(C1,C2,Pid).
column_path(C2,C3,Pid) :- column_edge(C1,C2,Pid),column_path(C2,C3,_).

select_path(C2,C3,Pid) :-
    column_path(C2,C3,Pid),
    C3 = column_state(c2,t2_2).

% accumulated dq handling
accumulated_dq_handling(C3,DQ) :-
    column_path(C2,C3,Pid),
    dq_proxy(Pid,_,DQ).

accumulated_dq_problem(column_state(C1,S1),DQProblem) :-
    dq_problem(C1,DQProblem),
    column_edge(column_state(C1,S1),_,_),
    not accumulated_dq_handling(column_state(C1,S1),DQProblem).

accumulated_dq_problem(column_state(C2,S2),DQProblem) :-
    dq_problem(C2,DQProblem),
    column_edge(_,column_state(C2,S2),Pid),
    not accumulated_dq_handling(column_state(C2,S2),DQProblem).

%#show accumulated_dq_handling/2.
#show accumulated_dq_problem/2.


%#show process_edge/4.
%#show select_path/3.

% accumulated process dq
%accumulated_process_dq() :-
