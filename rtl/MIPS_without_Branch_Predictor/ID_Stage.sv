`timescale 1ns / 1ps
`include "param.sv"
import MIPS_pkg::*;

 module ID_Stage(
    input  logic clk, 
    input  logic rst,
    input  logic stall, 
    input  logic flush, 
    input  logic RegWrite,
    input  reg_t WB_dest,
    input  logic [`WIDTH-1:0] WB_value, 
    input  stage1_t stage1,
    output stage2_t stage2
    ); 

    stage2_t   stage2_reg, stage2_next;
    opcode_t   opcode;
    func_t     func;
    EX_ctrl_t  EX_ctrl_next;
    MEM_ctrl_t MEM_ctrl_next;
    WB_ctrl_t  WB_ctrl_next;  
    reg_t      Ra, Rb, Rc;
    logic [`WIDTH-1:0] Ra_val, Rb_val;
    logic [5:0] Imm;
    logic [`WIDTH-1:0] Imm_ext;
          
    assign stage2 = stage2_reg;
    assign opcode = opcode_t'(stage1.Instr[15:12]);
    assign func   = func_t'(stage1.Instr[2:0]); 
    assign Ra     = reg_t'(stage1.Instr[11:9]);
    assign Rb     = reg_t'(stage1.Instr[8:6]);
    assign Rc     = reg_t'(stage1.Instr[5:3]);
    assign Imm    = stage1.Instr[5:0];
    
    Controller Con (.opcode(opcode),
                    .func(func),
                    .EX_ctrl(EX_ctrl_next),
                    .MEM_ctrl(MEM_ctrl_next),
                    .WB_ctrl(WB_ctrl_next)
                    );
                        
    Register_File Reg_File (.clk(clk),
                            .rst(rst),
                            .RegWrite(RegWrite),
                            .WB_dest(WB_dest),
                            .WB_value(WB_value),
                            .Ra(Ra), 
                            .Rb(Rb), 
                            .Ra_val(Ra_val), 
                            .Rb_val(Rb_val)
                            );
                            
    
    Sign_Extender6 SE6 (.in(Imm),
                        .out(Imm_ext)
                       );
                          
    always_comb begin
        stage2_next = '0;
        stage2_next.EX_ctrl  = EX_ctrl_next;
        stage2_next.MEM_ctrl = MEM_ctrl_next;
        stage2_next.WB_ctrl  = WB_ctrl_next;
        stage2_next.Inc_PC   = stage1.Inc_PC;
        stage2_next.Jump_PC  = {stage1.Inc_PC[`ADDRWIDTH-1-:4], stage1.Instr[11:0]};
        stage2_next.Ra_val   = Ra_val;
        stage2_next.Rb_val   = Rb_val;
        stage2_next.Imm_ext  = Imm_ext;
        stage2_next.Ra       = Ra;
        stage2_next.Rb       = Rb;
        stage2_next.Rc       = Rc;
    end
    
    always_ff@(posedge clk) begin
        if(rst) begin
            stage2_reg <= '0;
        end else if(flush || stall) begin
            stage2_reg <= '0;    
        end else begin
            stage2_reg <= stage2_next;        
        end
    end
       
endmodule
