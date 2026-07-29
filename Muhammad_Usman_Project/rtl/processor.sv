module riscv_processor (
    input  logic clk,
    input  logic reset,
    output logic [31:0] pc_out,
    output logic [31:0] instruction_out
);

    // Internal signals
    logic [31:0] pc, pc_next;
    logic [31:0] instruction;
    logic [6:0]  opcode;
    logic [4:0]  rs1, rs2, rd;
    logic [2:0]  funct3;
    logic [6:0]  funct7;

    logic        reg_write, alu_src, mem_write, result_src;
    logic        branch, mem_read, mem_to_reg, jump;
    logic [2:0]  imm_src;
    logic [3:0]  alu_control;

    logic [31:0] rd1, rd2;
    logic [31:0] imm_ext;
    logic [31:0] src_a, src_b;
    logic [31:0] alu_result;
    logic        zero;
    logic [31:0] read_data;
    logic [31:0] result;
    logic        pc_src;

    // Instruction field decode
    assign opcode = instruction[6:0];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    // PC next logic: sequential by default, branch or jump if taken
    always_comb begin
        pc_next = pc + 4;
        if (pc_src)
            pc_next = pc + imm_ext;      // branch taken
        else if (jump)
            pc_next = pc + imm_ext;      // JAL
    end

    // ALU input and write‑back muxes
    assign src_a = rd1;
    assign src_b = alu_src ? imm_ext : rd2;
    assign result = mem_to_reg ? read_data : alu_result;

    // Program counter
    pc pc_reg (
        .clk    (clk),
        .reset  (reset),
        .pc_next(pc_next),
        .pc     (pc)
    );

    // Instruction memory
    imem instruction_memory (
        .addr       (pc),
        .instruction(instruction)
    );

    // Main control unit
    control control_unit (
        .opcode     (opcode),
        .funct3     (funct3),
        .funct7     (funct7),
        .reg_write  (reg_write),
        .imm_src    (imm_src),
        .alu_src    (alu_src),
        .mem_write  (mem_write),
        .result_src (result_src),
        .branch     (branch),
        .mem_read   (mem_read),
        .mem_to_reg (mem_to_reg),
        .jump       (jump),
        .alu_control(alu_control)
    );

    // Register file
    register_file regfile (
        .clk   (clk),
        .we    (reg_write),
        .reset (reset),
        .ra1   (rs1),
        .ra2   (rs2),
        .wa    (rd),
        .wd    (result),
        .rd1   (rd1),
        .rd2   (rd2)
    );

    // Immediate generator
    immgen imm_gen (
        .instruction(instruction),
        .imm_src    (imm_src),
        .imm_ext    (imm_ext)
    );

    // ALU
    alu alu_unit (
        .a          (src_a),
        .b          (src_b),
        .alu_control(alu_control),
        .result     (alu_result),
        .zero       (zero)
    );

    // Data memory
    dmem data_memory (
        .clk   (clk),
        .we    (mem_write),
        .reset (reset),
        .addr  (alu_result),        // effective address = base + offset
        .wdata (rd2),
        .rdata (read_data)
    );

    // Branch decision unit
    branch_unit branch_decision (
        .rd1   (rd1),
        .rd2   (rd2),
        .funct3(funct3),
        .branch(branch),
        .pc_src(pc_src)
    );

    // Debug outputs
    assign pc_out         = pc;
    assign instruction_out = instruction;

endmodule