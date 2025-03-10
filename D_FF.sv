module D_FF( input logic clk, rst_n,
    input logic [31:0] pc,
    output logic [31:0] o_pc_debug
);
always_ff @( posedge clk or negedge rst_n) begin 
    if(!rst_n) o_pc_debug <= 0;
    else o_pc_debug <= pc;
end
endmodule