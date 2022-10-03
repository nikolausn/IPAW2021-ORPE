% dataset(dataset_id,dataset_name)
dataset(d1,dataset_1).
dataset(d2,dataset_2).
% array(array_id,dataset_id)
% a array is instantiation of dataset
% a dataset can be transformed into different structure of array
array(a1,d1).
array(a2,d2).
% column(column_id, array_id, col_schema_type, prev_col_id)
column(c1,a1,cs1,0).
column(c2,a1,cs2,c1).
column(c3,a1,cs3,c2).
column(c4,a1,cs4,c3).
column(c5,a1,cs5,c4).
column(c6,a1,cs6,c5).
column(c7,a1,cs7,c6).

column(c8,a2,cs1,0).
column(c9,a2,cs2,c8).
column(c10,a2,cs1,c9).
column(c11,a2,cs1,c10).


% column_schema(id,name,data_type,-quality_problems()).
% a column is presented as "name", with "date_type" and have a list of "quality_problems"
%column_schema(cs1,name,text).
%column_schema(cs2,birth_date,text).
%column_schema(cs3,department,number).
%column_schema(cs4,first_name,text).
%column_schema(cs5,last_name,text).
%column_schema(cs6,full_name,text).
%column_schema(cs7,merge_name,text).

% general column based on type
%column_schema(cs8,none,text).
%column_schema(cs9,none,number).
%column_schema(cs10,none,date).
% general column based on name with any type
%column_schema(cs11,name,none).
%column_schema(cs12,birth_date,none).

% process(id,name,-parameter,-description).
% process is presented as name, with "parameter" and detail execution as "description" 
process(p1,split_name).
process(p2,upper_case).
process(p3,rename_col).
process(p4,merge_col).
process(p5,normalize_char).
process(p6,normalize_date).
process(p7,fixed_ssn).

column_schema(cs1,name,full_name).
column_schema(cs1,data_type,text).
column_schema(cs2,name,first_name).
column_schema(cs2,data_type,text).
column_schema(cs3,name,last_name).
column_schema(cs3,data_type,text).
column_schema(cs6,name,ssn).
column_schema(cs6,data_type,text).
column_schema(cs7,name,ssn).
column_schema(cs7,data_type,number).

% input parameter of process blueprint
% input_parameter(pid,parameter_name,parameter_value).
% entity of input_parameter for a process pid where parameter_name has parameter_value 
parameter(p1,input,column_schema(cs11)).
parameter(p1,dq_problem,null_value).
parameter(p1,output,column_schema(cs11)).
parameter(p1,output,column_schema(cs12)).
parameter(p1,output,column_schema(cs13)).

% schema with only data type (doesnt care about naming)
column_schema(cs4,data_type,text).
column_schema(cs5,data_type,number).

parameter(p5,input,column_schema(cs14)).
parameter(p5,dq_problem,unknown_char).
parameter(p5,output,column_schema(cs14)).

parameter(p6,input,column_schema(cs14)).
parameter(p6,dq_problem,date_format_error).
parameter(p6,output,column_schema(cs15)).


% process blueprint input parameter
process_blueprint(Pid,Pname,PrName,column_schema(CSid,CSname,CSValue)) :-
    process(Pid,Pname),
    parameter(Pid,PrName,column_schema(CSid)),
    column_schema(CSid,CSname,CSValue).

process_blueprint(Pid,Pname,dq_problem,Value) :-
    process(Pid,Pname),
    parameter(Pid,dq_problem,Value).

% instantiate column
column(c1,a3,cs1,0).
column(c2,a3,cs2,c1).
column(c3,a3,cs3,c2).

column(c3,a4,cs3,none).
column(c4,a4,cs4,0).
column(c5,a4,cs5,c4).

% data_quality_problem as detected on a column
% remark to show violation of a process that apply to unnecesary problem 
%dq_problem(c11,null_value).
dq_problem(c12,null_value).
dq_problem(c12,unknown_char).

workflow_step(1,column_state(c1,1),p1,column_state(c1,2)).
% remark these two lines to test output workflow violation
workflow_step(1,column_state(c1,1),p1,column_state(c2,1)).
workflow_step(1,column_state(c1,1),p1,column_state(c3,1)).

% example of process violation given no name on the input
workflow_step(2,column_state(c2,1),p1,column_state(c2,2)).

workflow_step(3,column_state(c2,1),p6,column_state(c2,3)).
% remark this for example of output violation data type only
workflow_step(4,column_state(c2,1),p6,column_state(c5,2)).
% example for assigning output with name and number but the process only care about data type
workflow_step(4,column_state(c3,1),p6,column_state(c3,2)).



% checking violation on missing input of workflow_step

% workflow input schema
step_input_schema(column_state(CIid,SIid),Pid,column_schema(CSIid,Key,Value)) :-
    workflow_step(_,column_state(CIid,SIid),Pid,column_state(COid,SOid)),
    column(CIid,_,CSIid,_),
    column_schema(CSIid,Key,Value).


%#show step_input_schema/3.

workflow_input_violation(column_state(CIid,SIid),Pid,column_schema(CSPid,Key,Value)) :-
    parameter(Pid,input,column_schema(CSPid)),
    column_schema(CSPid,Key,Value),
    workflow_step(_,column_state(CIid,SIid),Pid,_),
    not step_input_schema(column_state(CIid,SIid),Pid,column_schema(_,Key,Value)).

%#show workflow_input_violation/3.

% checking violation on missing output of workflow step

% workflow output schema
step_output_schema(column_state(CIid,SIid),Pid,column_schema(CSIid,Key,Value)) :-
    workflow_step(_,column_state(CIid,SIid),Pid,column_state(COid,SOid)),
    column(COid,_,CSIid,_),
    column_schema(CSIid,Key,Value).


%#show step_output_schema/3.

workflow_output_violation(column_state(CIid,SIid),Pid,column_schema(CSPid,Key,Value)) :-
    parameter(Pid,output,column_schema(CSPid)),
    column_schema(CSPid,Key,Value),
    workflow_step(_,column_state(CIid,SIid),Pid,column_state(COid,SOid)),
    not step_output_schema(column_state(CIid,SIid),Pid,column_schema(_,Key,Value)).

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
    parameter(Pid,dq_problem,DQValue),
    workflow_step(_,column_state(CIid,SIid),Pid,_),
    not step_dq_problem(column_state(CIid,SIid),Pid,dq_problem(_,DQValue)).

%#show dq_problem_violation/3.

%    parameter(Pid,input,column_schema(CSId)),
%    column_schema(CSId,Key,Value).

%process_blueprint(Pid,Pname,output,schema,CSid,CSname,CSValue) :-
%    process(Pid,Pname),
%    output_parameter(Pid,schema,column_schema(CSid)),
%    column_schema(CSid,CSname,CSValue).

%process_blueprint(Pid,Pname,dq_,schema,CSid,CSname,CSValue) :-
%    process(Pid,Pname),
%    output_parameter(Pid,schema,column_schema(CSid)),
%    column_schema(CSid,CSname,CSValue).


%#show process_blueprint/4.

% possible name violation, data_type violation, or data_quality violation

% parameter(id,process_id,name,type).
parameter(1,p1,col_input,col_schema(cs1)).
parameter(2,p1,col_input,col_schema(cs3)).
parameter(3,p1,col_output,col_schema(cs7)).
parameter(4,p1,dq_problem,null_value).
parameter(5,p1,dq_problem,unknown_char).


% input_process(process_id,col_schema_id)
input_process(p1,cs1).
input_process(p2,cs1).
input_process(p3,cs4).

input_process(p4,cs2).
input_process(p4,cs3).

input_process(p5,cs4).
input_process(p6,cs4).

input_process(p7,cs6).


% output_process(process_id,column_name)
output_process(p1,cs1).
output_process(p1,cs2).
output_process(p1,cs3).
output_process(p2,cs4).
output_process(p3,cs4).

output_process(p4,cs4).

output_process(p5,cs4).
output_process(p6,cs5).

output_process(p7,cs7).


% recipe(recipe_id,seq_id,process_id,prev_seq_id)
recipe(r1,1,p2,0).
recipe(r1,2,p1,1).
recipe(r1,3,p4,2).

recipe(r2,1,p3,0).
%recipe(r2,1,p1,0).
recipe(r2,2,p5,1).
recipe(r2,3,p6,2).

% column_state(col_schema_id,id)

% workflow_step(column_state(column_id,state_id),process_id,output_state)
% workflow is execution of process_id given a existing column_state and produce and output_state
% probably: step?



% define another process with rename column_name (inject problem)
%workflow_step(column_state(1,2),3,column_state(6,1)).
% inject workflow_step(step(column_state,process))
% a plan to execute a process to an existing column_state
% supposed I inject/update a workflow by adding process 3 to the column_state(1,2) 
inject_workflow_step(workflow_step(column_state(c1,2),p3)).
inject_workflow_step(workflow_step(column_state(c1,1),p3)).


% replace a process with another process (update recipe problem)
update_workflow_step(workflow_step(column_state(c1,1),p2),p3).


% inject workflow violation
% what process will break ?
% gather input parameter (pre-condition) for process state
workflow_input(P,column_state(CIId,CIState),column_state(COId,COState),CIName,COName) :- 
    workflow_step(_,column_state(CIId,CIState),P,column_state(COId,COState)),
    column(CIId,_,CSIId,_),
    column(COId,_,CSOId,_),
    column_schema(CSIId,CIName,_),
    column_schema(CSOId,COName,_).

% update violation by column_name
inject_violation(P,OriginalP,AffectedP,CO,COName,CIAffectedName) :- 
    inject_workflow_step(workflow_step(column_state(CIId,CIState),P)),
    output_process(P,COId),
    column_schema(COId,COName,_),
    workflow_input(OriginalP,column_state(CIId,CIState),CO,_,_),
    workflow_input(AffectedP,CO,_,CIAffectedName,_),
    CIAffectedName!=COName.

% supposed we have recipe r1
% what are the pre-condition (required input), and post-condition (expected_output)?
% recipe find input and output sink
recipe_input_sink(Rid,CSid) :- recipe(Rid,Sid,Pid,PrevSeq),
    input_process(Pid,CSid).

% find the output sink of the recipe by querying any output
recipe_output_sink(Rid,CSid) :- recipe(Rid,Sid,Pid,PrevSeq),
    output_process(Pid,CSid).

% suppose we plan to reuse recipe on dataset 2 which have 2 column c1,c2
% the test fact:
% reuse_recipe(recipe(column_state(CIId,CIState),RId))

% assume we apply recipe on dataset 2.c8 : name
reuse_recipe(recipe(column_state(c8,1),r1)).
% another plan apply recipe on dataset 2.c9 : birth_date
reuse_recipe(recipe(column_state(c9,1),r1)).

% check if there is any violation or impossible application of the recipe
reuse_violation(column_state(CId,SId),RId,RColInput,TargetColInput) :-
    reuse_recipe(recipe(column_state(CId,SId),RId)),    
    recipe_input_sink(RId,CSId),
    column_schema(CSId,RColInput,_),
    column(CId,_,TargetCSId,_),
    column_schema(TargetCSId,TargetColInput,_),
    RColInput!=TargetColInput.


% recipe reuse to existing workflow, chainbreak checking
reuse_recipe(recipe(column_state(c10,2),r2)).
reuse_recipe(recipe(column_state(c11,2),r1)).

inject_violation_checking(RId,OriginalP,AffectedP,CO,RColOutput,CIAffectedName) :- 
    reuse_recipe(recipe(column_state(CIId,CIState),RId)),
    recipe_output_sink(RId,CSId),
    column_schema(CSId,RColOutput,_),
    workflow_input(OriginalP,column_state(CIId,CIState),CO,_,_),
    workflow_input(AffectedP,CO,_,CIAffectedName,_).

inject_violation(RId,OriginalP,AffectedP,CO,RColOutput,CIAffectedName) :-
    H = #count{RId:inject_violation_checking(RId,_,_,CO,CIAffectedName,CIAffectedName)},
    H == 0,
    inject_violation_checking(RId,OriginalP,AffectedP,CO,RColOutput,CIAffectedName).    


%#show select_workflow/4.
%#show inject_workflow/1.
%#show inject_workflow_step/1.
%#show inject_violation/6.
%#show inject_violation_checking/6.
%#show injected_parameter/4.
%#show recipe_input_sink/2.
%#show recipe_output_sink/2.
%#show reuse_recipe/1.
%#show reuse_violation/4.



%inject_violation(P,OriginalP,AffectedP,CO,COName,CIAffectedName) :- 
%    injected_parameter(P,column_state(CIId,CIState),column_state(COId,COState),COName),
%    workflow_input(OriginalP,column_state(CIId,CIState),CO,_,_),
%    workflow_input(AffectedP,CO,_,CIAffectedName,_),
%    CIAffectedName!=COName.

%inject_violation(P,OriginalP,AffectedP,CO,COName,CIAffectedName) :- 
%    injected_parameter(P,column_state(CIId,CIState),column_state(COId,COState),COName),
%    select_workflow_step(OriginalP,column_state(CIId,CIState),CO,CIAffectedName),
%    COName!=CIAffectedName.


select_workflow_step(OriginalP,CI,CO,CIAffectedName) :-
    workflow_input(OriginalP,CI,CO,_,_),
    workflow_input(AffectedP,CO,_,CIAffectedName,_).

injected_parameter(P,column_state(CIId,CIState),column_state(COId,COState),COName) :-
    inject_workflow_step(workflow_step(column_state(CIId,CIState),P,column_state(COId,COState))),
    column_schema(COId,COName,_).


% process_input_output(process_id,col_input_id,col_input_name,col_output_id,col_output_name)
process_schema(Pid,ColInputId,ColInputName,ColOutputId,ColOutputName):-
    process(Pid,_),
    input_process(Pid,ColInputId),
    column_schema(ColInputId,ColInputName,_),
    output_process(Pid,ColOutputId),
    column_schema(ColOutputId,ColOutputName,_).


% workflow graph
workflow_path(Source,Target,2,cons(Source,2,cons(Target,1,empty))) :- workflow_step(_,Source,_,Target).
workflow_path(Source,Target,NN+1,cons(Source,NN+1,L)) :- workflow_step(_,Source,_,Temp), workflow_path(Temp,Target,NN,L).


%path(X,Y,2,cons(X,2,cons(Y,1,empty))) :- edge(X,Y).
%path(A,C,NN+1,cons(A,NN+1,L)) :- edge(A,B), path(B,C,NN,L), step(NN+1).

% example_flow
example_flow(A,B,C,D) :- workflow_path(A,B,C,D),
    A = column_state(1,1),
    B = column_state(7,1).

%#show process_schema/5.
%#show workflow_path/4.
%#show example_flow/4.
%#show workflow_input/5.