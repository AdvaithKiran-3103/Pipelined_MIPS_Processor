`timescale 1ns / 1ps
`include "param.sv"
import MIPS_pkg::*;

module WB_Stage(
    input  stage4_t stage4,
    output logic RegWrite,
    output reg_t WB_dest,
    output logic [`WIDTH-1:0] WB_value
    );
   
    assign RegWrite  = stage4.WB_ctrl.RegWrite;
    assign WB_dest   = stage4.WB_dest;
    assign WB_value  = stage4.WB_ctrl.MemtoReg ? stage4.rd_data : stage4.ALU_out;
     
endmodule
    
    