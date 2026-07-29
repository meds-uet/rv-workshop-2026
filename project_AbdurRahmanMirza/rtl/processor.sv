// Copyright 2026 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Umer Shahid (@umershahidengr)
// =============================================================================
// Single-Cycle RISC-V Processor - Top-Level Module (Complete)
// =============================================================================

module riscv_processor (
    input  logic clk,
    input  logic reset,

    output logic [31:0] pc_out,
    output logic [31:0] instruction_out
);

    // internal datapath signals
    logic [31:0] pc, pc_next, pc_plus4, pc_target;
    logic [31:0] instruction;

    logic [31:0] rd1, rd2, imm_ext;
    logic [31:0] src_a, src_b, alu_result, read_data, result;
    logic        zero, pc_src;

    // control signals from the control unit
    logic        reg_write, alu_src, mem_write, result_src;
    logic        branch, mem_read, mem_to_reg, jump;
    logic [2:0]  imm_src;
    logic [3:0]  alu_control;

    // break instruction into fields
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    // detect LUI instruction
    logic is_lui;

    assign is_lui = (opcode == 7'b0110111);

    // next pc calculation
    assign pc_plus4  = pc + 4;
    assign pc_target = pc + imm_ext;
    assign pc_next   = (pc_src || jump) ? pc_target : pc_plus4;

    // outputs for debugging
    assign pc_out = pc;
    assign instruction_out = instruction;

    // select ALU inputs
    assign src_a = is_lui ? 32'h0000_0000 : rd1;
    assign src_b = alu_src ? imm_ext : rd2;

    // select data to write back into the register file
    logic [31:0] wb_data;

    assign wb_data = mem_to_reg ? read_data : alu_result;
    assign result  = jump ? pc_plus4 : wb_data;

    // program counter
    pc pc_reg (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc(pc)
    );

    // instruction memory
    imem instruction_memory (
        .addr(pc),
        .instruction(instruction)
    );

    // register file
    register_file reg_file_inst (
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

    // immediate generator
    immgen imm_gen_inst (
        .instruction(instruction),
        .imm_src(imm_src),
        .imm_ext(imm_ext)
    );

    // alu
    alu alu_inst (
        .a(src_a),
        .b(src_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );

    // data Memory
    dmem data_memory (
        .clk(clk),
        .we(mem_write),
        .reset(reset),
        .addr(alu_result),
        .wdata(rd2),
        .rdata(read_data)
    );

    // main control unit
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

    // branch decision logic
    branch_unit branch_unit_inst (
        .rd1(rd1),
        .rd2(rd2),
        .funct3(funct3),
        .branch(branch),
        .pc_src(pc_src)
    );

endmodule
