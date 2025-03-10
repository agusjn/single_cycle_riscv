module mux3to1 (
  input  logic [ 1:0]  i_sel,
  input  logic [31:0]  i_data0,
  input  logic [31:0]  i_data1,
  input  logic [31:0]  i_data2,
  output logic [31:0]  o_data
);
  assign o_data = ( i_sel == 2'b00 ) ? i_data0 :
                  ( i_sel == 2'b01 ) ? i_data1 :
                  ( i_sel == 2'b10 ) ? i_data2 : 32'bx ;
endmodule