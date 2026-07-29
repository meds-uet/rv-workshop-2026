// Copyright 2026 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Umer Shahid (@umershahidengr)
// =============================================================================
// Single-Cycle RISC-V Processor - Data Memory (Workshop Skeleton Version)
// =============================================================================
module dmem (
    input  logic        clk,
    input  logic        we,
    input  logic        reset,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata
);

    logic [31:0] mem [0:1023]; // 4KB data memory
    integer i;

    initial begin
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 32'h0000_0000;
    end

    // Read operation
    assign rdata = mem[addr[31:2]];

    // Write operation on positive clock edge
    always_ff @(posedge clk) begin
        if (we)
            mem[addr[31:2]] <= wdata;
    end

endmodule
