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
    logic [6:0]  opcode;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    logic [4:0]  rs1, rs2, rd;

    // Datapath signals
    logic [31:0] rd1, rd2;
    logic [31:0] imm_ext;
    logic [31:0] src_a, src_b;
    logic [31:0] alu_result;
    logic [31:0] read_data;
    logic [31:0] result;

    // Control and Branch signals
    logic       zero;
    logic       take_branch;
    logic       pc_src;
    logic       reg_write;
    logic [2:0] imm_src;
    logic       alu_src;
    logic       mem_write;
    logic       result_src;
    logic       branch;
    logic       mem_read;
    logic       mem_to_reg;
    logic       jump;
    logic [3:0] alu_control;

    // instruction decoding 
    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];


    // PC logic
    assign pc_plus_4 = pc + 4;
    assign pc_target = pc + imm_ext;
    
    // PC jumps if it's a JAL instruction OR a branch whose condition is met
    assign pc_src = jump | (branch & take_branch);
    
    // Mux for next PC
    assign pc_next = pc_src ? pc_target : pc_plus_4;

    //Datapath Mux
    assign src_a = rd1;
    // ALU Source Mux: 0 = Register 2, 1 = Immediate
    assign src_b = alu_src ? imm_ext : rd2;
    
    // Result Mux: 0 = ALU Result, 1 = Data Memory
    assign result = result_src ? read_data : alu_result;


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
    register_file reg_file (
        .clk(clk),
        .we(reg_write),
        .ra1(rs1),
        .ra2(rs2),
        .wa(rd),
        .wd(result),
        .rd1(rd1),
        .rd2(rd2)
    );

    immgen immediate_generator (
        .instruction(instruction),
        .imm_src(imm_src),
        .imm_ext(imm_ext)
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

    // ALU 
    alu arithmetic_logic_unit (
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
        .wdata(rd2), // Store instructions write the value of register rs2
        .rdata(read_data)
    );

    // Branch Unit 
    branch_unit bu (
        .rd1(rd1),
        .rd2(rd2),
        .funct3(funct3),
        .branch(branch),       // Added the 'branch' input that your module expects
        .pc_src(take_branch)   // Connects the module's 'pc_src' output to the processor's 'take_branch' wire
    );

endmodule
