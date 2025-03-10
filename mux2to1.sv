module mux2to1 (
  input  logic i_sel,
  input  logic [31:0]  i_data0,
  input  logic [31:0]  i_data1,
  output logic [31:0]  o_data
);
  assign o_data = (!i_sel) ? i_data0 : i_data1;
  
endmodule