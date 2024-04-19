# compilation
vcom -2008 Fetch/IF_ID.vhd
vcom -2008 Tests/FetchTests/IF_ID_TestBench.vhd

# simulation
vsim -gui work.if_id_testbench

# add waves
add wave -position end sim:/if_id_testbench/i_clk
add wave -position end sim:/if_id_testbench/i_reset
add wave -position end sim:/if_id_testbench/i_pc
add wave -position end sim:/if_id_testbench/i_en
add wave -position end sim:/if_id_testbench/i_instruction
add wave -position end sim:/if_id_testbench/i_immediate
add wave -position end sim:/if_id_testbench/o_pc
add wave -position end sim:/if_id_testbench/o_instruction
add wave -position end sim:/if_id_testbench/o_immediate

# run
run
