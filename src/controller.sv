module control (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic       reg_write,
    output logic [2:0] imm_src,
    output logic       alu_src,
    output logic       mem_write,
    output logic [1:0] result_src,
    output logic       branch,
    output logic       mem_read,
    output logic       jump,
    output logic [3:0] alu_control
);
    always_comb begin
        reg_write   = 1'b0;
        imm_src     = 3'b000;
        alu_src     = 1'b0;
        mem_write   = 1'b0;
        result_src  = 2'b00;
        branch      = 1'b0;
        mem_read    = 1'b0;
        jump        = 1'b0;
        alu_control = 4'b0000;

        case (opcode)
            7'b0110011: begin
                reg_write  = 1'b1;
                alu_src    = 1'b0;
                result_src = 2'b00;
                case ({funct3, funct7[5]})
                    4'b0000: alu_control = 4'b0000;
                    4'b0001: alu_control = 4'b0001;
                    4'b0010: alu_control = 4'b0101;
                    4'b0100: alu_control = 4'b1000;
                    4'b0110: alu_control = 4'b1001;
                    4'b1000: alu_control = 4'b0100;
                    4'b1010: alu_control = 4'b0110;
                    4'b1011: alu_control = 4'b0111;
                    4'b1100: alu_control = 4'b0011;
                    4'b1110: alu_control = 4'b0010;
                    default: alu_control = 4'b0000;
                endcase
            end

            7'b0010011: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                imm_src    = 3'b000;
                result_src = 2'b00;
                case (funct3)
                    3'b000: alu_control = 4'b0000;
                    3'b001: alu_control = 4'b0101;
                    3'b010: alu_control = 4'b1000;
                    3'b011: alu_control = 4'b1001;
                    3'b100: alu_control = 4'b0100;
                    3'b101: alu_control = funct7[5] ? 4'b0111 : 4'b0110;
                    3'b110: alu_control = 4'b0011;
                    3'b111: alu_control = 4'b0010;
                endcase
            end

            7'b0000011: begin
                reg_write   = 1'b1;
                alu_src     = 1'b1;
                imm_src     = 3'b000;
                mem_read    = 1'b1;
                result_src  = 2'b01;
                alu_control = 4'b0000;
            end

            7'b0100011: begin
                alu_src     = 1'b1;
                imm_src     = 3'b001;
                mem_write   = 1'b1;
                alu_control = 4'b0000;
            end

            7'b1100011: begin
                alu_src     = 1'b0;
                imm_src     = 3'b010;
                branch      = 1'b1;
                case (funct3)
                    3'b000: alu_control = 4'b0001;
                    3'b001: alu_control = 4'b0001;
                    3'b100: alu_control = 4'b1000;
                    3'b101: alu_control = 4'b1000;
                    3'b110: alu_control = 4'b1001;
                    3'b111: alu_control = 4'b1001;
                    default: alu_control = 4'b0001;
                endcase
            end

            7'b1101111: begin
                reg_write  = 1'b1;
                imm_src    = 3'b011;
                jump       = 1'b1;
                result_src = 2'b10;
            end

            7'b0110111: begin
                reg_write   = 1'b1;
                alu_src     = 1'b1;
                imm_src     = 3'b100;
                result_src  = 2'b00;
                alu_control = 4'b0000;
            end

            default: begin
            end
        endcase
    end
endmodule