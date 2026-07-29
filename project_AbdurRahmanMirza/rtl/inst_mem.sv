// Copyright 2026 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Umer Shahid (@umershahidengr)
// =============================================================================
// Single-Cycle RISC-V Processor - Instruction Memory (Workshop Skeleton Version)
// =============================================================================

module imem (
    input  logic [31:0] addr,
    output logic [31:0] instruction
);

    logic [31:0] mem [0:1023]; // 4KB instruction memory
    integer i;

    initial begin
        // program instructions
        mem[0] = 32'h0000_0093; // add  x1,  x0, 0
        mem[1] = 32'h0000_0112; // addi x2, x0, 0
        mem[2] = 32'h00A0_0193; // addi x3, x0, 10
        mem[3] = 32'h0031_5463; // bge  x2, x3, 20
        mem[4] = 32'h0020_80B3; // add  x1, x1, x2
        mem[5] = 32'h0110_0113; // addi x2, x2, 1
 
        // fill the remaining memory with NOPs
        for (i = 6; i < 1024; i = i + 1) begin
            mem[i] = 32'h00000013; // NOP (addi x0, x0, 0)
        end
    end

    // word-aligned access
    assign instruction = mem[addr[31:2]];

endmodule
