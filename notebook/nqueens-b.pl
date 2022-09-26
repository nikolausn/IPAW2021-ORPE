{ queen(I,1..n) } == 1 :- I = 1..n.
{ queen(1..n,J) } == 1 :- J = 1..n.

:- { queen(I,J) : D = I+J-1 } >= 2, D=1..2*n-1.
:- { queen(I,J) : D = I-J+n } >= 2, D=1..2*n-1.