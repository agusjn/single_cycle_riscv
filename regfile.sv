module regfile(
        input logic i_clk, i_rst_n,
        input logic i_rd_wren,
        input logic [4:0] i_rd_addr, i_rs1_addr , i_rs2_addr, 
        input logic [31:0] i_rd_data,
        output logic [31:0] o_rs1_data , o_rs2_data 
);

logic [31:0] reg_file [31:0];
integer i;
always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
                for(i=0;i<32;i=i+1) begin
                 reg_file[i] <= 32'h0;
                end
                end
        else if (i_rd_wren) begin
         reg_file[i_rd_addr] <= i_rd_data;
        end
end



assign o_rs1_data = (i_rs1_addr != 0) ? reg_file[i_rs1_addr] : 0;
assign o_rs2_data = (i_rs2_addr != 0) ? reg_file[i_rs2_addr] : 0;
endmodule