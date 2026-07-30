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
    logic [31:0] rd1, rd2, imm_ext, src_a, src_b, alu_result, read_data, result;
    logic        pc_src, reg_write, alu_src, mem_write, mem_read, jump,branch,result_src;
    logic [1:0] mem_to_reg;
    logic [2:0]  imm_src;
    logic [3:0]  alu_op;
    logic [31:0] pc_in;

    // PC logic
    assign pc_next = pc + 4; // TODO: Replace with branch/jump-aware logic

    // Debug outputs
    assign pc_out = pc;

    assign instruction_out = instruction;

    // Module instantiations

    mux pc_mux (
        .a(pc_next), // Next sequential PC
        .b(alu_result), // Branch target address
        .sel(pc_src), // TODO: Connect to branch control signal
        .y(pc_in) // Final PC value
    );

    pc pc_reg (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_in),
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
        .wa(instruction[11:7]),   // rd
        .wd(result),               // TODO: Connect to write data (from ALU or memory)
        .rd1(rd1),
        .rd2(rd2)
    );

    mux alu_mux_a (
        .a(pc), // rd
        .b(rd1), 
        .sel(jump),             // TODO: Connect to control signal for jal
        .y(src_a)                 // Write address to register file
    );

    mux alu_mux_b (
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


    alu alu_unit (
        .a(src_a), // TODO: Connect to rd1 or PC
        .b(src_b), // TODO: Connect to rd2 or imm_ext
        .alu_control(alu_op), // TODO: Connect to control signal
        .result(alu_result),
        .zero(zero)
    );

    branch_unit branch_unit (
        .rd1(rd1), // TODO: Connect to rd1
        .rd2(rd2), // TODO: Connect to rd2
        .funct3(instruction[14:12]), // TODO: Connect to instruction funct3
        .branch(branch), // TODO: Connect to control signal
        .pc_src(pc_src)
    );


    dmem data_memory (
        .clk(clk),
        .we(mem_write), // TODO: Connect to control signal
        .reset(reset),
        .addr(alu_result), // TODO: Connect to ALU result
        .wdata(rd2),       // TODO: Connect to rd2 for store operations
        .rdata(read_data)
    );

    always_comb begin
        case (mem_to_reg)
            2'b00: result = pc_next; 
            2'b01: result = alu_result; 
            2'b10: result = read_data; 
            default: result = 32'h0000_0000;
        endcase
    end

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
        .alu_control(alu_op)
    );

endmodule