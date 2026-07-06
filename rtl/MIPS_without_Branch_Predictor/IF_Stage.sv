`timescale 1ns / 1ps
`include "param.sv"
import MIPS_pkg::*;

module IF_Stage(
    input  logic clk,
    input  logic rst,
    input  logic stall,
    input  logic flush,
    input  logic [`ADDRWIDTH-1:0] Target_PC, 
    output stage1_t stage1
    );
    
    stage1_t stage1_reg, stage1_next;
    logic [`ADDRWIDTH-1:0] PC, PC_plus1;
    logic [`WIDTH-1:0] IMem_instr;
         
    assign stage1   = stage1_reg;
    assign PC_plus1 = PC + 1;
    
    Instruction_Memory IMemory (.addr(PC), 
                                .Instr(IMem_instr)
                               );    
    
    always_comb begin
         stage1_next        = '0;
         stage1_next.Inc_PC = PC_plus1;
         stage1_next.Instr  = IMem_instr;
    end
    
    always_ff @(posedge clk) begin
        if(rst) begin
            PC <= '0;
            stage1_reg <= '0;
        end else if(flush) begin
            PC <= Target_PC;
            stage1_reg <= '0;    
        end else if(!stall) begin
            PC <= PC_plus1;
            stage1_reg <= stage1_next;
        end
    end
        
endmodule
