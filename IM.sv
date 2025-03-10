module IM(
  input rst,
  input [31:0]PC,
  output [31:0]ins
  );

  reg [31:0] mem [2047:0]; //2048 * 4 byte = 8192 byte = 8KiB
  
  assign ins = (~rst) ? {32{1'b0}} : mem[PC[31:2]];

  /* initial begin
    $readmemh("../02_test/memfile.hex",mem);
  end
*/


 initial begin
    //mem[0] = 32'hFFC4A303;
    //mem[1] = 32'h00832383;
    // mem[0] = 32'h0064A423;
    // mem[1] = 32'h00B62423;
    mem[0] = 32'h0062E233;
    // mem[1] = 32'h00B62423;

  end

endmodule