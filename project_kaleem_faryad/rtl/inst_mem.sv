// Copyright 2026 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Umer Shahid (@umershahidengr)
// =============================================================================
// Single-Cycle RISC-V Processor - Instruction Memory
// =============================================================================

module imem (
    input  logic [31:0] addr,
    output logic [31:0] instruction
);

    logic [31:0] mem [0:1023];

    integer i;

    initial begin
        // Sample program
        mem[0] = 32'h00500093; // addi x1, x0, 5
        mem[1] = 32'h00600113; // addi x2, x0, 6
        mem[2] = 32'h002081B3; // add x3, x1, x2
        mem[3] = 32'h00000013; // nop

        // Fill remaining memory with NOPs
        for (i = 4; i < 1024; i = i + 1)
            mem[i] = 32'h00000013;
    end

    // Word-aligned instruction fetch
    assign instruction = mem[addr[31:2]];

endmodule