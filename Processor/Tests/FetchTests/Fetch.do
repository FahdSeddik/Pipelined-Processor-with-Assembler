# compilation
vcom -2008 Fetch/PC.vhd
vcom -2008 Fetch/mux.vhd
vcom -2008 Fetch/mux2.vhd
vcom -2008 General/PipelineRegs/IF_ID.vhd
vcom -2008 Fetch/ImmediateHandler.vhd
vcom -2008 Fetch/InstructionMemory.vhd
vcom -2008 Fetch/NOPHandler.vhd
vcom -2008 Fetch/Fetch.vhd

# simulation
vsim -gui work.Fetch

# add waves
### inputs ###
add wave -position end sim:/fetch/i_branch_address
add wave -position end sim:/fetch/i_branch_we
add wave -position end sim:/fetch/i_predict_we
add wave -position end sim:/fetch/i_predict_address
add wave -position end sim:/fetch/i_exception
add wave -position end sim:/fetch/i_freeze
add wave -position end sim:/fetch/i_clk
add wave -position end sim:/fetch/i_reset
add wave -position end sim:/fetch/i_interrupt

### fetch outputs ###
add wave -position end  sim:/fetch/o_pc
add wave -position end  sim:/fetch/o_instruction
add wave -position end  sim:/fetch/o_immediate
add wave -position end  sim:/fetch/w_instruction_memory_out
add wave -position end  sim:/fetch/w_mux_out


#### PC signals ###
add wave -position end sim:/fetch/pc/i_instruction
add wave -position end sim:/fetch/pc/i_interrupt
add wave -position end sim:/fetch/pc/i_branch_address
add wave -position end sim:/fetch/pc/i_branch_we
add wave -position end sim:/fetch/pc/i_predict_we
add wave -position end sim:/fetch/pc/i_predict_address
add wave -position end sim:/fetch/pc/i_exception
add wave -position end sim:/fetch/pc/i_freeze
add wave -position end sim:/fetch/pc/i_clk
add wave -position end sim:/fetch/pc/i_reset
add wave -position end sim:/fetch/pc/o_address
add wave -position end  sim:/fetch/pc/o_stall
#########
add wave -position end  /fetch/pc/main_loop/r_pc
add wave -position end  /fetch/pc/main_loop/r_state
add wave -position end  /fetch/pc/main_loop/r_reset_address
add wave -position end  /fetch/pc/main_loop/r_reset_counter
add wave -position end  /fetch/pc/main_loop/r_interrupt_address
add wave -position end  /fetch/pc/main_loop/r_interrupt_counter

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
mem load -i D:/Pipelined-Processor-with-Assembler/Assembler/instructions.mem /fetch/instruction_memory/r_mem
force -freeze sim:/fetch/i_clk 1 0, 0 {5 ps} -r {10 ps}

# run
run 40 ps

force -freeze sim:/fetch/i_reset 1 0
run 10 ps

force -freeze sim:/fetch/i_reset 0 0
run 40 ps

force -freeze sim:/fetch/i_interrupt 1 0
run 10 ps

force -freeze sim:/fetch/i_interrupt 0 0
run 30 ps
