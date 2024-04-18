# compilation
vcom -2008 Fetch/PC.vhd
vcom -2008 Tests/FetchTests/PC_TestBench.vhd

# simulation
vsim -gui work.pc_testbench

# add waves
add wave -position end  sim:/pc_testbench/i_branch
add wave -position end  sim:/pc_testbench/i_we
add wave -position end  sim:/pc_testbench/i_exception
add wave -position end  sim:/pc_testbench/i_freeze
add wave -position end  sim:/pc_testbench/i_clk
add wave -position end  sim:/pc_testbench/o_adress

# run
run