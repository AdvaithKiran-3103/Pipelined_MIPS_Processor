`timescale 1ns / 1ps
`include "param.sv"
import MIPS_pkg::*;

module testbench;

    logic clk, rst;
    int cycle_count;

    MIPS_Top mips (clk, rst);

    always #1 clk = ~clk;

    always_ff @(posedge clk) begin
        if (rst)
            cycle_count <= 0;
        else
            cycle_count <= cycle_count + 1;
    end

    initial begin
        clk = 0;
        rst = 1;

        for (int i = 0; i < (1 << `ADDRWIDTH); i++) begin
            mips.FETCH.IMemory.IM[i]  = '0;
            mips.MEMORY.DMemory.DM[i] = '0;
        end

        // ------------------------------------------------------------
        // Looped Bubble Sort for 25 elements
        //
        // R0 = 0
        // R1 = outer loop counter
        // R2 = N-1 = 24
        // R3 = inner loop counter / address pointer j
        // R4 = A[j]
        // R5 = A[j+1]
        // R6 = comparison result
        //
        // if A[j+1] < A[j], swap
        // ------------------------------------------------------------

        // PC 0: if outer == N-1, done
        // Target = Inc_PC + 12 = 1 + 12 = 13
        mips.FETCH.IMemory.IM[0]  = {BEQ, R1, R2, 6'd12};

        // PC 1: j = 0
        mips.FETCH.IMemory.IM[1]  = {R_type, R0, R0, R3, f_ADD};

        // PC 2: if j == N-1, go to next outer pass
        // Target = Inc_PC + 8 = 3 + 8 = 11
        mips.FETCH.IMemory.IM[2]  = {BEQ, R3, R2, 6'd8};

        // PC 3: R4 = DM[j]
        mips.FETCH.IMemory.IM[3]  = {LOAD, R3, R4, 6'd0};

        // PC 4: R5 = DM[j+1]
        mips.FETCH.IMemory.IM[4]  = {LOAD, R3, R5, 6'd1};

        // PC 5: R6 = 1 if R5 < R4
        mips.FETCH.IMemory.IM[5]  = {R_type, R5, R4, R6, f_SLT};

        // PC 6: if R6 == 0, skip swap
        // Target = Inc_PC + 2 = 7 + 2 = 9
        mips.FETCH.IMemory.IM[6]  = {BEQ, R6, R0, 6'd2};

        // PC 7: DM[j] = R5
        mips.FETCH.IMemory.IM[7]  = {STORE, R3, R5, 6'd0};

        // PC 8: DM[j+1] = R4
        mips.FETCH.IMemory.IM[8]  = {STORE, R3, R4, 6'd1};

        // PC 9: j = j + 1
        mips.FETCH.IMemory.IM[9]  = {ADDI, R3, R3, 6'd1};

        // PC 10: jump to inner loop check
        mips.FETCH.IMemory.IM[10] = {JUMP, 12'd2};

        // PC 11: outer = outer + 1
        mips.FETCH.IMemory.IM[11] = {ADDI, R1, R1, 6'd1};

        // PC 12: jump to outer loop check
        mips.FETCH.IMemory.IM[12] = {JUMP, 12'd0};

        // PC 13: done
        mips.FETCH.IMemory.IM[13] = {NOP, 12'd0};
        mips.FETCH.IMemory.IM[14] = {NOP, 12'd0};
        mips.FETCH.IMemory.IM[15] = {NOP, 12'd0};

        @(negedge clk);
        rst = 0;

        // Register initialization
        mips.DECODE.Reg_File.RF[0] = 16'd0;
        mips.DECODE.Reg_File.RF[1] = 16'd0;   // outer counter
        mips.DECODE.Reg_File.RF[2] = 16'd24;  // N-1 for 25 elements
        mips.DECODE.Reg_File.RF[3] = 16'd0;   // inner counter / address
        mips.DECODE.Reg_File.RF[4] = 16'd0;
        mips.DECODE.Reg_File.RF[5] = 16'd0;
        mips.DECODE.Reg_File.RF[6] = 16'd0;

        // Unsorted 25-element array
        mips.MEMORY.DMemory.DM[0]  = 16'd99;
        mips.MEMORY.DMemory.DM[1]  = 16'd88;
        mips.MEMORY.DMemory.DM[2]  = 16'd81;
        mips.MEMORY.DMemory.DM[3]  = 16'd76;
        mips.MEMORY.DMemory.DM[4]  = 16'd70;
        mips.MEMORY.DMemory.DM[5]  = 16'd67;
        mips.MEMORY.DMemory.DM[6]  = 16'd63;
        mips.MEMORY.DMemory.DM[7]  = 16'd60;
        mips.MEMORY.DMemory.DM[8]  = 16'd54;
        mips.MEMORY.DMemory.DM[9]  = 16'd50;
        mips.MEMORY.DMemory.DM[10] = 16'd45;
        mips.MEMORY.DMemory.DM[11] = 16'd42;
        mips.MEMORY.DMemory.DM[12] = 16'd35;
        mips.MEMORY.DMemory.DM[13] = 16'd31;
        mips.MEMORY.DMemory.DM[14] = 16'd29;
        mips.MEMORY.DMemory.DM[15] = 16'd21;
        mips.MEMORY.DMemory.DM[16] = 16'd18;
        mips.MEMORY.DMemory.DM[17] = 16'd16;
        mips.MEMORY.DMemory.DM[18] = 16'd13;
        mips.MEMORY.DMemory.DM[19] = 16'd10;
        mips.MEMORY.DMemory.DM[20] = 16'd7;
        mips.MEMORY.DMemory.DM[21] = 16'd5;
        mips.MEMORY.DMemory.DM[22] = 16'd3;
        mips.MEMORY.DMemory.DM[23] = 16'd2;
        mips.MEMORY.DMemory.DM[24] = 16'd1;

        repeat (8000) @(posedge clk);

        $display("Cycle count = %0d", cycle_count);
        $display("Sorted output:");

        for (int i = 0; i < 25; i++) begin
            $display("DM[%0d] = %0d", i, mips.MEMORY.DMemory.DM[i]);
        end

        $finish;
    end

endmodule