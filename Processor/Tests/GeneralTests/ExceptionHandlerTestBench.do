# Compile the VHDL file
vcom -2008 General/ExceptionHandler.vhd
vcom -2008 Tests/GeneralTests/ExceptionHandlerTestBench.vhd

# Load the simulation
vsim -gui work.exceptionhandlertestbench

# Run the simulation
run