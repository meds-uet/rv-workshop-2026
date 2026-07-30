module riscv_processor (
    input  logic clk,
    input  logic reset,
    output logic [31:0] pc_out,
    output logic [31:0] instruction_out,
    // Exposing internal signals as outputs for waveform debugging
    output logic [31:0] pc, 
    output logic [31:0] pc_next, 
    output logic [31:0] pc_plus4, 
    output logic [31:0] pc_target,
    output logic [31:0] instruction,
    output logic [6:0]  opcode,
    output logic [2:0]  funct3,
    output logic [6:0]  funct7,
    output logic [4:0]  rs1, 
    output logic [4:0]  rs2, 
    output logic [4:0]  rd,
    output logic [31:0] rd1, 
    output logic [31:0] rd2,
    output logic [31:0] imm_ext,
    output logic [31:0] src_a, 
    output logic [31:0] src_b,
    output logic [31:0] alu_result,
    output logic [31:0] read_data,
    output logic [31:0] result,
    output logic        reg_write, 
    output logic        alu_src, 
    output logic        mem_write, 
    output logic        mem_read, 
    output logic        branch, 
    output logic        jump,
    output logic [2:0]  imm_src,
    output logic [1:0]  result_src,
    output logic [3:0]  alu_control,
    output logic        zero,
    output logic        pc_src_branch, 
    output logic        pc_src
);
    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];

    // PC-relative target: correct for branches and JAL (both use PC + imm)
    assign pc_plus4  = pc + 4;
    assign pc_target = pc + imm_ext;
    assign pc_src    = jump | pc_src_branch;
    assign pc_next   = pc_src ? pc_target : pc_plus4;

    assign src_a = rd1;
    assign src_b = alu_src ? imm_ext : rd2;

    assign result = (result_src == 2'b01) ? read_data :
                    (result_src == 2'b10) ? pc_plus4  :
                    alu_result;

    // Backward-compatible outputs
    assign pc_out          = pc;
    assign instruction_out = instruction;

    pc pc_reg (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc(pc)
    );

    imem instruction_memory (
        .addr(pc),
        .instruction(instruction)
    );

    register_file regfile (
        .clk(clk),
        .we(reg_write),
        .reset(reset),
        .ra1(rs1),
        .ra2(rs2),
        .wa(rd),
        .wd(result),
        .rd1(rd1),
        .rd2(rd2)
    );

    immgen imm_gen (
        .instruction(instruction),
        .imm_src(imm_src),
        .imm_ext(imm_ext)
    );

    alu alu_unit (
        .a(src_a),
        .b(src_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );

    dmem data_memory (
        .clk(clk),
        .we(mem_write),
        .reset(reset),
        .addr(alu_result),
        .wdata(rd2),
        .rdata(read_data)
    );

    control control_unit (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .imm_src(imm_src),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .result_src(result_src),
        .branch(branch),
        .mem_read(mem_read),
        .jump(jump),
        .alu_control(alu_control)
    );

    branch_unit branch_unit_inst (
        .rd1(rd1),
        .rd2(rd2),
        .funct3(funct3),
        .branch(branch),
        .pc_src(pc_src_branch)
    );
endmodule