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

column_schema(cs1,name,full_name).
column_schema(cs1,data_type,text).
column_schema(cs2,name,first_name).
column_schema(cs2,data_type,text).
column_schema(cs3,name,last_name).
column_schema(cs3,data_type,text).
column_schema(cs4,name,date).
column_schema(cs4,data_type,text).
column_schema(cs5,data_type,text).
column_schema(cs6,name,ssn).
column_schema(cs6,data_type,text).
column_schema(cs7,name,ssn).
column_schema(cs7,data_type,number).
column_schema(cs8,data_type,number).


% process(id,name,-parameter,-description).
% process is presented as name, with "parameter" and detail execution as "description" 
process(p1,split_name).
process(p2,upper_case).
process(p3,rename_col).
process(p4,merge_col).
process(p5,normalize_char).
process(p6,normalize_date).
process(p7,fixed_ssn).
process(p8,lower_case).

% input parameter of process blueprint
% input_parameter(pid,parameter_name,parameter_value).
% entity of input_parameter for a process pid where parameter_name has parameter_value 
input_process(p1,1,cs1).
output_process(p1,1,cs1).
output_process(p1,2,cs2).
output_process(p1,3,cs3).
parameter(p1,1,dq_problem,null_value).

input_process(p2,1,cs5).
output_process(p2,1,cs5).
parameter(p2,1,dq_problem,unknown_char).

input_process(p5,1,cs5).
output_process(p5,1,cs5).
parameter(p5,1,dq_problem,unknown_char).

input_process(p6,1,cs5).
output_process(p6,1,cs8).
parameter(p6,1,dq_problem,date_format_error).

recipe_detail(r1,fixing_date_format).
recipe(r1,1,p2,0).
recipe(r1,2,p5,1).
recipe(r1,3,p6,2).


recipe_detail(r2,fixing_name).
recipe(r2,1,p1,0).
recipe(r2,2,p2,1).
recipe(r2,3,p5,2).
recipe(r2,4,p6,3).
recipe(r2,5,p3,4).

recipe(r3,1,p2,0).


% recipe to input, output, and parameter
recipe_input_process(Rid,Sid,CSid) :-
    recipe(Rid,_,Pid,_),
    input_process(Pid,Sid,CSid).

% recipe to input, output, and parameter
recipe_output_process(Rid,Sid,CSid) :-
    recipe(Rid,_,Pid,_),
    output_process(Pid,Sid,CSid).    


input_process(Rid,Sid,CSid) :-
    recipe_input_process(Rid,Sid,CSid).

output_process(Rid,Sid,CSid) :-
    recipe_output_process(Rid,Sid,CSid).

combined_process(input(Pid,B,C),Pid,output(Pid,E,F)) :-
    input_process(Pid,B,C),
    output_process(Pid,E,F).

two_hop(Rid,D,B,E,C,F):-
    recipe(Rid,B,C,D),
    recipe(Rid,E,F,B).


recipe_edge(Rid,X,Y) :- recipe(Rid,Y,_,X).

recipe_path(Rid,X,Y,via(X,1)) :- recipe_edge(Rid,X,Y).
recipe_path(Rid,X,Z,via(M,N+1)) :- recipe_edge(Rid,X,Y), recipe_path(Rid,Y,Z,via(M,N)).


select_recipe(A,B,C,D) :- recipe_path(A,B,C,D),A=r1, B=0.

% input output
%recipe_data_edge(Rid,X,Y,Pid1,Pid2,Sid1,CSid1,Sid2,CSid2) :- recipe_edge(Rid,X,Y),
%    recipe(Rid,X,Pid1,_),
%    recipe(Rid,Y,Pid2,_),
%    input_process(Pid1,Sid1,CSid1),
%    output_process(Pid2,Sid2,CSid2).

%recipe_data_edge(Rid,X,Y,Pid1,Pid2,Sid1,CSid1,Sid2,CSid2) :- recipe_edge(Rid,X,Y),
%    recipe(Rid,X,Pid1,_),
%    recipe(Rid,Y,Pid2,_),
%    input_process(Pid1,Sid1,CSid1),
%    output_process(Pid1,Sid2,CSid2).    

recipe_data_edge(Rid,X,column_schema(Sid1,CSid1),Pid,column_schema(Sid2,CSid2)) :- recipe(Rid,X,Pid,Z),
    input_process(Pid,Sid1,CSid1),
    output_process(Pid,Sid2,CSid2).

% revalidate schema changed

%#show recipe_path/4.
#show recipe_data_edge/5.
%#show two_hop/6.
%#show recipe_input_process/3.
%#show recipe_output_process/3.
%#show combined_process/3.

%0 - 1 - 2 - 3
%0 - 1 name -> name, first_name, last_name
%0 - 2 first_name -> test_name
%0 - 3 test_name, last_Name -> fixed_name

%name , first_name, test_name, last_name -> name, first_name, last_name, test_name, fixed_name

