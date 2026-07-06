`timescale 1ns / 1ps
`include "param.sv"
import MIPS_pkg::*;

module Bimodal_Branch_Predictor(
    input logic clk, 
    input logic rst, 
    input logic [`ADDRWIDTH-1:0] PC, Inc_PC,
    input BP_update_t update, 
    output logic [`ADDRWIDTH-1:0] pred_PC
    );
    
    localparam int BP_DEPTH = 1 << `BP_INDEX_WIDTH;
    
    typedef struct packed {
        logic [`BP_TAG_WIDTH-1:0] tag;
        logic [`ADDRWIDTH-1:0] target;
        logic [1:0] state;
        logic valid;
    } BP_t;
    
    BP_t BP [0:BP_DEPTH-1];
    
    logic [`BP_INDEX_WIDTH-1:0] index, update_index;
    logic [`BP_TAG_WIDTH-1:0] tag, update_tag;
    logic [1:0] state_next;
    logic predict_taken;
    logic hit;    
    
    always_comb begin    
        index         =  PC[`BP_INDEX_WIDTH-1:0];
        tag           =  PC[`ADDRWIDTH-1:`BP_INDEX_WIDTH];
        update_index  =  update.PC[`BP_INDEX_WIDTH-1:0];
        update_tag    =  update.PC[`ADDRWIDTH-1:`BP_INDEX_WIDTH];
        hit           =  BP[index].valid && 
                        (BP[index].tag == tag);
        predict_taken =  hit && 
                        (BP[index].state[1]);
        pred_PC       =  predict_taken ? 
                         BP[index].target : Inc_PC;
        
        state_next = BP[update_index].state;
        case((BP[update_index].state))
            2'b00   : state_next = update.branch_taken ? 2'b01 : 2'b00;
            2'b01   : state_next = update.branch_taken ? 2'b11 : 2'b00;
            2'b10   : state_next = update.branch_taken ? 2'b11 : 2'b00;
            2'b11   : state_next = update.branch_taken ? 2'b11 : 2'b10;
            default : state_next = 2'b00;
        endcase   
    end
  
    always_ff@ (posedge clk) begin
        if(rst) begin
            BP <= '{default:'0};
        end else if(update.en) begin
            if(!BP[update_index].valid || (BP[update_index].tag != update_tag)) begin
                BP[update_index].valid   <= 1'b1;
                BP[update_index].tag     <= update_tag;
                BP[update_index].target  <= update.target;
                BP[update_index].state   <= update.jump ? 2'b11:
                                           (update.branch_taken ? 2'b01 : 2'b00);                
            end else begin
                BP[update_index].state   <= update.jump ? 2'b11: state_next;
            end
        end
    end     
     
endmodule
