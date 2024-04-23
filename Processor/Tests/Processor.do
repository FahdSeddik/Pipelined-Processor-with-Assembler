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


#sim
vsim -gui work.processor

# waves
add wave -position end  sim:/processor/i_clk
add wave -position end  sim:/processor/i_reset
add wave -position end  sim:/processor/i_port
add wave -position end  sim:/processor/o_port

add wave -position end  sim:/processor/F/*
add wave -position insertpoint sim:/processor/F/instruction_memory/*
add wave -position insertpoint sim:/processor/F/mux/*
add wave -position insertpoint sim:/processor/F/immediate_handling/*

add wave -position 58  sim:/processor/E/alu1/i_a
add wave -position 59  sim:/processor/E/alu1/i_b
add wave -position 60  sim:/processor/E/alu1/i_op
add wave -position 61  sim:/processor/E/alu1/o_result
add wave -position 62  sim:/processor/E/alu1/o_flags
add wave -position 63  sim:/processor/E/alu1/temp

add wave -position end  sim:/processor/D/RF/i_clk
add wave -position end  sim:/processor/D/RF/i_reset
add wave -position end  sim:/processor/D/RF/i_we0
add wave -position end  sim:/processor/D/RF/i_we1
add wave -position end  sim:/processor/D/RF/i_rAddress0
add wave -position end  sim:/processor/D/RF/i_rAddress1
add wave -position end  sim:/processor/D/RF/i_wAddress0
add wave -position end  sim:/processor/D/RF/i_wAddress1
add wave -position end  sim:/processor/D/RF/i_wData0
add wave -position end  sim:/processor/D/RF/i_wData1
add wave -position end  sim:/processor/D/RF/o_rData0
add wave -position end  sim:/processor/D/RF/o_rData1
add wave -position end  sim:/processor/D/RF/ram
add wave -position end  sim:/processor/FD/o_pc
add wave -position end  sim:/processor/FD/o_instruction
add wave -position end  sim:/processor/FD/o_immediate
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
add wave -position end  sim:/processor/EM/o_memRead
add wave -position end  sim:/processor/EM/o_memWrite
add wave -position end  sim:/processor/EM/o_WB
add wave -position end  sim:/processor/EM/o_isProtect
add wave -position end  sim:/processor/EM/o_isFree
add wave -position end  sim:/processor/EM/o_stackControl
add wave -position end  sim:/processor/EM/o_aluResult
add wave -position end  sim:/processor/EM/o_vRs2
add wave -position end  sim:/processor/EM/o_aRd
add wave -position end  sim:/processor/EM/o_aRs2
add wave -position end  sim:/processor/EM/o_pc
add wave -position end  sim:/processor/EM/o_flag
add wave -position end  sim:/processor/MW/o_memRead
add wave -position end  sim:/processor/MW/o_writeBack
add wave -position end  sim:/processor/MW/o_readData
add wave -position end  sim:/processor/MW/o_result
add wave -position end  sim:/processor/MW/o_rdstAddr
add wave -position end  sim:/processor/MW/o_rs2Addr
add wave -position end  sim:/processor/MW/o_rs2Data
add wave -position end  sim:/processor/WB/o_writeBack
add wave -position end  sim:/processor/WB/o_data
add wave -position end  sim:/processor/WB/o_rdstAddr
add wave -position end  sim:/processor/WB/o_rs2Addr
add wave -position end  sim:/processor/WB/o_rs2Data
add wave -position end  sim:/processor/ExHReg/o_EPCMem
add wave -position end  sim:/processor/ExHReg/o_EPCExec
add wave -position end  sim:/processor/ExHReg/o_exception_memory_violation
add wave -position end  sim:/processor/ExHReg/o_exception_overflow


mem load -i D:/Pipelined-Processor-with-Assembler/Assembler/instructions.mem /processor/F/instruction_memory/r_mem


force -freeze sim:/processor/i_clk 1 0, 0 {5 ps} -r {10 ps}

force -freeze sim:/processor/i_reset 1 0

run 10 ps

force -freeze sim:/processor/i_reset 0 0

run 100 ps
