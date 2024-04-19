# compilation
vcom -2008 Fetch/PC.vhd
vcom -2008 Fetch/mux.vhd
vcom -2008 Fetch/IF_ID.vhd
vcom -2008 Fetch/ImmediateHandler.vhd
vcom -2008 Fetch/InstructionMemory.vhd
vcom -2008 Fetch/Fetch.vhd
vcom -2008 Tests/FetchTests/Fetch_TestBench.vhd

# simulation
vsim -gui work.Fetch_TestBench

# add waves
add wave -position end  sim:/Fetch_TestBench/w_i_branch
add wave -position end  sim:/Fetch_TestBench/w_i_we
add wave -position end  sim:/Fetch_TestBench/w_i_exception
add wave -position end  sim:/Fetch_TestBench/w_i_freeze
add wave -position end  sim:/Fetch_TestBench/w_i_clk
add wave -position end  sim:/Fetch_TestBench/w_i_reset

add wave -position end  sim:/Fetch_TestBench/w_o_pc
add wave -position end  sim:/Fetch_TestBench/w_o_instruction
add wave -position end  sim:/Fetch_TestBench/w_o_immediate

## pc 
#add wave -position end  sim:/fetch_testbench/fetch/pc/i_branch
#add wave -position end  sim:/fetch_testbench/fetch/pc/i_we
#add wave -position end  sim:/fetch_testbench/fetch/pc/i_exception
#add wave -position end  sim:/fetch_testbench/fetch/pc/i_freeze
#add wave -position end  sim:/fetch_testbench/fetch/pc/i_clk
#add wave -position end  sim:/fetch_testbench/fetch/pc/o_adress
#add wave -position end  sim:/fetch_testbench/fetch/pc/r_pc
#add wave -position end  sim:/fetch_testbench/fetch/pc/c_exception_handler

## mem
#add wave -position end  sim:/fetch_testbench/fetch/instruction_memory/i_address
#add wave -position end  sim:/fetch_testbench/fetch/instruction_memory/o_instruction
#add wave -position end  sim:/fetch_testbench/fetch/instruction_memory/r_mem

## mux
#add wave -position end  sim:/fetch_testbench/fetch/mux/i_input
#add wave -position end  sim:/fetch_testbench/fetch/mux/i_selector
#add wave -position end  sim:/fetch_testbench/fetch/mux/o_output

## imediate
#add wave -position end  sim:/fetch_testbench/fetch/immediate_handling/i_clk
#add wave -position end  sim:/fetch_testbench/fetch/immediate_handling/i_input
#add wave -position end  sim:/fetch_testbench/fetch/immediate_handling/o_instruction
#add wave -position end  sim:/fetch_testbench/fetch/immediate_handling/o_immediate
#add wave -position end  sim:/fetch_testbench/fetch/immediate_handling/r_state
#add wave -position end  sim:/fetch_testbench/fetch/immediate_handling/r_instruction
#add wave -position end  sim:/fetch_testbench/fetch/immediate_handling/r_immediate
#add wave -position end  sim:/fetch_testbench/fetch/immediate_handling/r_temp

## fetch as a whole
#add wave -position end  sim:/fetch_testbench/fetch/i_branch
#add wave -position end  sim:/fetch_testbench/fetch/i_we
#add wave -position end  sim:/fetch_testbench/fetch/i_exception
#add wave -position end  sim:/fetch_testbench/fetch/i_freeze
#add wave -position end  sim:/fetch_testbench/fetch/i_clk
#add wave -position end  sim:/fetch_testbench/fetch/o_pc
#add wave -position end  sim:/fetch_testbench/fetch/o_instruction
#add wave -position end  sim:/fetch_testbench/fetch/o_immediate
#add wave -position end  sim:/fetch_testbench/fetch/w_instruction_memory_out
#add wave -position end  sim:/fetch_testbench/fetch/w_mux_out


# mem load
mem load -i D:/Pipelined-Processor-with-Assembler/Processor/Tests/FetchTests/InstructionMemory.mem /fetch_testbench/fetch/instruction_memory/r_mem

# run
run