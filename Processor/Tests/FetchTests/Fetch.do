# compilation
vcom -2008 Fetch/PC.vhd
vcom -2008 Fetch/mux.vhd
vcom -2008 Fetch/IF_ID.vhd
vcom -2008 Fetch/ImmediateHandler.vhd
vcom -2008 Fetch/InstructionMemory.vhd
vcom -2008 Fetch/Fetch.vhd

# simulation
vsim -gui work.Fetch

# add waves
### inputs ###
add wave -position end  sim:/fetch/i_branch
add wave -position end  sim:/fetch/i_we
add wave -position end  sim:/fetch/i_exception
add wave -position end  sim:/fetch/i_freeze
add wave -position end  sim:/fetch/i_clk
### fetch outputs ###
add wave -position end  sim:/fetch/o_pc
add wave -position end  sim:/fetch/o_instruction
add wave -position end  sim:/fetch/o_immediate
add wave -position end  sim:/fetch/w_instruction_memory_out
add wave -position end  sim:/fetch/w_mux_out


#### PC signals ###
#add wave -position end  sim:/fetch/pc/i_branch
#add wave -position end  sim:/fetch/pc/i_we
#add wave -position end  sim:/fetch/pc/i_exception
#add wave -position end  sim:/fetch/pc/i_freeze
#add wave -position end  sim:/fetch/pc/i_clk
#add wave -position end  sim:/fetch/pc/o_adress
#add wave -position end  sim:/fetch/pc/r_pc
#add wave -position end  sim:/fetch/pc/c_exception_handler

### instr mem signals ###
#add wave -position end  sim:/fetch/instruction_memory/i_address
#add wave -position end  sim:/fetch/instruction_memory/o_instruction
#add wave -position end  sim:/fetch/instruction_memory/r_mem

### mux signals ###
#add wave -position end  sim:/fetch/mux/i_input
#add wave -position end  sim:/fetch/mux/i_selector
#add wave -position end  sim:/fetch/mux/o_output

#### immediate handling signals ###
#add wave -position end  sim:/fetch/immediate_handling/i_clk
#add wave -position end  sim:/fetch/immediate_handling/i_input
#add wave -position end  sim:/fetch/immediate_handling/o_instruction
#add wave -position end  sim:/fetch/immediate_handling/o_immediate
#add wave -position end  sim:/fetch/immediate_handling/r_state
#add wave -position end  sim:/fetch/immediate_handling/r_instruction
#add wave -position end  sim:/fetch/immediate_handling/r_immediate
#add wave -position end  sim:/fetch/immediate_handling/r_temp

# mem load 
mem load -i D:/Pipelined-Processor-with-Assembler/Processor/Tests/FetchTests/InstructionMemory.mem /fetch/instruction_memory/r_mem

force -freeze sim:/fetch/i_clk 0 0, 1 {5 ps} -r {10 ps}

# run
run 100 ps