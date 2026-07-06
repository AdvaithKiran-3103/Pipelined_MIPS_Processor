`include "param.sv"

package MIPS_pkg;
    // Opcodes
    typedef enum logic [3:0] {
        NOP    = 4'd0,
        R_type = 4'd1,
        ADDI   = 4'd2,
        LOAD   = 4'd3,
        STORE  = 4'd4,
        BEQ    = 4'd5,
        JUMP   = 4'd6
    } opcode_t;
         
    // Func fields in R-type Instr.
    typedef enum logic [2:0] {
        f_ADD = 3'd1,
        f_SUB = 3'd2,
        f_AND = 3'd3,
        f_SLT = 3'd4,
        f_SRL = 3'd5
    } func_t;
        
    //ALU Operations
    typedef enum logic [2:0] {
        op_NOP  = 3'd0,
        op_ADD  = 3'd1,
        op_SUB  = 3'd2,
        op_AND  = 3'd3,
        op_SLT  = 3'd4,
        op_SRL  = 3'd5        
    } ALUop_t;
    
    // Register File Index Naming
    typedef enum logic [`RF_INDEX_WIDTH-1:0] {
        R0 = 3'd0,
        R1 = 3'd1,
        R2 = 3'd2,
        R3 = 3'd3,
        R4 = 3'd4,
        R5 = 3'd5,
        R6 = 3'd6,
        R7 = 3'd7
    } reg_t;
    
    //Controller Outputs    
    typedef struct packed {
        ALUop_t ALUop;
        logic ALUSrc;
        logic RegDst;
        logic Branch;
        logic Jump;
    } EX_ctrl_t;
     
    typedef struct packed {
        logic MemRead;
        logic MemWrite;
    } MEM_ctrl_t;

    typedef struct packed {
        logic MemtoReg;
        logic RegWrite;
    } WB_ctrl_t;     
     
    // Forwarding Unit Outputs
    typedef enum logic [1:0] {
            FWD_NONE   = 2'd0,
            FWD_STAGE3 = 2'd1,
            FWD_STAGE4 = 2'd2    
    } forward_sel_t;
        
    //Pipeline Registers
    typedef struct packed {
        logic [`ADDRWIDTH-1:0] Inc_PC;
        logic [`WIDTH-1:0] Instr;
    } stage1_t;
    
    typedef struct packed {
        EX_ctrl_t  EX_ctrl;
        MEM_ctrl_t MEM_ctrl;
        WB_ctrl_t  WB_ctrl;
        logic [`ADDRWIDTH-1:0] Inc_PC;
        logic [`ADDRWIDTH-1:0] Jump_PC;
        logic [`WIDTH-1:0] Ra_val, Rb_val;
        logic [`WIDTH-1:0] Imm_ext;
        reg_t Ra, Rb, Rc;
    } stage2_t;
    
    typedef struct packed {
        MEM_ctrl_t MEM_ctrl;
        WB_ctrl_t  WB_ctrl;        
        logic [`WIDTH-1:0] ALU_out;
        logic [`WIDTH-1:0] wr_data;
        reg_t WB_dest;
    } stage3_t;
        
    typedef struct packed {
        WB_ctrl_t WB_ctrl;
        logic [`WIDTH-1:0] rd_data;
        logic [`WIDTH-1:0] ALU_out;
        reg_t WB_dest;
    } stage4_t;
               
endpackage