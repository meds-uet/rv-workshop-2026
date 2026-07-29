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

    // immediate type encoding (used by immgen):
    //      000: I-type,  001: S-type,  010: B-type, 011: J-type,  100: U-type

    always_comb begin
        // default control signals
        reg_write   = 1'b0;
        imm_src     = 3'b000;
        alu_src     = 1'b0;
        mem_write   = 1'b0;
        result_src  = 1'b0;
        branch      = 1'b0;
        mem_read    = 1'b0;
        mem_to_reg  = 1'b0;
        jump        = 1'b0;
        alu_control = 4'b0000;

        // generate control signals based on opcode
        case (opcode)

            // R-type instructions
            7'b0110011: begin
                reg_write = 1'b1;
                alu_src   = 1'b0;

                case (funct3)
                    3'b000: alu_control = funct7[5] ? 4'b0001 : 4'b0000;    // SUB / ADD
                    3'b001: alu_control = 4'b0101;                          // SLL
                    3'b010: alu_control = 4'b1000;                          // SLT
                    3'b011: alu_control = 4'b1001;                          // SLTU
                    3'b100: alu_control = 4'b0100;                          // XOR
                    3'b101: alu_control = funct7[5] ? 4'b0111 : 4'b0110;    // SRA / SRL
                    3'b110: alu_control = 4'b0011;                          // OR
                    3'b111: alu_control = 4'b0010;                          // AND
                    default: alu_control = 4'b0000;
                endcase
            end

            // I-type ALU instructions
            7'b0010011: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm_src   = 3'b000;

                case (funct3)
                    3'b000: alu_control = 4'b0000;                         // ADDI
                    3'b010: alu_control = 4'b1000;                         // SLTI
                    3'b011: alu_control = 4'b1001;                         // SLTIU
                    3'b100: alu_control = 4'b0100;                         // XORI
                    3'b110: alu_control = 4'b0011;                         // ORI
                    3'b111: alu_control = 4'b0010;                         // ANDI
                    3'b001: alu_control = 4'b0101;                         // SLLI
                    3'b101: alu_control = funct7[5] ? 4'b0111 : 4'b0110;   // SRAI / SRLI
                    default: alu_control = 4'b0000;
                endcase
            end

            // load word
            7'b0000011: begin
                reg_write   = 1'b1;
                alu_src     = 1'b1;
                imm_src     = 3'b000;
                alu_control = 4'b0000;
                mem_read    = 1'b1;
                mem_to_reg  = 1'b1;
                result_src  = 1'b1;
            end

            // store word
            7'b0100011: begin
                alu_src     = 1'b1;
                imm_src     = 3'b001;
                alu_control = 4'b0000;
                mem_write   = 1'b1;
            end

            // branch instructions
            7'b1100011: begin
                imm_src     = 3'b010;
                alu_src     = 1'b0;
                alu_control = 4'b0001;
                branch      = 1'b1;
            end

            // jump and link
            7'b1101111: begin
                reg_write = 1'b1;
                imm_src   = 3'b011;
                jump      = 1'b1;
            end

            // load upper immediate
            7'b0110111: begin
                reg_write   = 1'b1;
                alu_src     = 1'b1;
                imm_src     = 3'b100;
                alu_control = 4'b0000;
            end

            // unsupported instruction
            default: begin
            end

        endcase
    end

endmodule
