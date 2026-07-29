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
    input logic reset,
    input  logic [4:0]  ra1, ra2, wa,
    input  logic [31:0] wd,
    output logic [31:0] rd1, rd2
);

    logic [31:0] registers [0:31];
    integer i;
    // TODO: Initialize registers to zero using a for loop
    // Initialize registers to zero using a for loop
    //initial begin
        //for (i = 0; i < 32; i = i + 1)
            //registers[i] = 32'h00000000;
    //end
    
    // Read port 1 (example implemented)
    assign rd1 = (ra1 == 5'b00000) ? 32'h0000_0000 : registers[ra1];
    

    // TODO: Implement rd2 read port using same logic as rd1
    //Read port2
   assign rd2 = (ra2 == 5'b00000) ? 32'h0000_0000 :registers[ra2];
    // TODO: Implement write logic (on clk posedge)
    // Only write if we == 1 and wa != x0
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'h00000000;
        end
      else if (we && (wa != 5'b00000)) begin
            registers[wa] <= wd;
        end
    end

endmodule

