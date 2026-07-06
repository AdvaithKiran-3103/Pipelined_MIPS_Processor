`timescale 1ns / 1ps
import MIPS_pkg::*;

module Controller(
    input  opcode_t  opcode,
    input  func_t    func,
    output EX_ctrl_t  EX_ctrl,
    output MEM_ctrl_t MEM_ctrl,
    output WB_ctrl_t  WB_ctrl
    );

    always_comb begin
        EX_ctrl  = '0;
        EX_ctrl.ALUop = op_NOP;
        MEM_ctrl = '0;
        WB_ctrl  = '0;

        case(opcode)
            NOP : begin
                // Do nothing. Default control values already make this a NOP.
            end
            
            R_type : begin
                EX_ctrl.RegDst   = 1;
                WB_ctrl.RegWrite = 1;
                case(func)
                    f_ADD :  EX_ctrl.ALUop = op_ADD;
                    f_SUB :  EX_ctrl.ALUop = op_SUB;
                    f_AND :  EX_ctrl.ALUop = op_AND;
                    f_SLT :  EX_ctrl.ALUop = op_SLT;
                    f_SRL :  EX_ctrl.ALUop = op_SRL;
                    default: EX_ctrl.ALUop = op_NOP;
                endcase        
            end
            
            ADDI : begin
                EX_ctrl.ALUop    = op_ADD;
                EX_ctrl.ALUSrc   = 1;
                WB_ctrl.RegWrite = 1;
            end
            
            LOAD : begin
                EX_ctrl.ALUop    = op_ADD;
                EX_ctrl.ALUSrc   = 1;
                MEM_ctrl.MemRead = 1;
                WB_ctrl.MemtoReg = 1;
                WB_ctrl.RegWrite = 1;
            end
            
            STORE : begin
                EX_ctrl.ALUop     = op_ADD;
                EX_ctrl.ALUSrc    = 1;
                MEM_ctrl.MemWrite = 1;
            end

            BEQ : begin
                EX_ctrl.ALUop  = op_SUB;
                EX_ctrl.Branch = 1;  
            end
            
            JUMP : begin
                EX_ctrl.ALUop = op_NOP;
                EX_ctrl.Jump  = 1;     
            end
                
            default : begin
                EX_ctrl  = '0;
                MEM_ctrl = '0;
                WB_ctrl  = '0;
                EX_ctrl.ALUop = op_NOP;
            end
        endcase       
    end
endmodule