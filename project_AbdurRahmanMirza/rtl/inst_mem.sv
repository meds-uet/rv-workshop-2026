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
    integer i;

    initial begin
        mem[0]  = 32'h00500093; // addi x1,  x0, 5
        mem[1]  = 32'h00A00113; // addi x2,  x0, 10
        mem[2]  = 32'h002081B3; // add  x3,  x1, x2
        mem[3]  = 32'h40110233; // sub  x4,  x2, x1
        mem[4]  = 32'h0020F2B3; // and  x5,  x1, x2
        mem[5]  = 32'h0020E333; // or   x6,  x1, x2
        mem[6]  = 32'h0020C3B3; // xor  x7,  x1, x2
        mem[7]  = 32'h00209413; // slli x8,  x1, 2
        mem[8]  = 32'h00302023; // sw   x3,  0(x0)
        mem[9]  = 32'h00002483; // lw   x9,  0(x0)
        mem[10] = 32'h00300513; // addi x10, x0, 3
        mem[11] = 32'h00000593; // addi x11, x0, 0
        mem[12] = 32'h00A585B3; // Loop: add  x11, x11, x10
        mem[13] = 32'hFFF50513; //       addi x10, x10, -1
        mem[14] = 32'hFE051CE3; //       bne  x10, x0, Loop
        mem[15] = 32'h008000EF; // jal  x1, Target
        mem[16] = 32'h06300613; // addi x12, x0, 99   (skipped)
        mem[17] = 32'h02A00693; // Target: addi x13, x0, 42
        mem[18] = 32'h12345737; // lui  x14, 0x12345
        mem[19] = 32'h67870713; // addi x14, x14, 0x678
        mem[20] = 32'h00000463; // beq  x0, x0, End
        mem[21] = 32'h06F00793; // addi x15, x0, 111  (skipped)
        mem[22] = 32'h00700813; // End: addi x16, x0, 7

        for (i = 23; i < 1024; i = i + 1)
            mem[i] = 32'h00000013;
    end
    
    // word-aligned access
    assign instruction = mem[addr[31:2]];

endmodule
