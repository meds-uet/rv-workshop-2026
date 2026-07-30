// Copyright 2026 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Umer Shahid (@umershahidengr)
// =============================================================================
// RISCV Processor Full-System Testbench
// =============================================================================

module tb_riscv_processor;

    logic clk, reset;
    wire [31:0] pc_out, instruction_out;

    int passed = 0, failed = 0, total = 0;

    riscv_processor dut (
        .clk(clk),
        .reset(reset),
        .pc_out(pc_out),
        .instruction_out(instruction_out)
    );

    always #5 clk = ~clk;

    task check_instr(input [31:0] expected, input string msg);
        total++;
        if (instruction_out === expected) begin
            passed++;
            $display("[PASS] %s | PC = %h, Instr = %h", msg, pc_out, instruction_out);
        end else begin
            failed++;
            $display("[FAIL] %s | PC = %h, Instr = %h (expected %h)", msg, pc_out, instruction_out, expected);
        end
    endtask

    initial begin
        $display("=== RISCV Processor Test Start ===");
        clk = 0;
        reset = 1;
        #20;
        reset = 0;

        repeat (30) begin
            @(posedge clk);
            #1;
            case (pc_out)
                32'h00: check_instr(32'h00500093, "ADDI x1,x0,5");
                32'h04: check_instr(32'h00A00113, "ADDI x2,x0,10");
                32'h08: check_instr(32'h002081B3, "ADD x3,x1,x2");
                32'h0C: check_instr(32'h40110233, "SUB x4,x2,x1");
                32'h10: check_instr(32'h0020F2B3, "AND x5,x1,x2");
                32'h14: check_instr(32'h0020E333, "OR x6,x1,x2");
                32'h18: check_instr(32'h0020C3B3, "XOR x7,x1,x2");
                32'h1C: check_instr(32'h00209413, "SLLI x8,x1,2");
                32'h20: check_instr(32'h00302023, "SW x3,0(x0)");
                32'h24: check_instr(32'h00002483, "LW x9,0(x0)");
                32'h28: check_instr(32'h00300513, "ADDI x10,x0,3");
                32'h2C: check_instr(32'h00000593, "ADDI x11,x0,0");
                32'h30: check_instr(32'h00A585B3, "Loop: ADD x11,x11,x10");
                32'h34: check_instr(32'hFFF50513, "ADDI x10,x10,-1");
                32'h38: check_instr(32'hFE051CE3, "BNE x10,x0,Loop");
                32'h3C: check_instr(32'h008000EF, "JAL x1,Target");
                32'h44: check_instr(32'h02A00693, "Target: ADDI x13,x0,42");
                32'h48: check_instr(32'h12345737, "LUI x14,0x12345");
                32'h4C: check_instr(32'h67870713, "ADDI x14,x14,0x678");
                32'h50: check_instr(32'h00000463, "BEQ x0,x0,End");
                32'h58: check_instr(32'h00700813, "End: ADDI x16,x0,7");
                default: check_instr(32'h00000013, "NOP/other");
            endcase
        end

        $display("=== RISCV Processor Summary ===");
        $display("Total: %0d | Passed: %0d | Failed: %0d", total, passed, failed);
        if (failed == 0) $display("✅ All tests passed.");
        else $display("❌ Some tests failed.");
        $finish;
    end

endmodule
