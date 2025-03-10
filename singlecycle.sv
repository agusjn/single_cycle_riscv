module singlecycle(
    input logic i_clk, i_rst_n,
    input logic [31:0] i_io_sw,
    output logic o_insn_vld,
    output logic [31:0] o_pc_debug, o_io_ledr, o_io_ledg,
    output logic [6:0] o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3, o_io_hex4, o_io_hex5, o_io_hex6, o_io_hex7,
    output logic [17:0]   SRAM_ADDR,
    inout  [15:0]         SRAM_DQ,
    output logic          SRAM_CE_N,
    output logic          SRAM_WE_N,
    output logic          SRAM_LB_N,
    output logic          SRAM_UB_N
);

logic [31:0]  alu_data;
logic [31:0]  pc;
logic [31:0]  pc4;
logic [31:0]  instr;
logic [31:0]  rs1_data;
logic [31:0]  rs2_data;
logic [31:0]  wb_data;
logic [31:0]  operand_a;
logic [31:0]  operand_b;
logic [31:0]  ld_data;
logic [31:0]  pc_debug;
logic [31:0]  imm;
logic [ 5:0]  rs1_addr;
logic [ 5:0]  rs2_addr;
logic [ 5:0]  rd_addr;
logic [ 3:0]  alu_op;
logic [ 3:0]  byte_num;
logic [ 1:0]  wb_sel;
logic  pc_sel;
logic  br_un;
logic  br_less;
logic  br_equal;
logic  rd_wren;
logic  mem_wren;
logic  ld_unsigned;
logic  opa_sel;
logic  opb_sel;
logic insn_vld;
logic o_insn;

assign rs1_addr = instr[19:15];
assign rs2_addr = instr[24:20];
assign rd_addr = instr[11:7];
assign o_pc_debug = pc_debug;
assign o_insn_vld = o_insn;

D_FF PCdebug(.clk(i_clk), .rst_n(i_rst_n), .pc(pc), .o_pc_debug(pc_debug));
insvalid ins_vld(.clk(i_clk), .rst_n(i_rst_n), .insn_vld(insn_vld), .o_insn_vld(o_insn));

PC_block PC(.i_clk(i_clk), .i_rst_n(i_rst_n), .pc_sel(pc_sel), .alu_data_i(alu_data), .pc4_o(pc4), .pc_o(pc));
IM imem(.rst(i_rst_n), .PC(pc), .ins(instr));
ImmGen IMMGen(.ins(instr), .imm_out(imm));

brc br_comp(.i_rs1_data(rs1_data), .i_rs2_data(rs2_data), .i_br_un(br_un), .o_br_less(br_less), .o_br_equal(br_equal));

unit ctrl_unit( .instr(instr),
                .br_less(br_less),
                .br_equal(br_equal),
                .pc_sel(pc_sel),
                .br_un(br_un),
                .alu_op(alu_op),
                .rd_wren(rd_wren),
                .mem_wren(mem_wren),
                .mem_wrnum(byte_num),
                .opa_sel(opa_sel),
                .opb_sel(opb_sel),
                .wb_sel(wb_sel),
                .insn_vld(insn_vld));

regfile reg_file(.i_clk(i_clk), .i_rst_n(i_rst_n), .i_rd_wren(rd_wren), .i_rd_addr(rd_addr), .i_rs1_addr(rs1_addr), .i_rs2_addr(rs2_addr), .i_rd_data(wb_data), .o_rs1_data(rs1_data), .o_rs2_data(rs2_data));
ALU ALU(.i_operand_a(operand_a), .i_operand_b(operand_b), .i_alu_op(alu_op), .o_alu_data(alu_data));

mux2to1 opa_mux(.i_sel(opa_sel), .i_data0(pc), .i_data1(rs1_data), .o_data(operand_a));
mux2to1 opb_mux(.i_sel(opb_sel), .i_data0(rs2_data), .i_data1(imm), .o_data(operand_b));

/* lsu LSU(    .i_clk(i_clk),
            .i_rst(i_rst_n),
            .i_lsu_addr(alu_data),
            .i_st_data(rs2_data),
            .i_lsu_wren(mem_wren),
            .o_ld_data(ld_data),
            .o_io_ledr(o_io_ledr),
            .o_io_ledg(o_io_ledg),
            .o_io_hex0(o_io_hex0),
            .o_io_hex1(o_io_hex1),
            .o_io_hex2(o_io_hex2),
            .o_io_hex3(o_io_hex3),
            .o_io_hex4(o_io_hex4),
            .o_io_hex5(o_io_hex5),
            .o_io_hex6(o_io_hex6),
            .o_io_hex7(o_io_hex7),
			.i_io_sw(i_io_sw),
            .SRAM_ADDR(SRAM_ADDR),
            .SRAM_DQ(SRAM_DQ),
            .SRAM_CE_N(SRAM_CE_N),
            .SRAM_WE_N(SRAM_WE_N),
            .SRAM_LB_N(SRAM_LB_N),
            .SRAM_UB_N(SRAM_UB_N)); */

mux3to1 WB_mux( .i_sel(wb_sel),
                .i_data0(pc4),
                .i_data1(alu_data),
                .i_data2(1),
                .o_data(wb_data));

endmodule