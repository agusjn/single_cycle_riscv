module pc_plus_4(
  input  logic [31:0] pc ,
  output logic [31:0] pc_four
);
  assign pc_four = pc + 4;

endmodule: pc_plus_4

///////////////////////////////////////////////////////////////////////////

module PC_block
(
  input  logic  i_clk ,
  input  logic  i_rst_n ,
  input  logic  pc_sel ,
  
  input  logic [31:0] alu_data_i ,
  output logic [31:0] pc4_o,
  output logic [31:0] pc_o
);
  
  logic [31:0] pc4 ;
  logic [31:0] pc_next ;
  
  assign pc4_o = pc4 ;
  
  pc_plus_4 PC_PLUS_4( 
    .pc ( pc_o ),
    .pc_four( pc4  ));
  
  mux2_1_32b PC_MUX (
    .data0_i( pc4        ),
    .data1_i( alu_data_i ),
    .sel_i  ( pc_sel   ),
    .data_o ( pc_next     ));

  always_ff @( posedge i_clk or posedge !i_rst_n) begin : PC_FF
     if ( !i_rst_n ) pc_o <= 32'b0  ;
     else pc_o <= pc_next  ;
     end

  
endmodule: PC_block

///////////////////////////////////////////////////////////////////////////

module mux2_1_32b
(
  input  logic  sel_i ,

  input  logic [31:0] data0_i ,
  input  logic [31:0] data1_i ,

  output logic [31:0] data_o
);

  assign data_o = (sel_i) ? data1_i : data0_i ;
  
endmodule: mux2_1_32b