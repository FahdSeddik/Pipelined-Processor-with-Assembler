# compilation
vcom -2008 Fetch/mux.vhd
vcom -2008 Tests/FetchTests/mux_TestBench.vhd

# simulation
vsim -gui work.mux_testbench

# add waves
add wave -position end sim:/mux_testbench/i_input
add wave -position end sim:/mux_testbench/i_selector
add wave -position end sim:/mux_testbench/o_output

# run
run
