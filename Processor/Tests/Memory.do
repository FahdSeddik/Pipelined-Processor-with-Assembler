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
add wave -position end  sim:/processor/o_port

add wave -position end -color Yellow sim:/processor/FD/o_pc
add wave -position end  -color Yellow sim:/processor/FD/o_instruction
add wave -position end -color Yellow sim:/processor/FD/o_immediate

add wave -position end sim:/processor/D/RF/ram
add wave -position end  sim:/processor/E/o_flags
add wave -position end  sim:/processor/i_clk
add wave -position end  sim:/processor/i_reset
add wave -position end  sim:/processor/i_port
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

#add wave -position end  sim:/processor/D/RF/*
add wave -position end  sim:/processor/DE/o_WB
add wave -position end  sim:/processor/DE/o_stackControl
add wave -position end  sim:/processor/DE/o_memWrite
add wave -position end  sim:/processor/DE/o_memRead
add wave -position end  sim:/processor/DE/o_inputEnable
add wave -position end  sim:/processor/DE/o_outputEnable
add wave -position end  sim:/processor/DE/o_isImm
add wave -position end  sim:/processor/DE/o_isProtect
add wave -position end  sim:/processor/DE/o_isFree
add wave -position end  sim:/processor/DE/o_branchControl
add wave -position end  sim:/processor/DE/o_aluOP
add wave -position end  sim:/processor/DE/o_vRs1
add wave -position end  sim:/processor/DE/o_vRs2
add wave -position end  sim:/processor/DE/o_vImmediate
add wave -position end  sim:/processor/DE/o_aRs1
add wave -position end  sim:/processor/DE/o_aRs2
add wave -position end  sim:/processor/DE/o_aRd
add wave -position end  sim:/processor/DE/o_pc
add wave -position end  sim:/processor/EM/*
add wave -position end  sim:/processor/M/*
add wave -position end  sim:/processor/MW/*
add wave -position end  sim:/processor/WB/o_writeBack
add wave -position end  sim:/processor/WB/o_data
add wave -position end  sim:/processor/WB/o_rdstAddr
add wave -position end  sim:/processor/WB/o_rs2Addr
add wave -position end  sim:/processor/WB/o_rs2Data
add wave -position end  sim:/processor/ExHReg/o_EPCMem
add wave -position end  sim:/processor/ExHReg/o_EPCExec
add wave -position end  sim:/processor/ExHReg/o_exception_memory_violation
add wave -position end  sim:/processor/ExHReg/o_exception_overflow
add wave -position end  sim:/processor/E/s_flags
add wave -position 53 sim:/processor/E/*
add wave -position 101 sim:/processor/DE/*
mem load -i D:/Pipelined-Processor-with-Assembler/Assembler/instructions.mem /processor/F/instruction_memory/r_mem

force -freeze sim:/processor/i_clk 1 0, 0 {5 ps} -r {10 ps}

force -freeze sim:/processor/i_reset 1 0
force -freeze sim:/processor/i_interrupt 0 0
run 10 ps

force -freeze sim:/processor/i_reset 0 0

run 30 ps
force -freeze sim:/processor/i_port 00000000000000000000000000011001 0
run 10 ps
force -freeze sim:/processor/i_port 11111111111111111111111111111111 0
run 10 ps
force -freeze sim:/processor/i_port 11111111111111111111001100100000 0
#60
run 80 ps
force -freeze sim:/processor/i_port 00000000000000000000000000010000 0
#140
run 100 ps
force -freeze sim:/processor/i_port 00000000000000000000000000010000 0
run 10 ps
force -freeze sim:/processor/i_port 00000000000000000000000000011001 0
#250
run 80 ps
force -freeze sim:/processor/i_port 00000000000000000000001000010001 0
#330
run 20 ps
force -freeze sim:/processor/i_port 00000000000000000000001000010001 0
run 60 ps
force -freeze sim:/processor/i_port 00000000000000000000000100000000 0

run 3000 ps
