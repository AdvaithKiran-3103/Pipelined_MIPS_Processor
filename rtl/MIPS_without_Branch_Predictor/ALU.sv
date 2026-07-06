`timescale 1ns / 1ps
`include "param.sv"
import MIPS_pkg::*;

module ALU(
    input  logic [`WIDTH-1:0] a, b,
    input  ALUop_t ALUop,
    output logic [`WIDTH-1:0] out,
    output logic zero
    );
    
    localparam int SHAMT_WIDTH = $clog2(`WIDTH);
    assign zero = !(|out);
    
    always_comb begin
        case(ALUop)
            op_ADD : out = a+b;
            op_SUB : out = a-b;
            op_AND : out = a&b;
            op_SLT : out = ($signed(a) < $signed(b)) ? {{(`WIDTH-1){1'b0}}, 1'b1} : '0;
            op_SRL : out = a >> b[SHAMT_WIDTH-1:0];
            op_NOP : out = 0;
            default: out = 0;   
        endcase
    end
    
endmodule