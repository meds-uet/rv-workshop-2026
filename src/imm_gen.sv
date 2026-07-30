module immgen (
    input  logic [31:0] instruction,
    input  logic [2:0]  imm_src,
    output logic [31:0] imm_ext
);
    always_comb begin
        case (imm_src)
            3'b000:
                imm_ext = {{20{instruction[31]}}, instruction[31:20]};
            3'b001:
                imm_ext = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            3'b010:
                imm_ext = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            3'b011:
                imm_ext = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            3'b100:
                imm_ext = {instruction[31:12], 12'b0};
        default:
                imm_ext = 32'h0000_0000;
        endcase
    end
endmodule