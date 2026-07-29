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
    initial begin
        // Example instruction
        mem[0] = 32'h0050_0093; // addi x1, x0, 5
        mem[1] = 32'h0060_0113; // addi x2, x0, 6
        mem[2] = 32'h0020_81b3; // add x3, x1, x2
        for (int i = 3; i < 1024; i++) begin
            mem[i] = 32'h00000013; // NOP instruction  
        end
    end
    // Word-aligned access
    assign instruction = mem[addr[31:2]];
endmodule
