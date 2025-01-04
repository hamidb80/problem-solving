# idea taken from: https://github.com/pdegarcia/APL-LISP/blob/master/p2.pdf

# here's an example using notion like functions

# the parens should be hidden in your code editor 
# in order to be seen clean and pretty

# sbcl --script code.lisp

# --------------------------------------

# :::::::: BQN code ::::::::::
# CalcPoly ←{+ 𝕨 × ⌽ 𝕩 ÷˜ ×` 𝕩 ⥊˜ ≠𝕨 }
# [ 1,    5,   6] CalcPoly 2 

# :::::::: LISP code :::::::::

(defmacro BQN (& stmt)
  (pp stmt))

(BQN
  CalcPoly ← +/ 𝕨 × ⌽ 𝕩 ÷˜ ×/ 𝕩 ⥊˜ ≠ 𝕨 .
  (1 5 6) CalcPoly 2 .
)
