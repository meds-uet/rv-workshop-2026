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
    logic [31:0] rd1, rd2, imm_ext, src_a, src_b, alu_result, read_data, result, wa;
    logic zero, pc_src, reg_write, alu_src, mem_write, mem_to_reg, branch, regDst;
    logic [2:0] imm_src;        
    

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
    //              

    // register_file
    // immgen
    // alu
    // dmem
    // control
    // branch_unit

    register_file reg_file (
        .clk(clk),
        .we(reg_write), // TODO: Connect to control signal
        .reset(reset),
        .ra1(instruction[19:15]), // rs1
        .ra2(instruction[24:20]), // rs2
        .wa(wa),   // rd
        .wd(result),               // TODO: Connect to write data (from ALU or memory)
        .rd1(rd1),
        .rd2(rd2)
    );

    mux write_adress_mux (
        .a(instruction[24:20]), // rd
        .b(instruction[15:11]),   
        .sel(regDst),             // TODO: Connect to control signal for jal
        .y(wa)                 // Write address to register file
    );

    mux alu_src_mux (
        .a(rd2), // Register data
        .b(imm_ext), // Immediate value
        .sel(alu_src), // TODO: Connect to control signal
        .y(src_b) // ALU source B
    );

    immgen immediate_generator (
        .instruction(instruction),
        .imm_src(imm_src), // TODO: Connect to control signal
        .imm_ext(imm_ext)
    );

    mux pc_src_mux (
        .a(pc_next), // Next sequential PC
        .b(alu_result), // Branch target address
        .sel(pc_src), // TODO: Connect to branch control signal
        .y(pc_next) // Final PC value
    );

    alu alu_unit (
        .src_a(src_a), // TODO: Connect to rd1 or PC
        .src_b(src_b), // TODO: Connect to rd2 or imm_ext
        .alu_control(alu_control), // TODO: Connect to control signal
        .alu_result(alu_result),
        .zero(zero)
    );

    dmem data_memory (
        .clk(clk),
        .we(mem_write), // TODO: Connect to control signal
        .reset(reset),
        .addr(alu_result), // TODO: Connect to ALU result
        .wdata(rd2),       // TODO: Connect to rd2 for store operations
        .rdata(read_data)
    );

    mux mem_to_reg_mux (
        .a(alu_result), // ALU result
        .b(read_data),  // Data from memory
        .sel(mem_to_reg), // TODO: Connect to control signal
        .y(result) // Final result to write back to register file
    );

    branch_unit branch_unit (
        .zero(zero),
        .branch(branch), // TODO: Connect to control signal
        .pc_src(pc_src)  // TODO: Connect to PC source selection logic
    );


    control control_unit (
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .alu_control(alu_control)
    );

endmodule
