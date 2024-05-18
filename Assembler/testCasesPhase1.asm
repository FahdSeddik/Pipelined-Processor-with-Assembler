# all numbers in hex format
# we always start by reset signal
# this is a commented line
# You should ignore empty lines

# ---------- Don't forget to Reset before you start anything ---------- #

.ORG 0          #this means the the following line would be  at address  0 , and this is the reset address
00
10
0
555

.ORG 10          #this hw interrupt handler
LDM R0,200
Call R0
LDM R0,10

.ORG 200
LDM R1,400
ret

.org 555
LDM R6, 535
RTI