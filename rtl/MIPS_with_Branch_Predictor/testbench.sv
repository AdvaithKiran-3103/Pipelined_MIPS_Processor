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

        // Clear instruction and data memory
        for (int i = 0; i < (1 << `ADDRWIDTH); i++) begin
            mips.FETCH.IMemory.IM[i]  = '0;
            mips.MEMORY.DMemory.DM[i] = '0;
        end

        // ------------------------------------------------------------
        // Linear Search - Worst Case Successful Search
        //
        // Array size = 25
        // Search key = 99
        // Key is at the last index: DM[24]
        //
        // Expected:
        //   DM[25] = 24
        //
        // Register usage:
        //   R0 = 0
        //   R1 = i / address pointer
        //   R2 = N = 25
        //   R3 = key = 99
        //   R4 = current array value
        //   R6 = result address = 25
        //   R7 = not-found value = 16'hFFFF
        // ------------------------------------------------------------

        // PC 0: if i == N, go to NOT_FOUND at PC 7
        // Target = Inc_PC + Imm = 1 + 6 = 7
        mips.FETCH.IMemory.IM[0] = {BEQ, R1, R2, 6'd6};

        // PC 1: R4 = DM[i]
        mips.FETCH.IMemory.IM[1] = {LOAD, R1, R4, 6'd0};

        // PC 2: if R4 == key, go to FOUND at PC 5
        // Target = Inc_PC + Imm = 3 + 2 = 5
        mips.FETCH.IMemory.IM[2] = {BEQ, R4, R3, 6'd2};

        // PC 3: i = i + 1
        mips.FETCH.IMemory.IM[3] = {ADDI, R1, R1, 6'd1};

        // PC 4: jump back to loop check at PC 0
        mips.FETCH.IMemory.IM[4] = {JUMP, 12'd0};

        // PC 5: FOUND: store index i into DM[25]
        mips.FETCH.IMemory.IM[5] = {STORE, R6, R1, 6'd0};

        // PC 6: jump to DONE
        mips.FETCH.IMemory.IM[6] = {JUMP, 12'd8};

        // PC 7: NOT_FOUND: store 16'hFFFF into DM[25]
        mips.FETCH.IMemory.IM[7] = {STORE, R6, R7, 6'd0};

        // PC 8: DONE
        mips.FETCH.IMemory.IM[8]  = {NOP, 12'd0};
        mips.FETCH.IMemory.IM[9]  = {NOP, 12'd0};
        mips.FETCH.IMemory.IM[10] = {NOP, 12'd0};

        @(negedge clk);
        rst = 0;

        // Register initialization
        mips.DECODE.Reg_File.RF[0] = 16'd0;
        mips.DECODE.Reg_File.RF[1] = 16'd0;       // i = 0
        mips.DECODE.Reg_File.RF[2] = 16'd25;      // N = 25
        mips.DECODE.Reg_File.RF[3] = 16'd99;      // key
        mips.DECODE.Reg_File.RF[4] = 16'd0;       // current value
        mips.DECODE.Reg_File.RF[5] = 16'd0;
        mips.DECODE.Reg_File.RF[6] = 16'd25;      // result address
        mips.DECODE.Reg_File.RF[7] = 16'hFFFF;    // not-found value

        // 25-element array
        // Key 99 is at the last index, DM[24].
        mips.MEMORY.DMemory.DM[0]  = 16'd42;
        mips.MEMORY.DMemory.DM[1]  = 16'd7;
        mips.MEMORY.DMemory.DM[2]  = 16'd18;
        mips.MEMORY.DMemory.DM[3]  = 16'd13;
        mips.MEMORY.DMemory.DM[4]  = 16'd5;
        mips.MEMORY.DMemory.DM[5]  = 16'd76;
        mips.MEMORY.DMemory.DM[6]  = 16'd21;
        mips.MEMORY.DMemory.DM[7]  = 16'd63;
        mips.MEMORY.DMemory.DM[8]  = 16'd31;
        mips.MEMORY.DMemory.DM[9]  = 16'd2;
        mips.MEMORY.DMemory.DM[10] = 16'd88;
        mips.MEMORY.DMemory.DM[11] = 16'd54;
        mips.MEMORY.DMemory.DM[12] = 16'd29;
        mips.MEMORY.DMemory.DM[13] = 16'd67;
        mips.MEMORY.DMemory.DM[14] = 16'd10;
        mips.MEMORY.DMemory.DM[15] = 16'd45;
        mips.MEMORY.DMemory.DM[16] = 16'd3;
        mips.MEMORY.DMemory.DM[17] = 16'd70;
        mips.MEMORY.DMemory.DM[18] = 16'd16;
        mips.MEMORY.DMemory.DM[19] = 16'd81;
        mips.MEMORY.DMemory.DM[20] = 16'd60;
        mips.MEMORY.DMemory.DM[21] = 16'd1;
        mips.MEMORY.DMemory.DM[22] = 16'd35;
        mips.MEMORY.DMemory.DM[23] = 16'd50;
        mips.MEMORY.DMemory.DM[24] = 16'd99;

        // Result location
        // Sentinel means "search not finished yet"
        mips.MEMORY.DMemory.DM[25] = 16'hFFFE;

        // ------------------------------------------------------------
        // End simulation automatically when search completes
        // ------------------------------------------------------------
        fork
            begin
                wait (mips.MEMORY.DMemory.DM[25] != 16'hFFFE);

                // Allow a few extra cycles for pipeline cleanup
                repeat (5) @(posedge clk);

                $display("--------------------------------------------------");
                $display("Linear Search Finished");
                $display("Cycle count = %0d", cycle_count);
                $display("Search key  = %0d", mips.DECODE.Reg_File.RF[3]);
                $display("Result DM[25] = %0d", mips.MEMORY.DMemory.DM[25]);

                if (mips.MEMORY.DMemory.DM[25] == 16'hFFFF)
                    $display("Result: Key not found");
                else
                    $display("Result: Key found at index %0d", mips.MEMORY.DMemory.DM[25]);

                $display("Array contents:");
                for (int i = 0; i < 25; i++) begin
                    $display("DM[%0d] = %0d", i, mips.MEMORY.DMemory.DM[i]);
                end
                $display("--------------------------------------------------");

                $finish;
            end

            begin
                // Safety timeout
                repeat (2000) @(posedge clk);

                $display("--------------------------------------------------");
                $display("ERROR: Search did not finish within timeout");
                $display("Cycle count = %0d", cycle_count);
                $display("DM[25] = %0d", mips.MEMORY.DMemory.DM[25]);
                $display("--------------------------------------------------");

                $finish;
            end
        join_any

        disable fork;
    end

endmodule