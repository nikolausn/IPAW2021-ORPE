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
column_schema(cs1,name,text).
column_schema(cs2,birth_date,text).
column_schema(cs3,department,number).
column_schema(cs4,first_name,text).
column_schema(cs5,last_name,text).
column_schema(cs6,full_name,text).
column_schema(cs7,merge_name,text).

% general column based on type
column_schema(cs8,none,text).
column_schema(cs9,none,number).
column_schema(cs10,none,date).
% general column based on name with any type
column_schema(cs11,name,none).
column_schema(cs12,birth_date,none).

% process(id,name,-parameter,-description).
% process is presented as name, with "parameter" and detail execution as "description" 
process(p1,split_name).
process(p2,upper_case).
process(p3,rename_col).
process(p4,merge_col).
process(p5,normalize_char).
process(p6,normalize_date).
process(p7,fix_zip_code).


% parameter(id,process_id,name,type).
parameter(1,p1,col_input,col_schema(cs1)).
parameter(2,p1,col_input,col_schema(cs3)).
parameter(3,p1,col_output,col_schema(cs7)).
parameter(4,p1,dq_problem,null_value).
parameter(5,p1,dq_problem,unknown_char).


% input_process(process_id,col_schema_id)
input_process(p1,cs1).
input_process(p2,cs1).
input_process(p3,cs1).

input_process(p5,cs6).
input_process(p6,cs6).

% output_process(process_id,column_name)
output_process(p1,cs1).
output_process(p1,cs4).
output_process(p1,cs5).
output_process(p2,cs1).
output_process(p3,cs6).

output_process(p5,cs6).
output_process(p6,cs6).

% recipe(recipe_id,seq_id,process_id,prev_seq_id)
recipe(r1,1,p2,0).
recipe(r1,2,p1,1).
recipe(r1,3,p4,2).

recipe(r2,1,p3,0).
%recipe(r2,1,p1,0).
recipe(r2,2,p5,1).
recipe(r2,3,p6,2).

% column_state(col_schema_id,id)

% workflow(column_state(column_id,state_id),process_id,output_state)
% workflow is execution of process_id given a existing column_state and produce and output_state
% probably: step?
workflow(column_state(c1,1),p1,column_state(c1,2)).
workflow(column_state(c1,1),p1,column_state(c4,1)).
workflow(column_state(c1,1),p1,column_state(c5,1)).
workflow(column_state(c1,2),p2,column_state(c1,3)).
workflow(column_state(c4,1),p2,column_state(c4,2)).
workflow(column_state(c5,1),p2,column_state(c5,2)).
workflow(column_state(c4,2),p4,column_state(c7,1)).
workflow(column_state(c5,2),p4,column_state(c7,1)).
workflow(column_state(c1,3),p4,column_state(c1,4)).
workflow(column_state(c10,1),p5,column_state(c10,2)).
workflow(column_state(c10,2),p6,column_state(c10,3)).
workflow(column_state(c11,1),p1,column_state(c11,2)).
workflow(column_state(c11,2),p2,column_state(c11,3)).


% define another process with rename column_name (inject problem)
%workflow(column_state(1,2),3,column_state(6,1)).
% inject workflow(step(column_state,process))
% a plan to execute a process to an existing column_state
% supposed I inject/update a workflow by adding process 3 to the column_state(1,2) 
inject_workflow(workflow(column_state(c1,2),p3)).
inject_workflow(workflow(column_state(c1,1),p3)).


% replace a process with another process (update recipe problem)
update_workflow(workflow(column_state(c1,1),p2),p3).


% inject workflow violation
% what process will break ?
% gather input parameter (pre-condition) for process state
workflow_input(P,column_state(CIId,CIState),column_state(COId,COState),CIName,COName) :- 
    workflow(column_state(CIId,CIState),P,column_state(COId,COState)),
    column(CIId,_,CSIId,_),
    column(COId,_,CSOId,_),
    column_schema(CSIId,CIName,_),
    column_schema(CSOId,COName,_).

% update violation by column_name
inject_violation(P,OriginalP,AffectedP,CO,COName,CIAffectedName) :- 
    inject_workflow(workflow(column_state(CIId,CIState),P)),
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
#show inject_workflow/1.
#show inject_violation/6.
%#show inject_violation_checking/6.
%#show injected_parameter/4.
%#show recipe_input_sink/2.
%#show recipe_output_sink/2.
#show reuse_recipe/1.
#show reuse_violation/4.



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
%#show workflow_input/5.