`timescale 1ns / 1ps
`include "param.sv"

module Sign_Extender6(
    input  logic [5:0] in,
    output logic [`WIDTH-1:0] out
    );
    
    assign out = {{(`WIDTH-6){in[5]}}, in};
        
endmodule