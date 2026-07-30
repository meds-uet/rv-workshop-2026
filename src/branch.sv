module branch_unit (
    input  logic [31:0] rd1, rd2,
    input  logic [2:0]  funct3,
    input  logic        branch,
    output logic        pc_src
);
    logic branch_condition;
    always_comb begin
        case (funct3)
            3'b000:  branch_condition = (rd1 == rd2);
            3'b001:  branch_condition = (rd1 != rd2);
            3'b100:  branch_condition = ($signed(rd1) <  $signed(rd2));
            3'b101:  branch_condition = ($signed(rd1) >= $signed(rd2));
            3'b110:  branch_condition = (rd1 <  rd2);
            3'b111:  branch_condition = (rd1 >= rd2);
            default: branch_condition = 1'b0;
        endcase
    end
    assign pc_src = branch & branch_condition;
endmodule