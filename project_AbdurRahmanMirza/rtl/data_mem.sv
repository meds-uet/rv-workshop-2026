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

    logic [31:0] mem [0:1023];              // 4 KB data memory

    assign rdata = mem[addr[31:2]];         // asynchronous read

    always_ff @(posedge clk) begin          // synchronous write and reset
        if (reset) begin
            for (int i = 0; i < 1024; i++)
                mem[i] <= 32'b0;            // clear all memory locations
        end
        else if (we)
            mem[addr[31:2]] <= wdata;       // write data to memory
    end

endmodule
