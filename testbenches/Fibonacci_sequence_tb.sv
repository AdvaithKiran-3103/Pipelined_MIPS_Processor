`timescale 1ns / 1ps
`include "param.sv"
import MIPS_pkg::*;

module testbench;
    logic clk, rst;
    int cycle_count;
    
    MIPS_Top mips (clk, rst);
    
    always #1 clk = ~clk;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            cycle_count <= 0;
        end else begin
            cycle_count <= cycle_count + 1;
        end
    end    
    
    initial begin
        clk = 0; rst = 1;
         
        for (int i = 0; i < (1 << `ADDRWIDTH); i++) begin
            mips.FETCH.IMemory.IM[i]  = '0;
            mips.MEMORY.DMemory.DM[i] = '0;
        end
                
        // Instruction Memory
        // PC 0: if i == count, exit to PC 8
        // Target = Inc_PC + Imm = 1 + 7 = 8
        mips.FETCH.IMemory.IM[0] = {BEQ, R3, R4, 6'd7};

        // PC 1: DM[addr] = a
        mips.FETCH.IMemory.IM[1] = {STORE, R6, R1, 6'd0};

        // PC 2: temp = a + b
        mips.FETCH.IMemory.IM[2] = {R_type, R1, R2, R5, f_ADD};

        // PC 3: a = b
        mips.FETCH.IMemory.IM[3] = {R_type, R2, R0, R1, f_ADD};

        // PC 4: b = temp
        mips.FETCH.IMemory.IM[4] = {R_type, R5, R0, R2, f_ADD};

        // PC 5: addr = addr + 1
        mips.FETCH.IMemory.IM[5] = {ADDI, R6, R6, 6'd1};

        // PC 6: i = i + 1
        mips.FETCH.IMemory.IM[6] = {ADDI, R3, R3, 6'd1};

        // PC 7: jump back to loop
        mips.FETCH.IMemory.IM[7] = {JUMP, 12'd0};

        // PC 8: exit
        mips.FETCH.IMemory.IM[8] = {NOP, 12'd0};
        mips.FETCH.IMemory.IM[9] = {NOP, 12'd0};
        mips.FETCH.IMemory.IM[10] = {NOP, 12'd0};
        
        @(negedge clk); rst = 0;        
        
        

        // Register initialization
        mips.DECODE.Reg_File.RF[0] = 16'd0;
        mips.DECODE.Reg_File.RF[1] = 16'd0;   // a = F0
        mips.DECODE.Reg_File.RF[2] = 16'd1;   // b = F1
        mips.DECODE.Reg_File.RF[3] = 16'd0;   // i = 0
        mips.DECODE.Reg_File.RF[4] = 16'd25;   // count = 25, store F0 to F24
        mips.DECODE.Reg_File.RF[5] = 16'd0;   // temp
        mips.DECODE.Reg_File.RF[6] = 16'd0;   // addr = 0        
        #1000 $finish;
    end
    
endmodule
