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

    logic [31:0] rd1, rd2;
    logic [31:0] imm_ext;
    logic [31:0] src_a, src_b;
    logic [31:0] alu_result;
    logic [31:0] read_data;
    logic [31:0] result;

    logic zero;
    logic pc_src;
    logic reg_write;
    logic alu_src;
    logic mem_write;
    logic branch;

    logic [2:0]  imm_src;
    logic [2:0]  alu_control;
    logic [1:0]  result_src;

    // PC logic
    assign pc_next = pc_src ? (pc + imm_ext) : (pc + 32'd4);

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

    register_file register_file_inst (
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

    immgen imm_generator (
        .instruction(instruction),
        .imm_src(imm_src),
        .imm_ext(imm_ext)
    );

    alu alu_inst (
        .a(rd1),
        .b(alu_src ? imm_ext : rd2),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );

    dmem data_memory (
        .clk(clk),
        .we(mem_write),
        .reset(reset),
        .addr(alu_result),
        .wdata(rd2),
        .rdata(read_data)
    );

    control control_unit (
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .zero(zero),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .result_src(result_src),
        .imm_src(imm_src),
        .alu_control(alu_control),
        .pc_src(pc_src)
    );

    branch_unit branch_unit_inst (
        .rd1(rd1),
        .rd2(rd2),
        .funct3(instruction[14:12]),
        .branch(branch),
        .pc_src(pc_src)
    );  

endmodule
