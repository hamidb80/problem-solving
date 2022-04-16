# 1) Create a library for working in
vlib work

# 2) Compile the half adder
vlog ring4bd.v
vlog ring4bd_test.v

# 3) optimize
vopt +acc ring4bd_test -o ring4bd_test_opt

# 4) Load it for simulation
vsim ring4bd_test_opt

# 5) Open some selected windows for viewing
view structure
view signals
view wave

# 6) Show some of the signals in the wave window
add wave -noupdate -divider -height 32 Inputs
add wave -noupdate -divider -height 32 Outputs
add wave -noupdate clock
add wave -noupdate reset
add wave -noupdate count

# 6) Set some test patterns
# a = 0, b = 0 at 0 ns
#force a 0 0
#force b 0 0

# a = 1, b = 0 at 10 ns
#force a 1 10

# a = 0, b = 1 at 20 ns
#force a 0 20
#force b 1 20

# a = 1, b = 1 at 30 ns
#force a 1 30

# 7) Run the simulation for 1800 ns
run 4000