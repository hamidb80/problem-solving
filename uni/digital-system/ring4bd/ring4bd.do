# 1) Create a library for working in
vlib work

# 2) Compile the half adder
vlog ring4bd.v
vlog ring4bd_test.v

# 3) Load it for simulation
vsim ring4bd_test

# 4) Open some selected windows for viewing
view structure
view signals
view wave

# 5) Show some of the signals in the wave window
add wave -noupdate -divider -height 32 Inputs
add wave -noupdate -divider -height 32 Outputs
add wave -noupdate clock
add wave -noupdate reset
add wave -noupdate count

# 6) Run the simulation for 1800 ns
run 4000