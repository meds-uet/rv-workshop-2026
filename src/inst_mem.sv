`timescale 1ns / 1ps
module imem (
    input  logic [31:0] addr,
    output logic [31:0] instruction
);
    logic [31:0] mem [0:1023];
    initial begin
        mem[0] = 32'h00500093;
        mem[1] = 32'h00a00113;
        mem[2] = 32'h002081b3;
        mem[3] = 32'h40110233;
        mem[4] = 32'h003272b3;
        mem[5] = 32'h00326333;
        for (int i = 6; i < 1024; i++) begin
            mem[i] = 32'h00000013;
        end
    end
    assign instruction = mem[addr[11:2]];
endmodule