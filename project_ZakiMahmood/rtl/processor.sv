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

    // Instruction fields
    logic [6:0] opcode;
    logic [4:0] rs1, rs2, rd;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];

    // Control signals
    logic       reg_write, alu_src, mem_write, result_src;
    logic       branch, jump, mem_read, mem_to_reg;
    logic [2:0] imm_src;
    logic [3:0] alu_control;

    // Datapath signals
    logic [31:0] rd1, rd2, imm_ext;
    logic [31:0] src_a, src_b;
    logic [31:0] alu_result, read_data, result;
    logic        zero, pc_src;
    logic [31:0] pc_plus4, pc_target, jalr_target;

    // PC update logic
    assign pc_plus4    = pc + 32'd4;
    assign pc_target   = pc + imm_ext;                    // branch / JAL target
    assign jalr_target = (rd1 + imm_ext) & ~32'h1;         // JALR target (LSB cleared)

    always_comb begin
        if (jump)
            pc_next = (opcode == 7'b1100111) ? jalr_target : pc_target; // JALR vs JAL
        else if (pc_src)
            pc_next = pc_target;                                       // taken branch
        else
            pc_next = pc_plus4;                                        // sequential
    end

    // ALU operand A: PC for AUIPC, 0 for LUI, rs1 value otherwise
    always_comb begin
        if (opcode == 7'b0010111)      // AUIPC
            src_a = pc;
        else if (opcode == 7'b0110111) // LUI
            src_a = 32'h0000_0000;
        else
            src_a = rd1;
    end

    // ALU operand B: immediate or rs2 value
    assign src_b = alu_src ? imm_ext : rd2;

    // Writeback mux: link address (JAL/JALR) > memory data (load) > ALU result
    always_comb begin
        if (jump)
            result = pc_plus4;
        else if (result_src)
            result = read_data;
        else
            result = alu_result;
    end

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

    register_file reg_file_inst (
        .clk(clk),
        .we(reg_write),
        .reset(reset),
        .ra1(rs1),
        .ra2(rs2),
        .wa(rd),
        .wd(result),
        .rd1(rd1),
        .rd2(rd2)
    );

    immgen imm_gen_inst (
        .instruction(instruction),
        .imm_src(imm_src),
        .imm_ext(imm_ext)
    );

    alu alu_inst (
        .a(src_a),
        .b(src_b),
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

    branch_unit branch_unit_inst (
        .rd1(rd1),
        .rd2(rd2),
        .funct3(funct3),
        .branch(branch),
        .pc_src(pc_src)
    );

endmodule
