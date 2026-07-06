`timescale 1ns / 1ps
`include "param.sv"
import MIPS_pkg::*;

module MIPS_Top(
    input logic clk, 
    input logic rst
    );
    
    logic stall;
    logic flush; 
    logic [`ADDRWIDTH-1:0] Target_PC;
    logic RegWrite;
    reg_t WB_dest;
    logic [`WIDTH-1:0] WB_value;
    stage1_t stage1;
    stage2_t stage2;
    stage3_t stage3;
    stage4_t stage4;
    
    IF_Stage FETCH (.clk(clk),
                    .rst(rst),
                    .stall(stall),
                    .flush(flush),
                    .Target_PC(Target_PC),
                    .stage1(stage1)
                    );
                    
    ID_Stage DECODE (.clk(clk),
                     .rst(rst),
                     .stall(stall),
                     .flush(flush),
                     .RegWrite(RegWrite),
                     .WB_dest(WB_dest),
                     .WB_value(WB_value),
                     .stage1(stage1),
                     .stage2(stage2)
                     );
                     
    Hazard_Detection_Unit HDU (.stage1_Instr(stage1.Instr),
                               .stage2_Rb(stage2.Rb),
                               .stage2_MemRead(stage2.MEM_ctrl.MemRead),        
                               .stall(stall)
                               );
                                                    
    EX_Stage EXECUTE (.clk(clk), 
                      .rst(rst),
                      .stage2(stage2),
                      .stage4_WB_dest(stage4.WB_dest),
                      .stage4_RegWrite(stage4.WB_ctrl.RegWrite),
                      .WB_value(WB_value),
                      .Target_PC(Target_PC),
                      .flush(flush),
                      .stage3(stage3) 
                      );
    
    MEM_Stage MEMORY (.clk(clk), 
                      .rst(rst),
                      .stage3(stage3),
                      .stage4(stage4)
                      );
                     
    WB_Stage WRITEBACK (.stage4(stage4),                  
                        .RegWrite(RegWrite),
                        .WB_dest(WB_dest),
                        .WB_value(WB_value)
                        );
                     
endmodule
