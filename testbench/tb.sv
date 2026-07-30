`timescale 1ns/1ps

module tb_riscv_processor();

    // --------------------------------------------------------
    // 1. Signal Declarations
    // --------------------------------------------------------
    logic clk;
    logic reset;

    logic [31:0] pc_out, instruction_out, pc, pc_next, pc_plus4, pc_target, instruction;
    logic [6:0]  opcode, funct7;
    logic [2:0]  funct3;
    logic [4:0]  rs1, rs2, rd;
    logic [31:0] rd1, rd2, imm_ext, src_a, src_b, alu_result, read_data, result;
    logic        reg_write, alu_src, mem_write, mem_read, branch, jump;
    logic [2:0]  imm_src;
    logic [1:0]  result_src;
    logic [3:0]  alu_control;
    logic        zero, pc_src_branch, pc_src;

    // --------------------------------------------------------
    // 2. DUT Instantiation
    // --------------------------------------------------------
    riscv_processor dut (
        .clk(clk),
        .reset(reset),
        .pc_out(pc_out), .instruction_out(instruction_out),
        .pc(pc), .pc_next(pc_next), .pc_plus4(pc_plus4), .pc_target(pc_target),
        .instruction(instruction),
        .opcode(opcode), .funct3(funct3), .funct7(funct7),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .rd1(rd1), .rd2(rd2), .imm_ext(imm_ext),
        .src_a(src_a), .src_b(src_b), .alu_result(alu_result),
        .read_data(read_data), .result(result),
        .reg_write(reg_write), .alu_src(alu_src), .mem_write(mem_write),
        .mem_read(mem_read), .branch(branch), .jump(jump),
        .imm_src(imm_src), .result_src(result_src), .alu_control(alu_control),
        .zero(zero), .pc_src_branch(pc_src_branch), .pc_src(pc_src)
    );

    // --------------------------------------------------------
    // 3. Clock Generation
    // --------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period (100 MHz)
    end

    // --------------------------------------------------------
    // 4. Self-Checking Test Vector Setup
    // --------------------------------------------------------
    typedef struct packed {
        logic [31:0] exp_pc;
        logic        exp_reg_write;
        logic [4:0]  exp_rd;
        logic [31:0] exp_result;
    } test_vector_t;

    localparam int NUM_CYCLES = 6;
    test_vector_t expected_data [0:NUM_CYCLES-1];

    int cycle_count = 0;
    int errors      = 0;

    initial begin
        // Program (from imem):
        //   mem[0] = 00500093  addi x1, x0, 5
        //   mem[1] = 00a00113  addi x2, x0, 10
        //   mem[2] = 002081b3  add  x3, x1, x2
        //   mem[3] = 40110233  sub  x4, x2, x1
        //   mem[4] = 003272b3  and  x5, x4, x3
        //   mem[5] = 00326333  or   x6, x4, x3

        // Cycle 0: addi x1, x0, 5    (PC = 0x00) -> x1 = 5
        expected_data[0] = '{32'h00000000, 1'b1, 5'd1, 32'd5};
        // Cycle 1: addi x2, x0, 10   (PC = 0x04) -> x2 = 10
        expected_data[1] = '{32'h00000004, 1'b1, 5'd2, 32'd10};
        // Cycle 2: add  x3, x1, x2   (PC = 0x08) -> x3 = 5 + 10 = 15
        expected_data[2] = '{32'h00000008, 1'b1, 5'd3, 32'd15};
        // Cycle 3: sub  x4, x2, x1   (PC = 0x0C) -> x4 = 10 - 5 = 5
        expected_data[3] = '{32'h0000000C, 1'b1, 5'd4, 32'd5};
        // Cycle 4: and  x5, x4, x3   (PC = 0x10) -> x5 = 5 & 15 = 5
        expected_data[4] = '{32'h00000010, 1'b1, 5'd5, 32'd5};
        // Cycle 5: or   x6, x4, x3   (PC = 0x14) -> x6 = 5 | 15 = 15
        expected_data[5] = '{32'h00000014, 1'b1, 5'd6, 32'd15};
    end

    // --------------------------------------------------------
    // 5. Reset & Stimulus (synchronized to clock edges)
    // --------------------------------------------------------
    initial begin
        reset = 1;
        // Hold reset across a few full clock periods, release right after a posedge
        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;
    end

    // --------------------------------------------------------
    // 6. Self-Checking Monitor (checked on negedge, after logic settles)
    // --------------------------------------------------------
    always @(negedge clk) begin
        if (!reset && cycle_count < NUM_CYCLES) begin

            if (pc !== expected_data[cycle_count].exp_pc) begin
                $display("ERROR at Cycle %0d: PC mismatch. Expected: %h, Got: %h",
                         cycle_count, expected_data[cycle_count].exp_pc, pc);
                errors++;
            end

            if (reg_write !== expected_data[cycle_count].exp_reg_write) begin
                $display("ERROR at Cycle %0d: reg_write mismatch. Expected: %b, Got: %b",
                         cycle_count, expected_data[cycle_count].exp_reg_write, reg_write);
                errors++;
            end

            if (expected_data[cycle_count].exp_reg_write) begin
                if (rd !== expected_data[cycle_count].exp_rd) begin
                    $display("ERROR at Cycle %0d: rd mismatch. Expected: %0d, Got: %0d",
                             cycle_count, expected_data[cycle_count].exp_rd, rd);
                    errors++;
                end

                if (result !== expected_data[cycle_count].exp_result) begin
                    $display("ERROR at Cycle %0d: result mismatch. Expected: %h, Got: %h",
                             cycle_count, expected_data[cycle_count].exp_result, result);
                    errors++;
                end
            end

            cycle_count++;
        end

        if (cycle_count == NUM_CYCLES) begin
            $display("========================================");
            $display("Simulation Complete!");
            if (errors == 0)
                $display("Status: PASSED (0 errors in %0d cycles)", NUM_CYCLES);
            else
                $display("Status: FAILED (%0d errors found)", errors);
            $display("========================================");
            $finish;
        end
    end

    // --------------------------------------------------------
    // 7. Timeout guard (prevents infinite runs if PC diverges)
    // --------------------------------------------------------
    initial begin
        #10000;
        if (cycle_count < NUM_CYCLES) begin
            $display("========================================");
            $display("TIMEOUT: Only %0d of %0d cycles checked (PC may have diverged).", cycle_count, NUM_CYCLES);
            $display("Status: FAILED (timeout)");
            $display("========================================");
        end
        $finish;
    end

    // --------------------------------------------------------
    // 8. Waveform dump
    // --------------------------------------------------------
    initial begin
        $dumpfile("processor.vcd");
        $dumpvars(0, tb_riscv_processor);
    end

endmodule