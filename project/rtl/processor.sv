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
    logic [31:0] rd1, rd2;
    logic [31:0] imm_ext;
    logic [31:0] src_b;
    logic [31:0] alu_result;
    logic [31:0] read_data;
    logic [31:0] result;
    // zero, pc_src, reg_write, alu_src, mem_write, etc.
    logic zero;
    logic pc_src;

    logic reg_write;
    logic [2:0] imm_src;
    logic alu_src;
    logic mem_write;
    logic result_src;
    logic branch;
    logic mem_read;
    logic mem_to_reg;
    logic jump;
    logic [3:0] alu_control;
    // PC logic
    assign pc_next = (pc_src) ? (pc + imm_ext) : (pc + 32'd4);// TODO: Replace with branch/jump-aware logic
    assign src_b   = (alu_src) ? imm_ext : rd2;
    assign result  = (mem_to_reg) ? read_data : alu_result;
    

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
    register_file rf (
        .clk(clk),
        .we(reg_write),
        .reset(reset),
        .ra1(instruction[19:15]),
        .ra2(instruction[24:20]),
        .wa(instruction[11:7]),
        .wd(result),
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
        .a(rd1),
        .b(src_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );
    // dmem
    dmem data_memory (
        .clk(clk),
        .we(mem_write),
        .reset(reset),
        .addr(alu_result),
        .wdata(rd2),
        .rdata(read_data)
    );
    // control
    control control_unit (
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
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
    branch_unit branch_logic (
        .rd1(rd1),
        .rd2(rd2),
        .funct3(instruction[14:12]),
        .branch(branch),
        .pc_src(pc_src)
    );

endmodule

