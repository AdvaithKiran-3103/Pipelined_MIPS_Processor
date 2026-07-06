`timescale 1ns / 1ps
`include "param.sv"
import MIPS_pkg::*;

module Forwarding_Unit( 
    input  reg_t stage2_Ra, stage2_Rb,
    input  reg_t stage3_WB_dest, stage4_WB_dest,
    input  logic stage3_MemRead, 
    input  logic stage3_RegWrite, stage4_RegWrite,
    output forward_sel_t forwardA, forwardB 
    );
    
    logic stage3_writes_Ra;
    logic stage3_writes_Rb;
    logic stage4_writes_Ra;
    logic stage4_writes_Rb;
    
    assign stage3_writes_Ra = (!stage3_MemRead) && (stage3_RegWrite) && (stage3_WB_dest == stage2_Ra);
    assign stage3_writes_Rb = (!stage3_MemRead) && (stage3_RegWrite) && (stage3_WB_dest == stage2_Rb);
    assign stage4_writes_Ra = (stage4_RegWrite) && (stage4_WB_dest == stage2_Ra);
    assign stage4_writes_Rb = (stage4_RegWrite) && (stage4_WB_dest == stage2_Rb);
                             
    always_comb begin
        forwardA = FWD_NONE;
        forwardB = FWD_NONE;
        
        if (stage3_writes_Ra)
            forwardA = FWD_STAGE3;
        else if (stage4_writes_Ra)
            forwardA = FWD_STAGE4;

        if (stage3_writes_Rb)
            forwardB = FWD_STAGE3;
        else if (stage4_writes_Rb)
            forwardB = FWD_STAGE4;                      
    end
        
endmodule
