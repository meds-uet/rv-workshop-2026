// Copyright 2026 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Umer Shahid (@umershahidengr)
// =============================================================================
// Single-Cycle RISC-V Processor - Top-Level Module (Workshop Skeleton Version)
// =============================================================================

module riscv_processor (
    input  logic clk,
    input  logic reset,
    output logic [31:0] pc_out,
    output logic [31:0] instruction_out
);

    // Internal signals
    logic [31:0] pc, pc_next;
    logic [31:0] instruction;

    // TODO: Declare additional internal signals like:
    // rd1, rd2, imm_ext, src_a, src_b, alu_result, read_data, result
    // zero, pc_src, reg_write, alu_src, mem_write, etc.
    logic [31:0] rd1, rd2, src_a, src_b, result, addr, wdata, rdata, imm_ext, wd;
    logic zero, pc_src, branch, reg_write, alu_src, mem_write, result_src, mem_read, mem_to_reg, jump, we;
    logic [2:0] funct3, imm_src;
    logic [6:0] opcode, funct7;
    logic [3:0] alu_control;
    logic [4:0] wa, ra1, ra2;

    // PC logic
    assign pc_next = pc + 4; // TODO: Replace with branch/jump-aware logic

    // Debug outputs
    assign pc_out = pc;

    assign instruction_out = instruction;

    // Module instantiations

    pc pc_reg (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc(pc)
    );

    imem instruction_memory (
        .addr(pc),
        .instruction(instruction)
    );

    // TODO: Instantiate remaining modules
    // register_file
    register_file register_file (
        .clk(clk),
        .we(we),
        .reset(reset),
        .ra1(ra1),
        .ra2(ra2),
        .wa(wa),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );
    // immgen
    immgen immediate_generator (
        .instruction(instruction),
        .imm_src(imm_src),
        .imm_ext(imm_ext)
    );
    // alu
    alu alu_unit (
        .a(src_a),
        .b(src_b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );
    // dmem
    dmem data_memory (
        .clk(clk),
        .we(mem_write),
        .reset(reset),
        .addr(addr),
        .wdata(wdata),
        .rdata(rdata)
    );
    // control
    control control_unit (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .imm_src(imm_src),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .result_src(result_src),
        .branch(branch),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .jump(jump),
        .alu_control(alu_control)
    );
    // branch_unit
    branch_unit branch_unit (
        .funct3(funct3),
        .rd1(rd1),
        .rd2(rd2),
        .branch(branch),
        .pc_src(pc_src)
    );

endmodule
