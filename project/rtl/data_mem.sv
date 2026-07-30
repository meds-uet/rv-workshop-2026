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

     // TODO: Initialize memory to zero using a for loop
    initial begin
        for (int i = 0; i < 1024; i++) begin
            mem[i] = 32'h0000_0000;
        end
    end

    // Read operation
    assign rdata = mem[addr[31:2]];

     // TODO: Implement write operation on positive clock edge
    // Hint: if (we) then write wdata to mem[addr[31:2]]
    always_ff @(posedge clk) begin
        if (reset) begin
            // Reset memory to zero
            for (int i = 0; i < 1024; i++) begin
                mem[i] <= 32'h0000_0000;
            end
        end else if (we) begin
            mem[addr[31:2]] <= wdata;
        end
    end

endmodule
