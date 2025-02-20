q(X, b).
q(X, g(X)) :- p(X).

p(a).

% 1 ?- q(a,X). 
% X = b .
% 2 ?- q(a,b). 
% true.
