module brc(
    input  logic [31:0] i_rs1_data, i_rs2_data,
    input  logic        i_br_un,
    output logic        o_br_less,
    output logic        o_br_equal
);

always @(*) begin
    if (!i_br_un) begin
        if (i_rs1_data == i_rs2_data) begin
            o_br_equal = 1;
			end
        if (i_rs1_data < i_rs2_data) begin
            o_br_less = 1;
			end
    end else begin
        if ($signed(i_rs1_data) == $signed(i_rs2_data)) begin
            o_br_equal = 1;
			end
        if ($signed(i_rs1_data) < $signed(i_rs2_data)) begin
            o_br_less = 1;
			end
    end
end

endmodule
