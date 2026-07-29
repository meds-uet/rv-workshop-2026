module register_file (
    input  logic        clk,
    input  logic        we,
    input logic reset,
    input  logic [4:0]  ra1, ra2, wa,
    input  logic [31:0] wd,
    output logic [31:0] rd1, rd2
);

    logic [31:0] registers [0:31];

    initial begin
        for (int i = 0; i < 32; i++ ) begin
            registers[i] = 32'b0;
        end
    end

    // Read port 1
    assign rd1 = (ra1 == 5'b00000) ? 32'h0000_0000 : registers[ra1];
    // Implemented rd2 read port using same logic as rd1
    assign rd2 = (ra2 == 5'b00000) ? 32'h0000_0000 : registers[ra2];

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'b0;
            end
        end 
        else if (we && (wa != 5'b00000)) begin
            registers[wa] <= wd;
        end
    end   
endmodule