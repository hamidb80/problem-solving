# 1) Create a library for working in
vlib work

# 2) Compile the half adder
vlog clocks.v

# 3) Load it for simulation
vsim clocks

# 4) Open some selected windows for viewing
view structure
view signals
view wave

# 5) Show some of the signals in the wave window
add wave -noupdate -divider -height 32 Inputs
add wave -noupdate -divider -height 32 Outputs
add wave -noupdate clk
add wave -noupdate clk2
add wave -noupdate clk3
add wave -noupdate clk4
add wave -noupdate clk5
add wave -noupdate clk6
add wave -noupdate clk7
add wave -noupdate clk8

# 6) Run the simulation for 1800 ns
run 1000