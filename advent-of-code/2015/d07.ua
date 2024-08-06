$ 123 -> x
$ 456 -> y
$ x AND y -> d
$ x OR y -> e
$ x LSHIFT 2 -> f
$ y RSHIFT 2 -> g
$ NOT x -> h
$ NOT y -> i

♭ regex "[^\n]+"
## {"123 -> x" "456 -> y" "x AND y -> d" "x OR y -> e" "x LSHIFT 2 -> f" "y RSHIFT 2 -> g" "NOT x -> h" "NOT y -> i"} 
≡(
  ↘ 1⊢ regex "(.*) -> (.*)"

  ⊏ 0
  °□

  regex "[A-Z]+" .

  ## ╭─        ╭─        ╭─        ╭─       ╭─           ╭─           ╭─        ╭─        
  ## ╷ 0×1 □   ╷ 0×1 □   ╷ ⌜AND⌟   ╷ ⌜OR⌟   ╷ ⌜LSHIFT⌟   ╷ ⌜RSHIFT⌟   ╷ ⌜NOT⌟   ╷ ⌜NOT⌟   
  ##         ╯         ╯         ╯        ╯            ╯            ╯         ╯         ╯ 
  # regex "[a-z]+"

  :
  regex "[a-z0-9]+"
  ## ╭─        ╭─        ╭─      ╭─      ╭─      ╭─      ╭─      ╭─      
  ## ╷ ⌜123⌟   ╷ ⌜456⌟   ╷ ⌜x⌟   ╷ ⌜x⌟   ╷ ⌜x⌟   ╷ ⌜y⌟   ╷ ⌜x⌟   ╷ ⌜y⌟   
  ##         ╯         ╯   ⌜y⌟     ⌜y⌟     ⌜2⌟     ⌜2⌟         ╯       ╯ 
  ##                           ╯       ╯       ╯       ╯         

  ≡⊂
  ## ╭─        ╭─        ╭─            ╭─           ╭─               ╭─               ╭─            ╭─            
  ## ╷ 0×2 □   ╷ 0×2 □   ╷ ⌜x⌟ ⌜AND⌟   ╷ ⌜x⌟ ⌜OR⌟   ╷ ⌜x⌟ ⌜LSHIFT⌟   ╷ ⌜y⌟ ⌜RSHIFT⌟   ╷ ⌜x⌟ ⌜NOT⌟   ╷ ⌜y⌟ ⌜NOT⌟   
  ##         ╯         ╯   ⌜y⌟ ⌜AND⌟     ⌜y⌟ ⌜OR⌟     ⌜2⌟ ⌜LSHIFT⌟     ⌜2⌟ ⌜RSHIFT⌟               ╯             ╯ 
  ##                                 ╯            ╯                ╯                ╯               
  △
  ## [0 2] [0 2] [2 2] [2 2] [2 2] [2 2] [1 2] [1 2] 

  "NOT "
  "AND "
  "OR "
  "LSHIFT "
  "RSHIFT "
)
# ≡(⧻ °□)
## ╭─            
## ╷ "RSHIFT "   
##   "RSHIFT "   
##   "RSHIFT "   
##   "RSHIFT "   
##   "RSHIFT "   
##   "RSHIFT "   
##   "RSHIFT "   
##   "RSHIFT "   
##             ╯ 
