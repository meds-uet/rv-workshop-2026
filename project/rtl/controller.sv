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
    output logic [1:0] mem_to_reg,
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
                        4'b0010: alu_control = 4'b0110; // SLT
                        4'b0110: alu_control = 4'b0111; // SLTU
                        4'b0100: alu_control = 4'b0101; // SLL
                        4'b1010: alu_control = 4'b1000; // SRL
                        4'b1011: alu_control = 4'b1001; // SRA

                    endcase
            end

            // TODO: Implement remaining instruction types:
            // I-type (0010011)
            // Load (0000011)
            // Store (0100011)
            // Branch (1100011)
            // JAL (1101111)
            // LUI (0110111)

            7'b0010011: begin // I-type
                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm_src   = 3'b000;
                case (funct3)
                    3'b000: alu_control = 4'b0000; // ADDI
                    3'b111: alu_control = 4'b0010; // ANDI
                    3'b110: alu_control = 4'b0011; // ORI
                    3'b100: alu_control = 4'b0100; // XORI
                    3'b001: alu_control = 4'b0101; // SLLI
                    3'b010: alu_control = 4'b0110; // SLTI
                    3'b011: alu_control = 4'b1001; // SLTIU
                    3'b101: alu_control = funct7[5] ? 4'b0111 : 4'b1000; // SRAI/SRLI
                    default: alu_control = 4'b0000;
                endcase
            end

            7'b0000011: begin // Load
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                imm_src    = 3'b000;
                mem_read   = 1'b1;
                mem_to_reg = 2'b10;
                result_src = 1'b1;
                alu_control = 4'b0000; // ADD 
            end

            7'b0100011: begin // Store
                alu_src    = 1'b1;
                imm_src    = 3'b001;
                mem_write  = 1'b1;
                alu_control = 4'b0000; // ADD 
            end

            7'b1100011: begin // Branch
                imm_src     = 3'b010;
                branch      = 1'b1;
                alu_control = 4'b0001; // SUB for comparison
            end

            7'b1101111: begin // JAL
                reg_write  = 1'b1;
                jump       = 1'b1;
                imm_src    = 3'b100;
                mem_to_reg = 2'b00; // Write PC+4 to rd
            end

            7'b0110111: begin // LUI
                reg_write  = 1'b1;
                imm_src    = 3'b011;
                alu_src    = 1'b1;
                alu_control = 4'b0000;
            end

             default: begin
                // NOP or unsupported instruction
            end
        endcase
    end
endmodule