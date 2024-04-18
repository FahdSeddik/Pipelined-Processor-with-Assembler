# compilation
vcom -2008 Fetch/InstructionMemory.vhd
vcom -2008 Tests/FetchTests/InstructionMemory_TestBench.vhd

# simulation
vsim -gui work.instructionmemory_testbench

# add waves
add wave -position end sim:/instructionmemory_testbench/i_address
add wave -position end sim:/instructionmemory_testbench/o_instruction

#load data
mem load -i D:/Pipelined-Processor-with-Assembler/Processor/Tests/FetchTests/InstructionMemory.mem /instructionmemory_testbench/uut/r_mem

# run
run
