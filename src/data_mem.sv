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

    assign rdata = mem[addr[11:2]];

    always_ff @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 1024; i = i + 1) begin
                mem[i] <= 32'b0;
            end
        end else if (we) begin
            mem[addr[11:2]] <= wdata;
        end
    end
endmodule