#include "align_merged.pl".

last_cell_value_not(PrevStateId):-
    cell_values(_,_,_,_,PrevStateId),
    PrevStateId!="-1".

last_cell_value(Prev2,CellId,StateId,Val,PrevStateId):-
    cell_values(Prev2,CellId,StateId,Val,PrevStateId),
    not last_cell_value_not(Prev2).

cell_value_disagreement(ValueId1,ValueId2,CellId,Val1,Val2):-
    last_cell_value(ValueId1,CellId,StateId1,Val1,PrevStateId1),
    last_cell_value(ValueId2,CellId,StateId2,Val2,PrevStateId2),
    Val1!=Val2.

cell_value_agreement(ValueId1,ValueId2,CellId,Val1,Val2):-
    last_cell_value(ValueId1,CellId,StateId1,Val1,PrevStateId1),
    last_cell_value(ValueId2,CellId,StateId2,Val2,PrevStateId2),
    Val1=Val2,
    ValueId1!=ValueId2.

cell_unchanged(ValueId1,CellId,Val1):-
    last_cell_value(ValueId1,CellId,"-1",Val1,"-1").


%#show last_cell_value_not/1.
%#show last_cell_value/5.
#show cell_value_disagreement/5.
#show cell_value_agreement/5.
#show cell_unchanged/3.

%#show cell_values/5.