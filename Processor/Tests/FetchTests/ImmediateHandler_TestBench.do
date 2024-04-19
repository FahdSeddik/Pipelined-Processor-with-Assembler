# compilation
vcom -2008 Fetch/ImmediateHandler.vhd
vcom -2008 Tests/FetchTests/ImmediateHandler_TestBench.vhd

# simulation
vsim -gui work.immediatehandler_testbench

# add waves
add wave -position end sim:/immediatehandler_testbench/i_input
add wave -position end sim:/immediatehandler_testbench/i_clk
add wave -position end sim:/immediatehandler_testbench/o_instruction
add wave -position end sim:/immediatehandler_testbench/o_immediate

# run
run
