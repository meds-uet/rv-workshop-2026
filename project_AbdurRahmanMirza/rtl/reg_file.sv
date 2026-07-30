// Copyright 2026 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Umer Shahid (@umershahidengr)
// =============================================================================
// Single-Cycle RISC-V Processor - Register File (Workshop Skeleton Version)
// =============================================================================

module register_file (
    input  logic        clk,
    input  logic        we,
    input  logic        reset,
    input  logic [4:0]  ra1, ra2, wa,
    input  logic [31:0] wd,
    output logic [31:0] rd1, rd2
);

    logic [31:0] registers [0:31];           // 32 general-purpose registers
    integer i;

    // Read port 1 (x0 is always zero)
    assign rd1 = (ra1 == 5'b00000) ? 32'h0000_0000 : registers[ra1];

    // Read port 2 (x0 is always zero)
    assign rd2 = (ra2 == 5'b00000) ? 32'h0000_0000 : registers[ra2];

    always_ff @(posedge clk) begin          // register write and reset
        if (reset) begin
            for (i = 0; i < 32; i++)
                registers[i] <= 32'b0;      // clear all registers
        end
        else if (we && wa != 5'b00000) begin
            registers[wa] <= wd;            // write data into destination register
        end
    end

endmodule
