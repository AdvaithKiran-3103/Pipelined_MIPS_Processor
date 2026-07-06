`timescale 1ns / 1ps
`include "param.sv"
import MIPS_pkg::*;

module IF_Stage(
    input  logic clk,
    input  logic rst,
    input  logic mispredict,    
    input  logic stall, 
    input  logic [`ADDRWIDTH-1:0] Correct_PC,
    input  BP_update_t BP_update,
    output stage1_t stage1
    );
    
    stage1_t stage1_reg, stage1_next;
    logic [`ADDRWIDTH-1:0] PC;
    logic [`ADDRWIDTH-1:0] PC_plus1;
    logic [`ADDRWIDTH-1:0] pred_PC;
    logic [`WIDTH-1:0]     IMem_instr;
         
    assign stage1   = stage1_reg;
    assign PC_plus1 = PC + 1;
    
    Instruction_Memory IMemory (.addr(PC), 
                                .Instr(IMem_instr)
                               );    
    
    Bimodal_Branch_Predictor BBP (.clk(clk),
                                  .rst(rst),
                                  .PC(PC),
                                  .Inc_PC(PC_plus1),
                                  .update(BP_update),
                                  .pred_PC(pred_PC)
                                  );
    
    always_comb begin
         stage1_next         = '0;
         stage1_next.PC      = PC;
         stage1_next.Inc_PC  = PC_plus1;
         stage1_next.pred_PC = pred_PC;
         stage1_next.Instr   = IMem_instr;
    end
    
    always_ff @(posedge clk) begin
        if(rst) begin
            PC <= '0;
            stage1_reg <= '0;
        end else if(mispredict) begin
            PC <= Correct_PC;
            stage1_reg <= '0;    
        end else if(!stall) begin
            PC <= pred_PC;
            stage1_reg <= stage1_next;
        end
    end
        
endmodule
