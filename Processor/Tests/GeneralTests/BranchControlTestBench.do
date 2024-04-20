# Compile the VHDL file
vcom -2008 General/BranchControl.vhd
vcom -2008 Tests/GeneralTests/BranchControlTestBench.vhd

# Load the simulation
vsim -gui work.branchcontroltestbench

# add waves
add wave -position end  sim:/branchcontroltestbench/w_i_branch_control
add wave -position end  sim:/branchcontroltestbench/w_i_branch_adress
add wave -position end  sim:/branchcontroltestbench/w_i_z_flag
add wave -position end  sim:/branchcontroltestbench/w_o_branch_control
add wave -position end  sim:/branchcontroltestbench/w_o_branch_adress

# Run the simulation
run