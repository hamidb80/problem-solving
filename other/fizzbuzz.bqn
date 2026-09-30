Map ← {𝕩‿"fizz"‿"buzz"‿"fizzbuzz" ⊑˜ |𝕩×𝕩<0}
FizzBuzz ← { Map ¨ (((1+↕𝕩)×0=⊢) + -) +´ ˘ ⍉ 1‿2 × 0= 3‿5 |⌜ 1+↕𝕩 }
FizzBuzz 20
# ⟨ 1 2 "fizz" 4 "buzz" "fizz" 7 8 "fizz" "buzz" 11 "fizz" 13 14 "fizzbuzz" 16 17 "fizz" 19 "buzz" ⟩
