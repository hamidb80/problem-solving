ParseDataOne ← (
  regex ".*\n*"
  ♭
  ≡(⍚(⋕ regex "\\d"))
)

First ← (
  ParseDataOne
  ≡(⊢ + ×10 ⊃(⊢|⊢ ⇌) °□)
  /+
)

DigitNames ← {"zero" "one" "two" "three" "four" "five" "six" "seven" "eight" "nine"}
Digits ← "0123456789"

ParseDataTwo ← (
  DigitNames
  Digits
  ## "0123456789" 
  ≡(⍚$"_|_")
  /$"_|_"
  ## "0|zero|1|one|2|two|3|three|4|four|5|five|6|six|7|seven|8|eight|9|nine" 
  □
  ↯ [1 ∞]
  ## ╭─                                                                          
  ## ╷ ⌜0|zero|1|one|2|two|3|three|4|four|5|five|6|six|7|seven|8|eight|9|nine⌟   
  ##                                                                           ╯ 

  ⊙(regex ".*\n*")
  ## ╭─                                                                          
  ## ╷ ⌜0|zero|1|one|2|two|3|three|4|four|5|five|6|six|7|seven|8|eight|9|nine⌟   
  ##                                                                           ╯ 
  ⊢
  ≡(⍚regex)
  ## ╭─                                                                                
  ##                                                 ╓─                                
  ##   ╓─                     ╓─          ╓─         ╟ ⌜4⌟       ╓─                    
  ##   ╟ ⌜two⌟    ╓─          ╟ ⌜one⌟     ╟ ⌜two⌟      ⌜nine⌟    ╟ ⌜one⌟   ╓─          
  ##     ⌜1⌟      ╟ ⌜eight⌟     ⌜2⌟         ⌜3⌟        ⌜eight⌟     ⌜2⌟     ╟ ⌜7⌟       
  ##     ⌜nine⌟     ⌜three⌟     ⌜three⌟     ⌜four⌟     ⌜seven⌟     ⌜3⌟       ⌜six⌟     
  ##            ╜           ╜           ╜          ╜   ⌜2⌟         ⌜4⌟             ╜   
  ##                                                           ╜         ╜             
  ##                                                                                 ╯ 
)

PartTwo ← (
  ParseDataTwo
)

# ------------------------------------------

$ 1abc2
$ pqr3stu8vwx
$ a1b2c3d4e5f
$ treb7uchet

$ two1nine
$ eightwothree
$ abcone2threexyz
$ xtwone3four
$ 4nineeightseven2
$ zoneight234
$ 7pqrstsixteen

# ⊃PartOne PartTwo

PartTwo
