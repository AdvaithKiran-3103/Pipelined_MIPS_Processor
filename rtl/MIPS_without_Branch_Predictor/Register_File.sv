`timescale 1ns / 1ps
`include "param.sv"
import MIPS_pkg::*;

module Register_File(
    input  logic clk, rst,
    input  logic RegWrite, 
    input  reg_t WB_dest,
    input  logic [`WIDTH-1:0] WB_value,
    input  reg_t Ra, Rb,
    output logic [`WIDTH-1:0] Ra_val, Rb_val
    );
    
    logic [`WIDTH-1:0] RF [0:`NUM_OF_REGISTERS-1];
    
    assign Ra_val = (RegWrite && (WB_dest == Ra)) ? WB_value : RF[Ra];
    assign Rb_val = (RegWrite && (WB_dest == Rb)) ? WB_value : RF[Rb];

    always_ff@(posedge clk) begin
        if(rst) 
            RF <= '{default:'0};
        else if(RegWrite)
            RF[WB_dest] <= WB_value;
    end
    
endmodule
