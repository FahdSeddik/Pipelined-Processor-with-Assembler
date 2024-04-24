#compilation
vcom -2008 ./General/PipelineRegs/EX_MEM.vhd
vcom -2008 ./General/PipelineRegs/ID_EX.vhd
vcom -2008 ./General/PipelineRegs/IF_ID.vhd
vcom -2008 ./General/PipelineRegs/MEM_WB.vhd
vcom -2008 ./General/ExceptionHandlerReg.vhd
vcom -2008 ./General/BranchControl.vhd
vcom -2008 ./General/ExceptionHandlerReg.vhd
vcom -2008 ./Fetch/*
vcom -2008 ./Memory/*
vcom -2008 ./Decode/*
vcom -2008 ./Execute/*
vcom -2008 ./Processor.vhd

#simumlation
vsim -gui work.processor

# waves
add wave -label Clk -position end  sim:/processor/i_clk
add wave -label Rst -position end  sim:/processor/i_reset
add wave -label PC -position end  sim:/processor/F/pc/o_adress
add wave -label "Register Values" -position end sim:/processor/D/RF/ram
add wave -label "In port" -position end  sim:/processor/i_port
add wave -label "Out port" -position end  sim:/processor/o_port
add wave -label MemoryOutput -position end  sim:/processor/M/DataMemory1/o_dataOut
add wave -label Flags -position end  sim:/processor/E/o_flags

# loading memory
mem load -i D:/Pipelined-Processor-with-Assembler/Assembler/instructions.mem /processor/F/instruction_memory/r_mem

# clock
force -freeze sim:/processor/i_clk 1 0, 0 {5 ps} -r {10 ps}

# reset
force -freeze sim:/processor/i_reset 1 0
run 10 ps
force -freeze sim:/processor/i_reset 0 0

# run
run 3000 ps
