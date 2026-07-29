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
    logic [31:0] pc, pc_next, pc_plus_4;

    logic [6:0] opcode;
    logic [4:0] rs1, rs2, rd;
    logic [2:0] funct3;
    logic [6:0] funct7;

    logic       reg_write, alu_src, mem_write, result_src, branch, mem_read, mem_to_reg, jump;
    logic [2:0] imm_src;
    logic [3:0] alu_control;

    logic        reg_dst; 
    logic [4:0]  wa;   
    logic [31:0] rd1, rd2, write_data;
  

    logic [31:0] imm_ext, imm_shifted;

    logic [31:0] alu_b;

    logic [31:0] alu_result;
    logic        zero;

    logic        pc_src;
    logic        and_gate_out;

    logic [31:0] branch_target;

    logic [31:0] rdata;


    logic [31:0] instruction;
    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[25:21];
    assign rs2    = instruction[20:16];
    assign funct7 = instruction[31:25];

    // PC logic
    assign pc_plus_4 = pc + 4; 

    // Debug outputs
    assign pc_out = pc;
    assign instruction_out = instruction;

    assign reg_dst = 1'b1;
    assign imm_shifted   = {imm_ext[29:0], 2'b00};

    assign branch_target = pc_plus_4 + imm_shifted;
    assign and_gate_out = branch & zero;

    assign wa = reg_dst ? instruction[15:11] : instruction[20:16];
    assign alu_b = alu_src ? imm_ext : rd2;
    assign write_data = mem_to_reg ? rdata : alu_result;
    assign pc_next = and_gate_out ? branch_target : pc_plus_4;

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

    control control_unit (
        .opcode      (opcode),
        .funct3      (funct3),
        .funct7      (funct7),
        .reg_write   (reg_write),
        .imm_src     (imm_src),
        .alu_src     (alu_src),
        .mem_write   (mem_write),
        .result_src  (result_src),
        .branch      (branch),
        .mem_read    (mem_read),
        .mem_to_reg  (mem_to_reg),
        .jump        (jump),
        .alu_control (alu_control)
    );

    register_file regs (
        .clk   (clk),
        .we    (reg_write),
        .reset (reset),
        .ra1   (rs1),
        .ra2   (rs2),
        .wa    (wa),
        .wd    (write_data),
        .rd1   (rd1),
        .rd2   (rd2)
    );

    immgen immediate_generator (
        .instruction (instruction),
        .imm_src     (imm_src),
        .imm_ext     (imm_ext)
    );

    alu alu_unit (
        .a           (rd1),
        .b           (alu_b),
        .alu_control (alu_control),
        .result      (alu_result),
        .zero        (zero)
    );

    branch_unit branch_logic (
        .rd1    (rd1),
        .rd2    (rd2),
        .funct3 (funct3),
        .branch (branch),
        .pc_src (pc_src)
    );

    dmem data_memory (
        .clk   (clk),
        .we    (mem_write),
        .reset (reset),
        .addr  (alu_result),
        .wdata (rd2),
        .rdata (rdata)
    );

endmodule

