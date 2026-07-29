// Copyright 2026 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Umer Shahid (@umershahidengr)
// =============================================================================
// Single-Cycle RISC-V Processor - Complete Implementation
// MEDS Workshop: "Build your own RISC-V Processor in a day"
// =============================================================================
// =============================================================================
// BRANCH UNIT MODULE
// =============================================================================
module branch_unit (
    input  logic [31:0] rd1, rd2,
    input  logic [2:0]  funct3,
    input  logic        branch,
    output logic        pc_src
);
    logic branch_condition;
    always_comb begin

        case (funct3)
            3'b000: branch_condition = (rd1 == rd2);                       // BEQ
            3'b001: branch_condition = (rd1 != rd2);                       // BNE
            3'b100: branch_condition = ($signed(rd1) < $signed(rd2));      // BLT
            3'b101: branch_condition = ($signed(rd1) >= $signed(rd2));     // BGE
            3'b110: branch_condition = ($unsigned(rd1) < $unsigned(rd2));  // BLTU
            3'b111: branch_condition = ($unsigned(rd1) >= $unsigned(rd2)); // BGEU
            default: branch_condition = 1'b0;
        endcase     

    end
    assign pc_src = branch & branch_condition;
endmodule
