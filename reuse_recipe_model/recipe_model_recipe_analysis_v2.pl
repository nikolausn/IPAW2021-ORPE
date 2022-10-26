% column_schema(id,name,data_type).
% a column is presented as "name", with "date_type"
column_schema(cs1,name,full_name). column_schema(cs1,data_type,text).
column_schema(cs2,name,first_name). column_schema(cs2,data_type,text).
column_schema(cs3,name,last_name). column_schema(cs3,data_type,text).
column_schema(cs4,name,date). column_schema(cs4,data_type,text).
column_schema(cs5,data_type,text).
column_schema(cs6,name,ssn). column_schema(cs6,data_type,text).
column_schema(cs7,name,ssn). column_schema(cs7,data_type,number).
column_schema(cs8,data_type,number).
column_schema(cs9,name,fixed_name). column_schema(cs9,data_type,text).


% process(id,name).
% process is presented as name
process(p1,split_name).
process(p2,upper_case).
process(p3,rename_col).
process(p4,merge_col).
process(p5,normalize_char).
process(p6,normalize_date).
process(p7,fixed_ssn).
process(p8,lower_case).
process(p9,standard2).

% input parameter of process blueprint
% entity of input_parameter for a process pid where parameter_name has parameter_value 
input_process(p1,1,cs1).
output_process(p1,1,cs1).
output_process(p1,2,cs2).
output_process(p1,3,cs3).
output_process(p1,4,cs4).
% input_parameter(pid,parameter_name,parameter_value).
% dq_problem can be represented as a parameter: goal of a process
parameter(p1,1,dq_problem,null_value).
parameter(p1,3,dq_problem,split_name).

input_process(p2,1,cs2).
output_process(p2,1,cs2).
parameter(p2,1,dq_problem,unknown_char).

input_process(p3,1,cs5).
output_process(p3,1,cs5).
parameter(p3,1,dq_problem,wrong_column_name).

input_process(p4,1,cs2).
input_process(p4,2,cs3).
output_process(p4,1,cs9).
parameter(p4,1,dq_problem,merge_name).

input_process(p5,1,cs5).
output_process(p5,1,cs5).
parameter(p5,1,dq_problem,unknown_char).

input_process(p6,1,cs4).
output_process(p6,1,cs8).
parameter(p6,1,dq_problem,date_format_error).

input_process(p7,1,cs6).
output_process(p7,1,cs7).
parameter(p7,1,dq_problem,format_ssn).

input_process(p8,1,cs5).
output_process(p8,1,cs5).
parameter(p8,1,dq_problem,lower_case).

input_process(p9,1,cs2).
input_process(p9,2,cs3).
output_process(p9,1,cs5).
output_process(p9,3,cs7).


recipe(r1,1,p1,0).
recipe(r1,2,p2,1).
recipe(r1,3,p4,2).
recipe(r1,4,p5,3).
recipe(r1,5,p6,3).
recipe(r1,6,p9,1).

all_recipe_input(Rid,CSin) :-
    recipe(Rid,_,Pid,_),
    input_process(Pid,_,CSin).

all_recipe_output(Rid,CSout) :-
    recipe(Rid,_,Pid,_),
    output_process(Pid,_,CSout).

%#show all_recipe_input/2.
%#show all_recipe_output/2.

recipe_edge(Rid,Pid1,Pid2,seq(RSeq1,RSeq2)) :- recipe(Rid,RSeq1,Pid1,Rprev),
            recipe(Rid,RSeq2,Pid2,RSeq1).

recipe_path(Rid,Pid1,Pid2,seq(RSeq1,RSeq2,0)) :- recipe_edge(Rid,Pid1,Pid2,seq(RSeq1,RSeq2)).
recipe_path(Rid,Pid1,Pid3,seq(seq(RSeq3,RSeq4),seq(RSeq1,RSeq2,N),N+1)) :- recipe_edge(Rid,Pid1,Pid2,seq(RSeq3,RSeq4)),
                    recipe_path(Rid,Pid2,Pid3,seq(RSeq1,RSeq2,N)).

acc_input(Rid,Pid2,Pid1,CSin,seq(RSeq1,RSeq2)) :- recipe_edge(Rid,Pid1,Pid2,seq(RSeq1,RSeq2)),
    process_io(Pid1,CSin,CSout).

acc_input(Rid,Pid2,Pid1,CSin,seq(RSeq1,RSeq2)) :- recipe_edge(Rid,Pid1,Pid2,seq(RSeq1,RSeq2)),
    process_io(Pid2,CSin,CSout).

%acc_output_derived(Rid,Pid2,Pid1,CSin,seq(RSeq1,RSeq2)) :- acc_input(Rid,Pid2,Pid1,CSin,seq(RSeq1,RSeq2)).

%acc_output(Rid,Pid2,Pid1,CSin,seq(RSeq1,RSeq2)) :- acc_input(Rid,Pid2,Pid1,CSin,seq(RSeq1,RSeq2)),
%    not process_io(Pid1,CSin,_).

acc_output(Rid,Pid2,Pid1,CSout,seq(RSeq1,RSeq2)) :- acc_input(Rid,Pid2,Pid1,CSin,seq(RSeq1,RSeq2)),
    process_io(Pid1,_,CSout).

acc_output(Rid,Pid2,Pid1,CSout,seq(RSeq1,RSeq2)) :- acc_input(Rid,Pid2,Pid1,CSin,seq(RSeq1,RSeq2)),
    process_io(Pid2,_,CSout).

acc_output(Rid,Pid2,Pid1,CSin,seq(RSeq1,RSeq2)) :-
    recipe_edge(Rid,Pid1,Pid2,seq(RSeq1,RSeq2)),
    process_io(Pid2,CSin,_),
    not process_io(Pid1,CSin,_).

acc_output_not(Rid,Pid2,Pid1,CSout,seq(RSeq1,RSeq2)) :-
    acc_output(Rid,Pid2,Pid1,CSout,seq(RSeq1,RSeq2)),
    not process_io(Pid1,_,CSout).

acc_output_derived(Rid,Pid2,Pid1,CSout,seq(RSeq1,RSeq2)) :-
    acc_output(Rid,Pid2,Pid1,CSout,seq(RSeq1,RSeq2)),
    not acc_output_not(Rid,Pid2,Pid1,CSout,seq(RSeq1,RSeq2)).

acc_output_derived(Rid,Pid2,Pid1,CSout,seq(RSeq1,RSeq2)) :-
    acc_output(Rid,Pid2,Pid1,CSout,seq(RSeq1,RSeq2)),
    not process_io(Pid1,CSout,_).    

%column_path(C1,C2,Pid) :- column_edge(C1,C2,Pid).
%column_path(C2,C3,Pid) :- column_edge(C1,C2,Pid),column_path(C2,C3,_).

process_io(Pid,CSin,CSout) :- process(Pid,_), input_process(Pid,_,CSin), output_process(Pid,_,CSout).

recipe_edge_io(Rid,Pid1,Pid2,seq(RSeq1,RSeq2),process_io(Pid1,CSin1,CSout1),process_io(Pid2,CSin2,CSout2)) :- 
    recipe_edge(Rid,Pid1,Pid2,seq(RSeq1,RSeq2)),
    process_io(Pid1,CSin1,CSout1),
    process_io(Pid2,CSin2,CSout2).

recipe_edge_con(Rid,Pid1,Pid2,seq(RSeq1,RSeq2),CSin1,CSout1,CSout2) :- recipe_edge(Rid,Pid1,Pid2,seq(RSeq1,RSeq2)),
    process_io(Pid1,CSin1,CSout1),
    process_io(Pid2,CSout1,CSout2).

serialize_recipe_path(Rid,Pid2,Pid1,S1,N,S2,seq(S1,S2,N),0) :-
    recipe_path(Rid,Pid1,Pid2,seq(S1,S2,N)).
    
serialize_recipe_path(Rid,Pid1,Pid2,S1,N,S2,Sign,M+1) :-
    serialize_recipe_path(Rid,Pid1,Pid2,_,_,seq(S1,S2,N),Sign,M), N>0.

serialize_recipe_path(Rid,Pid1,Pid2,seq(S1,S2),0,-1,Sign,M+1) :-
    serialize_recipe_path(Rid,Pid1,Pid2,_,_,seq(S1,S2,N),Sign,M), N=0.


%#show acc_output/5.

%#show acc_output_derived/5.

select_acc_output_not(Rid,p1,p9,CSout,seq(RSeq1,RSeq2)) :-
    acc_output_not(Rid,p1,p9,CSout,seq(RSeq1,RSeq2)).

select_acc_output_derived(Rid,p1,p9,CSout,seq(RSeq1,RSeq2)) :-
    acc_output_derived(Rid,p1,p9,CSout,seq(RSeq1,RSeq2)).

select_acc_output(Rid,p1,p9,CSout,seq(RSeq1,RSeq2)) :-
    acc_output(Rid,p1,p9,CSout,seq(RSeq1,RSeq2)).

select_process_io(p9,CSin,CSout) :-
    process_io(p9,CSin,CSout).

%#show recipe_path/4.
%#show serialize_recipe_path/6.

select_serialize_recipe(Rid,A,B,S1,M,Sign,N) :- 
    serialize_recipe_path(Rid,B,A,S1,N,S2,Sign,M),
    A = p1,
    B = p5.

select_serialize_derived_input(Rid,A,B,seq(S1,S2),M,Sign,N,CSin) :-
    select_serialize_recipe(Rid,A,B,seq(S1,S2),M,Sign,N),
    recipe(Rid,S1,P1,_),
    M=0,
    all_recipe_input(Rid,CSin),
    not input_process(P1,_,CSin).

select_serialize_derived_input(Rid,A,B,seq(S1,S2),M,Sign,N,CSout) :-
    select_serialize_recipe(Rid,A,B,seq(S1,S2),M,Sign,N),
    recipe(Rid,S1,P1,_),
    M=0,
    output_process(P1,_,CSout). 

select_serialize_derived_input(Rid,A,B,seq(S1,S2),M,Sign,N,CSout) :-
    select_serialize_recipe(Rid,A,B,seq(S1,S2),M,Sign,N),
    recipe(Rid,S2,P1,_),
    M=0,
    output_process(P1,_,CSout).     

select_serialize_derived_input(Rid,A1,B1,seq(S3,S4),M1,Sign,N1,CSin) :-
    select_serialize_recipe(Rid,A1,B1,seq(S3,S4),M1,Sign,N1),
    select_serialize_derived_input(Rid,A1,B1,seq(S1,S2),M2,Sign,N2,CSin),
    recipe(Rid,S4,P4,_),
    M1>0,
    %M2=M1-1,
    S2=S3,
    not input_process(P4,_,CSin).

select_serialize_derived_input(Rid,A1,B1,seq(S3,S4),M1,Sign,N1,CSout) :-
    select_serialize_recipe(Rid,A1,B1,seq(S3,S4),M1,Sign,N1),
    recipe(Rid,S4,P4,_),
    M1>0,
    output_process(P4,_,CSout).


#show select_serialize_derived_input/8.
#show all_recipe_input/2.



%#show select_serialize_recipe/6.

%#show acc_output_derived/5.
%#show select_acc_output_derived/5.
%#show select_acc_output/5.
%#show select_acc_output_not/5.
%#show select_process_io/3.


%#show recipe_edge/4.
%#show process_io/3.
%#show recipe_edge_io/6.
%#show recipe_edge_con/7.
