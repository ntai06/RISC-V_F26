# RISC-V CPU Project

## Register File
**REG 0 Hardwired to 0 **
- ReadReg1 associated with rs1, [19:15] of Instruction
- ReadReg2 associated with rs2, [24:20] of Instruction
- WriteReg associated with rd, [11:7] of Instruction
- WriteData is the 32 bit data needing to be written @ register at the location of Write Reg
- ReadData1 is the 32 bit data needing to be read from register @ location of ReadReg1
- ReadData2 is the 32 bit data needing to be read from register @ location of ReadReg2
## To Test:
 - compile: & "C:\iverilog\bin\iverilog.exe" -g2012 -o sim.out <module_name>.sv tb_<module_name>.sv
 - run tb: & "C:\iverilog\bin\vvp.exe" sim.out
 - waves: & "C:\iverilog\gtkwave\bin\gtkwave.exe" <vcd_name>.vcd
