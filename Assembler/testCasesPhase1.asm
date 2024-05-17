#	All numbers are in hex format
#	We always start by reset signal (in phase one, it just reset all registers)
# 	This is a commented line
#	You should ignore empty lines and commented ones
# 	add as much NOPs (or for example `LDM R7, 0` (a filling instruction)) as you want to avoid hazards (as a software solution, just in 
#          phase one)
# ---------- Don't forget to Reset before you start anything ---------- #
# LDM, NOT, DEC, MOV, OR, CMP

.org 0			# means the code start at address zero, this could be written in 
			# several places in the file and the assembler should handle it in Phase 2
0
2
LDM R0, 1
LDM R1, AAAA
LDM R2, FFFF
DEC R0
MOV R4, R1
NOT R1
MOV R3, R0
DEC R0
CMP R4, R2
OR R5, R1, R4
MOV R6, R0
CMP R2, R4
CMP R5, R0
OR R7, R4, R3
NOT R6
DEC R0
