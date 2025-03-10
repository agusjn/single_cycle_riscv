module lsu (
    input logic i_clk,
    input logic i_reset_n,
    input logic [31:0] i_lsu_addr,
    input logic [31:0] i_st_data,
    input logic i_lsu_wren,
    output logic [31:0] o_ld_data,
    output logic [31:0] o_io_ledr,
    output logic [31:0] o_io_ledg,
    output logic [6:0] o_io_hex0, o_io_hex1,o_io_hex2,o_io_hex3, o_io_hex4,o_io_hex5,o_io_hex6,o_io_hex7,
    input logic [31:0] i_io_sw,
    input logic [3:0] byte_en,
    output logic [17:0]   SRAM_ADDR,
    inout [15:0]          SRAM_DQ  ,
    output logic          SRAM_CE_N,
    output logic          SRAM_WE_N,
    output logic          SRAM_LB_N,
    output logic          SRAM_UB_N
    
);
parameter [31:0] HEX0_addr = 32'h7020;
parameter [31:0] HEX4_addr = 32'h7024;
parameter [31:0] sw_addr   = 32'h7800;
parameter [31:0] ledr_st   = 32'h7000;
parameter [31:0] ledr_end   = 32'h7010;
parameter [31:0] ledg_st   = 32'h7010;
parameter [31:0] ledg_end   = 32'h7020;
parameter [31:0] out_load_st = 32'h7000;
parameter [31:0] out_load_end = 32'h7800;
parameter [31:0] sram_st = 32'h2000;
parameter [31:0] sram_end = 32'h3FFF;
    //SRAM
    logic [31:0] o_data_sram;
    logic o_ACK;
    sram_IS61WV25616_controller_32b_3lr sram(
        .i_ADDR(i_lsu_addr[17:0]),
        .i_WDATA(i_st_data),
        .i_BMASK(byte_en),
        .i_WREN(sram_enable),
        .i_RDEN(~sram_enable),
        .o_RDATA(o_data_sram),
        .o_ACK(o_ACK),
        .SRAM_ADDR(SRAM_ADDR),
        .SRAM_DQ(SRAM_DQ),
        .SRAM_CE_N(SRAM_CE_N),
        .SRAM_WE_N(SRAM_WE_N),
        .SRAM_LB_N(SRAM_LB_N),
        .SRAM_UB_N(SRAM_UB_N),
        .SRAM_OE_N(),
        .i_clk(i_clk),
        .i_reset(i_reset_n));

logic ledr_en, ledg_en, out_en, sram_enable;
logic [31:0] hex_addr;
logic [31:0] led_red;
logic [31:0] led_green;
logic [31:0] switch;
logic [3:0][7:0] hex0;
logic [3:0][7:0] hex4;
logic [31:0] o_ld_data_o;
logic [31:0] switch_addr;

assign out_en = (i_lsu_addr >= out_load_st && i_lsu_addr <= out_load_end) ? 1 : 0;
assign switch_addr = {i_lsu_addr[31:4], 4'b0000};
assign hex_addr = {i_lsu_addr[31:2], 2'b00};
assign ledr_en = (i_lsu_addr >= ledr_st && i_lsu_addr < ledr_end) ? 1 : 0;
assign ledg_en = (i_lsu_addr >= ledg_st && i_lsu_addr < ledg_end) ? 1 : 0;
assign sram_enable  = (i_lsu_addr >= sram_st && i_lsu_addr <= sram_end && i_lsu_wren == 1) ? 1 : 0;
always @(posedge i_clk) begin 
	o_io_ledr <= led_red & 32'h0001FFFF;    //17 red
	o_io_ledg <= led_green & 32'h000000FF;  //8 green 
	o_io_hex0 <= hex0[0];
  o_io_hex1 <= hex0[1];
  o_io_hex2 <= hex0[2];
  o_io_hex3 <= hex0[3];
  o_io_hex4 <= hex4[0];
  o_io_hex5 <= hex4[1];
  o_io_hex6 <= hex4[2];
  o_io_hex7 <= hex4[3];
	switch <= i_io_sw;
end

always @(posedge i_clk or negedge i_reset_n) begin
	if (!i_reset_n) begin
		led_red <= 32'h0000;
		led_green <= 32'h0000;
		hex0 <= 32'h0000;
 		hex4 <= 32'h0000;
	end
    else begin 
        if(i_lsu_wren) begin
            if(ledr_en) begin
                led_red <= i_st_data;
            end
            else if(ledg_en) begin
                led_green <= i_st_data;
            end
            else if(hex_addr == HEX0_addr) begin
              hex0[0] <= i_st_data[7:0];
					    hex0[1] <= i_st_data[15:8];
					    hex0[2] <= i_st_data[23:16];
					    hex0[3] <= i_st_data[31:24];
            end
            else if(hex_addr == HEX4_addr) begin
					    hex4[0] <= i_st_data[7:0];
					    hex4[1] <= i_st_data[15:8];
					    hex4[2] <= i_st_data[23:16];
			        hex4[3] <= i_st_data[31:24];
            end
            else begin
            led_red <= 32'h0000;
		        led_green <= 32'h0000;
		        hex0 <= 32'h0000;
 		        hex4 <= 32'h0000;
            end
        end
        else begin
            if(ledr_en) begin 
                o_ld_data_o <= led_red;
            end
            else if(ledg_en) begin
                o_ld_data_o <= led_green;
            end
            else if(hex_addr == HEX0_addr) begin
                o_ld_data_o <= hex0;
            end
            else if(hex_addr == HEX4_addr) begin
                o_ld_data_o <= hex4;
            end
            else if(switch_addr == sw_addr) begin
                o_ld_data_o <= switch;
            end
            else begin
                o_ld_data_o <= 32'h0000;
            end
        end
    end
end






always@(*) begin
    if(out_en) begin
        if(byte_en == 4'b0001) begin
          o_ld_data <= {24'd0,o_ld_data_o[7:0]};
        end
        else if(byte_en == 4'b0011) begin
          o_ld_data <= {16'd0 ,o_ld_data_o[15:0]};
        end
        else if(byte_en == 4'b1111) begin
          o_ld_data <= o_ld_data_o;
        end
        else begin
          o_ld_data <=  o_ld_data_o;
        end
    end
    else if(sram_enable)begin 
        if(byte_en == 4'b0001) begin
          o_ld_data <= {24'd0,o_data_sram[7:0]};
        end
        else if(byte_en == 4'b0011) begin
          o_ld_data <= {16'd0 ,o_data_sram[15:0]};
        end
        else if(byte_en == 4'b1111) begin
          o_ld_data <= o_data_sram;
        end
        else begin
          o_ld_data <=  o_data_sram;
        end
    end
    else o_ld_data <= o_ld_data;
end

endmodule

module sram_IS61WV25616_controller_32b_3lr (
  input  logic [17:0]   i_ADDR   ,
  input  logic [31:0]   i_WDATA  ,
  input  logic [ 3:0]   i_BMASK  ,
  input  logic          i_WREN   ,
  input  logic          i_RDEN   ,
  output logic [31:0]   o_RDATA  ,
  output logic          o_ACK    ,

  output logic [17:0]   SRAM_ADDR,
  inout   [15:0]   SRAM_DQ  ,
  output logic          SRAM_CE_N,
  output logic          SRAM_WE_N,
  output logic          SRAM_LB_N,
  output logic          SRAM_UB_N,
  input  logic          SRAM_OE_N,

  input logic i_clk,
  input logic i_reset
);

  typedef enum logic [2:0] {
      StIdle
    , StWrite
    , StWriteAck
    , StRead0
    , StRead1
    , StReadAck
  } sram_state_e;

  sram_state_e sram_state_d;
  sram_state_e sram_state_q;
  parameter [15:0] z = 16'bzzzzzzzzzzzzzzzz;
  logic [17:0] addr_d;
  logic [17:0] addr_q;
  logic [31:0] wdata_d;
  logic [31:0] wdata_q;
  logic [31:0] rdata_d;
  logic [31:0] rdata_q;
  logic [ 3:0] bmask_d;
  logic [ 3:0] bmask_q;
  logic [15:0] SRAM_DQ_T;
   always_comb begin : proc_detect_state
    case (sram_state_q)
      StIdle, StWriteAck, StReadAck: begin
        if (i_WREN ~^ i_RDEN) begin
          sram_state_d = StIdle;
          addr_d       = addr_q;
          wdata_d      = wdata_q;
          rdata_d      = rdata_q;
          bmask_d      = bmask_q;
        end
        else begin
          sram_state_d = i_WREN ? StWrite : StRead0;
          addr_d       = i_ADDR & 18'h3FFFE;
          wdata_d      = i_WREN ? i_WDATA : wdata_q;
          rdata_d      = rdata_q;
          bmask_d      = i_BMASK;
        end
      end
      StWrite: begin
        sram_state_d = StWriteAck;
        addr_d       = addr_q | 18'h1;
        wdata_d      = wdata_q;
        rdata_d      = rdata_q;
        bmask_d      = bmask_q;
      end
      StRead0: begin
        sram_state_d = StRead1;
        addr_d       = addr_q | 18'h1;
        wdata_d      = wdata_q;
        rdata_d      = {rdata_q[31:16], SRAM_DQ};
        bmask_d      = bmask_q;
      end
      StRead1: begin
        sram_state_d = StReadAck;
        addr_d       = addr_q;
        wdata_d      = wdata_q;
        rdata_d      = {SRAM_DQ, rdata_q[15:0]};
        bmask_d      = bmask_q;
      end
      default: begin
        sram_state_d = StIdle;
        addr_d       = '0;
        wdata_d      = '0;
        rdata_d      = '0;
        bmask_d      = '0;
      end
    endcase

  end

  always_ff @(posedge i_clk) begin
    if (!i_reset) begin
      sram_state_q <= StIdle;
    end
    else begin
      sram_state_q <= sram_state_d;
    end
  end

  always_ff @(posedge i_clk) begin
    if (!i_reset) begin
      addr_q  <= '0;
      wdata_q <= '0;
      rdata_q <= '0;
      bmask_q <= 4'b0000;
    end
    else begin
      addr_q  <= addr_d;
      wdata_q <= wdata_d;
      rdata_q <= rdata_d;
      bmask_q <= bmask_d;
    end
  end

  always_comb begin : proc_output
    SRAM_ADDR = addr_q;
    SRAM_DQ_T   = z;
    SRAM_WE_N = 1'b1;
    SRAM_CE_N = 1'b1;
    case (sram_state_q)
      StWrite, StRead0: begin
        {SRAM_UB_N, SRAM_LB_N} = ~bmask_q[1:0];
      end
      StWriteAck, StRead1, StReadAck: begin
        {SRAM_UB_N, SRAM_LB_N} = ~bmask_q[3:2];
      end
      default: begin
        {SRAM_UB_N, SRAM_LB_N} = ~bmask_q[1:0];
      end
    endcase

    if (sram_state_q == StWrite) begin
      SRAM_DQ_T   = wdata_q[15:0];
      SRAM_WE_N = 1'b0;
    end
    if (sram_state_q == StWriteAck) begin
      SRAM_DQ_T   = wdata_q[31:16];
      SRAM_WE_N = 1'b0;
    end

    if (sram_state_q != StIdle) begin
      SRAM_CE_N = 1'b0;
    end
  end
  assign SRAM_DQ = SRAM_DQ_T;
  assign o_RDATA = rdata_q;
  assign o_ACK  = (sram_state_q == StWriteAck) || (sram_state_q == StReadAck);

endmodule : sram_IS61WV25616_controller_32b_3lr