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

        mem[0] = 32'h00500093; // addi x1, x0, 5
        mem[1] = 32'h00A00113; // addi x2, x0, 10
        mem[2] = 32'h00208233; // add x4, x1, x2
        mem[3] = 32'h401102B3; // sub x5, x2, x1
        mem[4] = 32'h0020E4B3; // or x9, x1, x2
        mem[5] = 32'h0020F533; // and x10, x1, x2
        
        // Fill remaining memory with NOPs
        for(int i=6; i<1024; i++) begin
            mem[i] = 32'h00000013;
        end
    end
    // Word-aligned access
    assign instruction = mem[addr[31:2]];
endmodule
