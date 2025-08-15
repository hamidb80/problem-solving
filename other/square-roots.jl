
# -------------------------------------

function solveQuadraic(a, b, c)
  Δ² = b*b - 4*a*c
  if Δ² >= 0 
    x₁ = 0.5 * (-b + sqrt(Δ²)) / a
    x₂ = 0.5 * (-b - sqrt(Δ²)) / a
    [x₁, x₂]
  else [] end
end

# -------------------------------------

ans = solveQuadraic(1, 5, 6)
println(ans)
