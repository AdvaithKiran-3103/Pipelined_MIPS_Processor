`timescale 1ns / 1ps
`include "param.sv"
import MIPS_pkg::*;

module Hazard_Detection_Unit(
    input  logic [`WIDTH-1:0] stage1_Instr,
    input  reg_t stage2_Rb,
    input  logic stage2_MemRead,
    output logic stall
    );

    opcode_t stage1_opcode;
    reg_t    stage1_Ra;
    reg_t    stage1_Rb;

    logic stage1_reads_Ra;
    logic stage1_reads_Rb;

    assign stage1_opcode = opcode_t'(stage1_Instr[15:12]);
    assign stage1_Ra     = reg_t'(stage1_Instr[11:9]);
    assign stage1_Rb     = reg_t'(stage1_Instr[8:6]);

    assign stage1_reads_Ra = (stage1_opcode == R_type)|| (stage1_opcode == ADDI)|| (stage1_opcode == LOAD)||
                             (stage1_opcode == STORE) || (stage1_opcode == BEQ);

    assign stage1_reads_Rb = (stage1_opcode == R_type)||(stage1_opcode == STORE)||
                             (stage1_opcode == BEQ);

    assign stall = stage2_MemRead &&
                   ( (stage1_reads_Ra && (stage2_Rb == stage1_Ra)) ||
                     (stage1_reads_Rb && (stage2_Rb == stage1_Rb))
                   );

endmodule
