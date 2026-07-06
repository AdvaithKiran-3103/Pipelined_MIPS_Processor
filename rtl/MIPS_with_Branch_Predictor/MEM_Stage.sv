`timescale 1ns / 1ps
`include "param.sv"
import MIPS_pkg::*;

module MEM_Stage(
    input  logic clk, 
    input  logic rst,
    input  stage3_t stage3,
    output stage4_t stage4
    );
    
    stage4_t stage4_reg, stage4_next;
    logic [`WIDTH-1:0] rd_data;
    
    Data_Memory DMemory (.clk(clk),
                         .MemRead(stage3.MEM_ctrl.MemRead),
                         .MemWrite(stage3.MEM_ctrl.MemWrite),
                         .addr(stage3.ALU_out[`ADDRWIDTH-1:0]),
                         .wr_data(stage3.wr_data),
                         .rd_data(rd_data)
                         );
    
    assign stage4    = stage4_reg;
    
    always_comb begin
        stage4_next = '0;
        stage4_next.WB_ctrl  = stage3.WB_ctrl;
        stage4_next.ALU_out  = stage3.ALU_out;
        stage4_next.WB_dest  = stage3.WB_dest;
        stage4_next.rd_data  = rd_data;
    end
     
    always_ff @(posedge clk) begin
        if(rst) begin
            stage4_reg <= '0;    
        end else begin
            stage4_reg <= stage4_next;
        end
    end
    
endmodule