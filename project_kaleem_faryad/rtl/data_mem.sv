module dmem (
    input  logic        clk,
    input  logic        we,
    input  logic        reset,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata
);

    logic [31:0] mem [0:1023];
    integer i;

    // Combinational read
    assign rdata = mem[addr[31:2]];

    // Reset memory and perform writes
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 1024; i = i + 1)
                mem[i] <= 32'h00000000;
        end
        else if (we) begin
            mem[addr[31:2]] <= wdata;
        end
    end

endmodule