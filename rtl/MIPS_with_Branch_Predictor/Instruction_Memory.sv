`timescale 1ns / 1ps
`include "param.sv"

module Instruction_Memory(
    input  logic [`ADDRWIDTH-1:0] addr,
    output logic [`WIDTH-1:0] Instr
    );
    
    localparam DEPTH = 1 << `ADDRWIDTH;
    logic [`WIDTH-1:0] IM [DEPTH-1:0];
    
    assign Instr = IM[addr];
    
endmodule