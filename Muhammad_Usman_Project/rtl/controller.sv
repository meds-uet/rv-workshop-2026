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
        // Default values (all zero)
        reg_write   = 1'b0;
        imm_src     = 3'b000;
        alu_src     = 1'b0;
        mem_write   = 1'b0;
        result_src  = 1'b0;
        branch      = 1'b0;
        jump        = 1'b0;
        mem_read    = 1'b0;
        mem_to_reg  = 1'b0;
        alu_control = 4'b0000;

        case (opcode)
            // R-type
            7'b0110011: begin
                reg_write = 1'b1;
                alu_src   = 1'b0;      // use register operand b
                case ({funct3, funct7[5]})
                    4'b0000: alu_control = 4'b0000; // ADD
                    4'b0001: alu_control = 4'b0001; // SUB
                    4'b1110: alu_control = 4'b0010; // AND
                    4'b1100: alu_control = 4'b0011; // OR
                    4'b1000: alu_control = 4'b0100; // XOR
                    4'b0010: alu_control = 4'b0101; // SLL  (funct7[5]=0)
                    4'b1010: alu_control = 4'b0110; // SRL  (funct7[5]=0)
                    4'b1011: alu_control = 4'b0111; // SRA  (funct7[5]=1)
                    4'b0100: alu_control = 4'b1000; // SLT
                    4'b0110: alu_control = 4'b1001; // SLTU
                    default: alu_control = 4'b0000;
                endcase
            end

            // I-type
            7'b0010011: begin
                reg_write = 1'b1;
                imm_src   = 3'b000;     // I‑type immediate
                alu_src   = 1'b1;       // use immediate
                case (funct3)
                    3'b000: alu_control = 4'b0000; // ADDI
                    3'b001: alu_control = 4'b0101; // SLLI
                    3'b010: alu_control = 4'b1000; // SLTI
                    3'b011: alu_control = 4'b1001; // SLTIU
                    3'b100: alu_control = 4'b0100; // XORI
                    3'b101: begin
                        // SRLI vs SRAI
                        if (funct7[5] == 1'b0)
                            alu_control = 4'b0110; // SRLI
                        else
                            alu_control = 4'b0111; // SRAI
                    end
                    3'b110: alu_control = 4'b0011; // ORI
                    3'b111: alu_control = 4'b0010; // ANDI
                    default: alu_control = 4'b0000;
                endcase
            end

            // Load
            7'b0000011: begin
                reg_write  = 1'b1;
                imm_src    = 3'b000;    // I‑type immediate
                alu_src    = 1'b1;      // compute address = rs1 + imm
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;      // write memory data to register
                result_src = 1'b1;      // select memory data (if used)
                alu_control = 4'b0000;  // ADD for address
            end

            // Store
            7'b0100011: begin
                imm_src   = 3'b001;     // S‑type immediate
                alu_src   = 1'b1;       // compute address = rs1 + imm
                mem_write = 1'b1;
                alu_control = 4'b0000;  // ADD for address
            end

            // B (Branch) - type
            7'b1100011: begin
                branch   = 1'b1;
                imm_src  = 3'b010;      // B‑type immediate
                alu_src  = 1'b0;        // compare rs1 and rs2
                // ALU control depends on funct3
                case (funct3)
                    3'b000: alu_control = 4'b0001; // BEQ  (use SUB, zero flag)
                    3'b001: alu_control = 4'b0001; // BNE  (use SUB, not zero)
                    3'b100: alu_control = 4'b1000; // BLT  (SLT)
                    3'b101: alu_control = 4'b1001; // BGE  (SLT, invert)
                    3'b110: alu_control = 4'b1000; // BLTU (SLTU)
                    3'b111: alu_control = 4'b1001; // BGEU (SLTU, invert)
                    default: alu_control = 4'b0000;
                endcase
                // Branch logic uses ALU result/zero to decide; control only sets branch=1
            end

            // JAL
            7'b1101111: begin
                jump       = 1'b1;
                reg_write  = 1'b1;
                imm_src    = 3'b100;    // J‑type immediate
                // Write PC+4 is handled outside ALU (via jump mux)
                // result_src can be 0 (don't care)
            end

            // LUI
            7'b0110111: begin
                reg_write = 1'b1;
                imm_src   = 3'b011;     // U‑type immediate
                alu_src   = 1'b1;       // use immediate (rs1 is forced to 0 in decode)
                alu_control = 4'b0000;  // ADD (0 + imm_ext)
                // result = imm_ext (since a=0)
            end 
            
            default: begin
                // All control signals remain zero (NOP)
            end
        endcase
    end
endmodule