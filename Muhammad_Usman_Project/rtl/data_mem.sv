module dmem (
    input  logic        clk,
    input  logic        we,
    input  logic        reset,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata
);

    logic [31:0] mem [0:1023]; // 4KB data memory

    initial begin
        for (int i = 0; i < 1024; i++ ) begin
            mem[i] = 32'b0;
        end
    end

    // Read operation
    assign rdata = mem[addr[31:2]];

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin 
            for (int i = 0; i < 1024; i++ ) begin
                mem[i] <= 32'b0;
            end
        end
        else if (we) begin 
            mem[addr[31:2]] <= wdata;
        end
    end
endmodule