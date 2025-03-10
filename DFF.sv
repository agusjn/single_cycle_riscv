module insvalid( input logic clk, rst_n,
    input logic [31:0] insn_vld,
    output logic [31:0] o_insn_vld
);
always_ff @( posedge clk or negedge rst_n) begin 
    if(!rst_n) o_insn_vld <= 0;
    else o_insn_vld <= insn_vld;
end
endmodule