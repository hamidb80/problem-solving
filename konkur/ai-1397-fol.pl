p(f(X)) :- p(X).
p(a).

q(f(X)) :- p(X), q(X).
q(a).

% run `trace.` and then enter your query `q(f(f(a))).`