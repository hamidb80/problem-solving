# problem: https://apl.quest/psets/2023.html?goto=P8_Critical_Thinking
#
# the solution is almost complete, but it gives the date as days from 1/1/1
# to get real date, you should implement D2dt function ...
# --------------------------------------------------------

days_in_month ← [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

IsLeap        ← {≠´ 0= 400‿100‿4 |⌜ 𝕩}
Lcm           ← •math.LCM ´

Dt2d ← { # convert date to days from 1/1/1
  y‿m‿d   ← 𝕩
  
  y_days  ← (365×y-1) 
  l_years ← (⌊y÷4) + (-⌊y÷100) + (⌊y÷400)
  m_days  ← (+´ days_in_month × m > ↕12)
  is_leap ← (2<m)  ∧ (IsLeap y)

  d + y_days + m_days + l_years + is_leap
}

D2dt ← { # TODO convert days from 1/1/1 to date 
  𝕩
}

Fn ← {
  dd ← -´ Dt2d ¨ 𝕩‿𝕨 # delta days
  p  ← ⟨23‿28‿33, 23‿28, 28‿33, 23‿33⟩ # periods
  pd ← 2 ÷˜ Lcm ¨ p # period dists
  m  ← ⌊´ pd × 1 - 1 | ˘ dd ÷ pd # closest critical day distance
  D2dt m + Dt2d 𝕩
}

# •Show Dt2d 2000‿1‿1 # 2000‿1‿1 => 730121 days
•Show 1962‿10‿31 Fn 2023‿1‿1 # 738586
------------------
