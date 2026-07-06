`timescale 1ns / 1ps
`include "param.sv"
import MIPS_pkg::*;

module EX_Stage(
    input  logic clk, 
    input  logic rst,
    input  stage2_t stage2,
    input  logic stage4_RegWrite,
    input  reg_t stage4_WB_dest,
    input  logic [`WIDTH-1:0] WB_value,
    output logic mispredict,
    output logic [`ADDRWIDTH-1:0] Correct_PC,
    output BP_update_t BP_update,   
    output stage3_t stage3
    );
    
    stage3_t stage3_reg, stage3_next;
    logic [`WIDTH-1:0] ALU_in1, ALU_in2;
    logic [`WIDTH-1:0] ALU_out;
    logic ALU_zero;
    logic [1:0] forwardA, forwardB;
    logic [`WIDTH-1:0] ALU_in1_fwd, ALU_in2_fwd;  
    
    logic [`ADDRWIDTH-1:0] Branch_PC; 
    logic branch_taken, branch_or_jump, jump;
    
    assign stage3  = stage3_reg;
    assign jump    = stage2.EX_ctrl.Jump;                                                        
    assign ALU_in1 = ALU_in1_fwd;
    assign ALU_in2 = stage2.EX_ctrl.ALUSrc ? stage2.Imm_ext : ALU_in2_fwd;
          
    ALU Alu1 (.a(ALU_in1),
              .b(ALU_in2),
              .ALUop(stage2.EX_ctrl.ALUop),
              .out(ALU_out),
              .zero(ALU_zero)
              );
    
    Forwarding_Unit FU (.stage2_Ra(stage2.Ra),
                        .stage2_Rb(stage2.Rb),
                        .stage3_MemRead(stage3_reg.MEM_ctrl.MemRead),
                        .stage3_RegWrite(stage3_reg.WB_ctrl.RegWrite),
                        .stage3_WB_dest(stage3_reg.WB_dest),
                        .stage4_WB_dest(stage4_WB_dest),
                        .stage4_RegWrite(stage4_RegWrite),
                        .forwardA(forwardA),
                        .forwardB(forwardB)
                        );

    always_comb begin
        branch_or_jump = stage2.EX_ctrl.Branch || stage2.EX_ctrl.Jump;
        branch_taken   = stage2.EX_ctrl.Branch && ALU_zero;
        Branch_PC      = stage2.Inc_PC + stage2.Imm_ext;
        Correct_PC     = stage2.EX_ctrl.Jump ? stage2.Jump_PC : 
                         branch_taken ? Branch_PC:
                         stage2.Inc_PC; 
        mispredict     = branch_or_jump && (stage2.pred_PC != Correct_PC);
        
        BP_update = '0;     
        BP_update.en            =  branch_or_jump;
        BP_update.jump          =  stage2.EX_ctrl.Jump;
        BP_update.PC            =  stage2.PC;
        BP_update.target        =  stage2.EX_ctrl.Jump ? stage2.Jump_PC  :Branch_PC;
        BP_update.branch_taken  =  branch_taken;     
    end
   
    always_comb begin
        case(forwardA) 
            FWD_NONE   : ALU_in1_fwd = stage2.Ra_val;
            FWD_STAGE3 : ALU_in1_fwd = stage3_reg.ALU_out;
            FWD_STAGE4 : ALU_in1_fwd = WB_value;
            default    : ALU_in1_fwd = stage2.Ra_val;  
        endcase
        
        case(forwardB)
            FWD_NONE   : ALU_in2_fwd = stage2.Rb_val;
            FWD_STAGE3 : ALU_in2_fwd = stage3_reg.ALU_out;
            FWD_STAGE4 : ALU_in2_fwd = WB_value;
            default    : ALU_in2_fwd = stage2.Rb_val;       
        endcase
    end   
    
    always_comb begin
        stage3_next = '0;
        stage3_next.MEM_ctrl = stage2.MEM_ctrl;
        stage3_next.WB_ctrl  = stage2.WB_ctrl;
        stage3_next.ALU_out  = ALU_out;
        stage3_next.wr_data  = ALU_in2_fwd;
        stage3_next.WB_dest  = stage2.EX_ctrl.RegDst ? stage2.Rc : stage2.Rb;
    end
    
    always_ff @(posedge clk) begin
        if(rst) begin
            stage3_reg <= '0;
        end else begin
            stage3_reg <= stage3_next;
        end 
    end
    
endmodule
