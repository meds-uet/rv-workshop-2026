// Copyright 2026 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Umer Shahid (@umershahidengr)
// =============================================================================
// Single-Cycle RISC-V Processor - Complete Implementation
// MEDS Workshop: "Build your own RISC-V Processor in a day"
// =============================================================================
module alu (
    input  logic [31:0] a, b,
    input  logic [3:0]  alu_control,
    output logic [31:0] result,
    output logic        zero
);
    always_comb begin
        // alu_control encoding:
        case (alu_control)
            4'b0000: result = a + b; // 0000: ADD
            4'b0001: result = a - b; // 0001: SUB
            4'b0010: result = a & b; // 0010: AND
            4'b0011: result = a | b; // 0011: OR
            4'b0100: result = a ^ b; // 0100: XOR
            4'b0101: result = a << b[4:0]; // 0101: SLL (Shift Left Logical)
            4'b0110: result = a >> b[4:0]; // 0110: SRL (Shift Right Logical)
            4'b0111: result = $signed(a) >>> b[4:0]; // 0111: SRA (Shift Right Arithmetic)
            4'b1000: result = ($signed(a) < $signed(b)) ? 32'h0000_0001 : 32'h0000_0000; // 1000: SLT (signed)
            4'b1001: result = ($unsigned(a) < $unsigned(b)) ? 32'h0000_0001 : 32'h0000_0000; // 1001: SLTU (unsigned)
            default: result = 32'h0000_0000;
        endcase
    end

    assign zero = (result == 32'h0000_0000);

endmodule
