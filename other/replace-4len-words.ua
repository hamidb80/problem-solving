# given a sentence, replace words with len 4 with "LOVE"

"a sentence from space, my name is Hamid"
♭ regex "[^ ]+"
## {"a" "sentence" "from" "space," "my" "name" "is" "Hamid"} 

≡⍚(⍥("LOVE"⋅) =4 ⧻.)
# ≡⍚(⨬(∘|⋅"LOVE") =4 ⧻.)
/$"_ _"
