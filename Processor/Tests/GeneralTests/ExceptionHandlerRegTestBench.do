# Compile the VHDL file
vcom -2008 General/ExceptionHandlerReg.vhd
vcom -2008 Tests/generalTests/ExceptionHandlerRegTestBench.vhd

# Load the simulation
vsim -gui work.ExceptionHandlerRegTestBench

# waves
add wave -position end  sim:/exceptionhandlerregtestbench/i_we
add wave -position end  sim:/exceptionhandlerregtestbench/i_EPC
add wave -position end  sim:/exceptionhandlerregtestbench/i_memory_violation
add wave -position end  sim:/exceptionhandlerregtestbench/i_overflow
add wave -position end  sim:/exceptionhandlerregtestbench/o_EPC
add wave -position end  sim:/exceptionhandlerregtestbench/o_exception_memory_violation
add wave -position end  sim:/exceptionhandlerregtestbench/o_exception_overflow

# Run the simulation
run