// Copyright 2026 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Umer Shahid (@umershahidengr)
// =============================================================================
// Single-Cycle RISC-V Processor - Complete Implementation
// MEDS Workshop: "Build your own RISC-V Processor in a day"
// =============================================================================
// =============================================================================
// CONTROL UNIT MODULE
// =============================================================================
module control (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic       reg_write,
    output logic [2:0] imm_src,
    output logic       alu_src,
    output logic       mem_write,
    output logic       result_src,
    output logic       branch,
    output logic       mem_read,
    output logic       mem_to_reg,
    output logic       jump,
    output logic [3:0] alu_control
);

    always_comb begin
            // Default values
            reg_write   = 1'b0;
            imm_src     = 3'b000;
            alu_src     = 1'b0;
            mem_write   = 1'b0;
            result_src  = 1'b0;
            branch      = 1'b0;
            jump        = 1'b0;
            alu_control = 4'b0000;

            case (opcode)
                7'b0110011: begin // R-type (only ADD shown as example)
                    reg_write = 1'b1;
                    case ({funct3, funct7[5]})
                        4'b0000: alu_control = 4'b0000; // ADD
                        // TODO: Implement other R-type operations
                        4'b0001: alu_control = 4'b0001; // SUB
                        4'b1110: alu_control = 4'b0010; // AND
                        4'b1100: alu_control = 4'b0011; // OR
                        4'b1000: alu_control = 4'b0100; // XOR
                        4'b0010: alu_control = 4'b0101; // SLL
                        4'b1010: alu_control = 4'b0110; // SRL
                        4'b1011: alu_control = 4'b0111; // SRA
                        4'b0100: alu_control = 4'b1000; // SLT
                        4'b0110: alu_control = 4'b1001; // SLTU
                        default: alu_control = 4'b0000;
                    endcase
                end

            // TODO: Implement remaining instruction types:
            // I-type (0010011)
                7'b0010011: begin
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    imm_src = 3'b000;
                    case ({funct3, funct7[5]})
                        4'b0000: alu_control = 4'b0000; // ADDI
                        4'b0010: alu_control = 4'b0101; // SLLI
                        4'b0100: alu_control = 4'b1000; // SLTI
                        4'b0110: alu_control = 4'b1001; // SLTIU
                        4'b1000: alu_control = 4'b0100; // XORI
                        4'b1010: alu_control = 4'b0110; // SRLI
                        4'b1011: alu_control = 4'b0111; // SRAI
                        4'b1100: alu_control = 4'b0011; // ORI
                        4'b1110: alu_control = 4'b0010; // ANDI
                        default: alu_control = 4'b0000;
                    endcase
                end
            // Load (0000011)
                7'b0000011: begin
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    result_src = 1'b1;
                    mem_read = 1'b1;
                    mem_to_reg = 1'b1;
                    imm_src = 3'b000;
                    alu_control = 4'b0000;
                end
            // Store (0100011)
                7'b0100011: begin
                    alu_src = 1'b1;
                    mem_write = 1'b1;
                    imm_src = 3'b001;
                    alu_control = 4'b0000;
                end
            // Branch (1100011)
                7'b1100011: begin
                    branch = 1'b1;
                    imm_src = 3'b010;
                    alu_control = 4'b0001;
                end
            // JAL (1101111)
                7'b1101111: begin
                    reg_write = 1'b1;
                    jump = 1'b1;
                    imm_src = 3'b100;
                    alu_control = 4'b0000;
                end
            // LUI (0110111)
                7'b0110111: begin
                    reg_write = 1'b1;
                    alu_src = 1'b1;
                    imm_src = 3'b011;
                    alu_control = 4'b0000;
                end

             default: begin
                // NOP or unsupported instruction
                //This should keep the default values4
            end
        endcase
    end
endmodule
