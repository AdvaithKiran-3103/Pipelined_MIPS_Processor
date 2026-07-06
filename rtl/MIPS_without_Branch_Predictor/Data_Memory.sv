`timescale 1ns/1ps
`include "param.sv"

module Data_Memory(
    input  logic clk,
    input  logic MemRead, MemWrite,  
    input  logic [`ADDRWIDTH-1:0] addr,
    input  logic [`WIDTH-1:0] wr_data, 
    output logic [`WIDTH-1:0] rd_data
    );
    
    localparam DEPTH = 1 << `ADDRWIDTH;
    logic [`WIDTH-1:0] DM [0:DEPTH-1];
    
    assign rd_data = MemRead ? DM[addr] : '0;
    
    always_ff@(posedge clk) begin
        if(MemWrite) begin
            DM[addr] <= wr_data;
        end
    end
endmodule