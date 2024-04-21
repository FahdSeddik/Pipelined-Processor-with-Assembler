#sim
vsim -gui work.processor

# waves
add wave -position end  sim:/processor/i_clk
add wave -position end  sim:/processor/i_reset
add wave -position end  sim:/processor/i_port
add wave -position end  sim:/processor/o_port

## fd
#add wave -position end  sim:/processor/FD/i_clk
#add wave -position end  sim:/processor/FD/i_reset
#add wave -position end  sim:/processor/FD/i_pc
#add wave -position end  sim:/processor/FD/i_en
#add wave -position end  sim:/processor/FD/i_instruction
#add wave -position end  sim:/processor/FD/i_immediate
add wave -position end  sim:/processor/FD/o_pc
add wave -position end  sim:/processor/FD/o_instruction
add wave -position end  sim:/processor/FD/o_immediate

# rf
#add wave -position 49  sim:/processor/D/RF/i_clk
#add wave -position 50  sim:/processor/D/RF/i_reset
#add wave -position 51  sim:/processor/D/RF/i_we0
#add wave -position 52  sim:/processor/D/RF/i_we1
#add wave -position 53  sim:/processor/D/RF/i_rAddress0
#add wave -position 54  sim:/processor/D/RF/i_rAddress1
#add wave -position 55  sim:/processor/D/RF/i_wAddress0
#add wave -position 56  sim:/processor/D/RF/i_wAddress1
#add wave -position 57  sim:/processor/D/RF/i_wData0
#add wave -position 58  sim:/processor/D/RF/i_wData1
add wave -position 59  sim:/processor/D/RF/o_rData0
add wave -position 60  sim:/processor/D/RF/o_rData1
add wave -position 61  sim:/processor/D/RF/ram

## de
#add wave -position end  sim:/processor/DE/i_clk
#add wave -position end  sim:/processor/DE/i_reset
#add wave -position end  sim:/processor/DE/i_en
#add wave -position end  sim:/processor/DE/i_WB
#add wave -position end  sim:/processor/DE/i_stackControl
#add wave -position end  sim:/processor/DE/i_memWrite
#add wave -position end  sim:/processor/DE/i_memRead
#add wave -position end  sim:/processor/DE/i_inputEnable
#add wave -position end  sim:/processor/DE/i_outputEnable
#add wave -position end  sim:/processor/DE/i_isImm
#add wave -position end  sim:/processor/DE/i_isProtect
#add wave -position end  sim:/processor/DE/i_isFree
#add wave -position end  sim:/processor/DE/i_branchControl
#add wave -position end  sim:/processor/DE/i_aluOP
#add wave -position end  sim:/processor/DE/i_vRs1
#add wave -position end  sim:/processor/DE/i_vRs2
#add wave -position end  sim:/processor/DE/i_vImmediate
#add wave -position end  sim:/processor/DE/i_aRs1
#add wave -position end  sim:/processor/DE/i_aRs2
#add wave -position end  sim:/processor/DE/i_aRd
#add wave -position end  sim:/processor/DE/i_pc
#add wave -position end  sim:/processor/DE/o_WB
#add wave -position end  sim:/processor/DE/o_stackControl
#add wave -position end  sim:/processor/DE/o_memWrite
#add wave -position end  sim:/processor/DE/o_memRead
#add wave -position end  sim:/processor/DE/o_inputEnable
#add wave -position end  sim:/processor/DE/o_outputEnable
#add wave -position end  sim:/processor/DE/o_isImm
#add wave -position end  sim:/processor/DE/o_isProtect
#add wave -position end  sim:/processor/DE/o_isFree
#add wave -position end  sim:/processor/DE/o_branchControl
#add wave -position end  sim:/processor/DE/o_aluOP
#add wave -position end  sim:/processor/DE/o_vRs1
#add wave -position end  sim:/processor/DE/o_vRs2
#add wave -position end  sim:/processor/DE/o_vImmediate
#add wave -position end  sim:/processor/DE/o_aRs1
#add wave -position end  sim:/processor/DE/o_aRs2
#add wave -position end  sim:/processor/DE/o_aRd
#add wave -position end  sim:/processor/DE/o_pc


# fetch
#add wave -position end  sim:/processor/F/i_branch
#add wave -position end  sim:/processor/F/i_we
#add wave -position end  sim:/processor/F/i_exception
#add wave -position end  sim:/processor/F/i_freeze
#add wave -position end  sim:/processor/F/i_clk
#add wave -position end  sim:/processor/F/o_pc
#add wave -position end  sim:/processor/F/o_instruction
#add wave -position end  sim:/processor/F/o_immediate
#add wave -position end  sim:/processor/F/w_instruction_memory_out
#add wave -position end  sim:/processor/F/w_mux_out
    # fetch pc
        #add wave -position end  sim:/processor/F/pc/i_reset
        #add wave -position end  sim:/processor/F/pc/i_interrupt
        #add wave -position end  sim:/processor/F/pc/i_branch
        #add wave -position end  sim:/processor/F/pc/i_we
        #add wave -position end  sim:/processor/F/pc/i_exception
        #add wave -position end  sim:/processor/F/pc/i_freeze
        #add wave -position end  sim:/processor/F/pc/i_clk
        #add wave -position end  sim:/processor/F/pc/o_adress
        #add wave -position end  sim:/processor/F/pc/r_pc
        #add wave -position end  sim:/processor/F/pc/c_exception_handler
        #add wave -position end  sim:/processor/F/pc/c_reset_adress
        #add wave -position end  sim:/processor/F/pc/c_interrupt_handler
    # fetch IM
        #add wave -position end  sim:/processor/F/instruction_memory/i_address
        #add wave -position end  sim:/processor/F/instruction_memory/o_instruction
        #add wave -position end  sim:/processor/F/instruction_memory/r_mem
    # fetch mux
        #add wave -position end  sim:/processor/F/mux/i_input
        #add wave -position end  sim:/processor/F/mux/i_selector
        #add wave -position end  sim:/processor/F/mux/o_output
    # fetch IMHandling


mem load -i D:/Pipelined-Processor-with-Assembler/Assembler/instructions.mem /processor/F/instruction_memory/r_mem


force -freeze sim:/processor/i_clk 0 0, 1 {5 ps} -r {10 ps}

force -freeze sim:/processor/i_reset 1 0

run 10 ps

force -freeze sim:/processor/i_reset 0 0
