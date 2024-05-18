# da feh org 70 interrupt
# w interrupt f 900 3shan el infinite loop



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
add wave -position end  sim:/processor/i_interrupt

add wave -position end -color Yellow sim:/processor/FD/o_pc
add wave -position end  -color Yellow sim:/processor/FD/o_instruction
add wave -position end -color Yellow sim:/processor/FD/o_immediate

add wave -position end sim:/processor/D/RF/ram
add wave -position end  sim:/processor/E/o_flags
add wave -position end  sim:/processor/FD/i_flush
add wave -position end  sim:/processor/FD/i_int
add wave -position end  sim:/processor/FD/o_int

add wave -position end  -color Magenta sim:/processor/F/*
add wave -position end -color Magenta /processor/F/pc/main_loop/*
add wave -position end -color Yellow sim:/processor/BP/*
add wave -position end  -color Goldenrod sim:/processor/BC/*
add wave -position end  -color Turquoise sim:/processor/E/*

add wave -position end  sim:/processor/DE/o_pc
add wave -position end  sim:/processor/DE/i_pc
add wave -position end  sim:/processor/DE/i_flush

mem load -i D:/Pipelined-Processor-with-Assembler/Assembler/instructions.mem /processor/F/instruction_memory/r_mem

force -freeze sim:/processor/i_clk 1 0, 0 {5 ps} -r {10 ps}

force -freeze sim:/processor/i_reset 1 0

force -freeze sim:/processor/i_interrupt 0 0

run 10 ps

force -freeze sim:/processor/i_reset 0 0

run 30 ps
force -freeze sim:/processor/i_port 00000000000000000000000000110000 0
run 10 ps
force -freeze sim:/processor/i_port 00000000000000000000000001010000 0
run 10 ps
force -freeze sim:/processor/i_port 00000000000000000000000100000000 0
run 10 ps
force -freeze sim:/processor/i_port 00000000000000000000001100000000 0
###############
run 60 ps
force -freeze sim:/processor/i_port 00000000000000000000000001100000 0
run 60 ps
force -freeze sim:/processor/i_port 00000000000000000000000001100000 0
run 40 ps
force -freeze sim:/processor/i_port 00000000000000000000000001110000 0

# 230 ps
# org 70 interrupt #######
run 100 ps
force -freeze sim:/processor/i_interrupt 1 0
# 330 ps
run 10 ps
force -freeze sim:/processor/i_interrupt 0 0
# 340

run 40 ps
force -freeze sim:/processor/i_port 00000000000000000000000000000101 0
# 380 ps

run 10 ps
force -freeze sim:/processor/i_interrupt 1 0
run 10 ps
force -freeze sim:/processor/i_interrupt 0 0

run 3000 ps
