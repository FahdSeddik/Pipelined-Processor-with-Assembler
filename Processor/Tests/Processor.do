#compilation
########## GENERAL ##########
vcom -2008 ./General/PipelineRegs/EX_MEM.vhd
vcom -2008 ./General/PipelineRegs/ID_EX.vhd
vcom -2008 ./General/PipelineRegs/IF_ID.vhd
vcom -2008 ./General/PipelineRegs/MEM_WB.vhd
vcom -2008 ./General/ExceptionHandlerReg.vhd
vcom -2008 ./General/BranchControl.vhd
vcom -2008 ./General/ExceptionHandlerReg.vhd
########## FETCH ############
vcom -2008 ./Fetch/ImmediateHandler.vhd 
vcom -2008 ./Fetch/InstructionMemory.vhd
vcom -2008 ./Fetch/Mux.vhd
vcom -2008 ./Fetch/Mux2.vhd
vcom -2008 ./Fetch/NOPHandler.vhd 
vcom -2008 ./Fetch/PC.vhd 
vcom -2008 ./Fetch/Fetch.vhd 
#############################
vcom -2008 ./Memory/*
vcom -2008 ./Decode/*
vcom -2008 ./Execute/*
vcom -2008 ./Processor.vhd


#sim
vsim -gui work.processor

# waves
add wave -position end  sim:/processor/i_clk
add wave -position end  sim:/processor/i_reset
add wave -position end  sim:/processor/i_port
add wave -position end  sim:/processor/i_interrupt
add wave -position end  sim:/processor/o_port

add wave -position end  sim:/processor/F/*
#add wave -position insertpoint sim:/processor/F/instruction_memory/*
#add wave -position insertpoint sim:/processor/F/mux/*
#add wave -position insertpoint sim:/processor/F/immediate_handling/*


add wave -position end  sim:/processor/FD/o_pc
add wave -position end  sim:/processor/FD/o_instruction
add wave -position end  sim:/processor/FD/o_immediate

add wave -position end sim:/processor/D/RF/ram

#add wave -position 58  sim:/processor/E/alu1/*

add wave -position insertpoint sim:/processor/EM/*
add wave -position insertpoint sim:/processor/M/*

mem load -i D:/UNI/Senior-1/spring/Arch/Pipelined-Processor-with-Assembler/Assembler/instructions.mem /processor/F/instruction_memory/r_mem
add wave -position insertpoint sim:/processor/M/*
add wave -position insertpoint sim:/processor/M/DataMemory1/*
add wave -position 26 sim:/processor/D/*
add wave -position end sim:/processor/BP/*
add wave -position end sim:/processor/BC/*
force -freeze sim:/processor/i_clk 1 0, 0 {5 ps} -r {10 ps}

force -freeze sim:/processor/i_reset 1 0

run 10 ps

force -freeze sim:/processor/i_reset 0 0
force -freeze sim:/processor/i_port x\"00000005\" 0

run
run
run
run
force -freeze sim:/processor/i_interrupt 1 0
run
force -freeze sim:/processor/i_interrupt 0 0
run
run
run
run
run
run
run
run
run
run
run
run
run
run