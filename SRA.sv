module SRA(
    input logic [31:0] data,
    input logic [4:0] shamt,
    output logic [31:0] out
);

    logic [31:0] s0;
    logic [31:0] s1;
    logic [31:0] s2;
    logic [31:0] s3;
    logic fill_bit; 

    assign fill_bit = data[31]; // Bit dấu được giữ lại khi dịch

    assign s0 = shamt[0] ? {fill_bit, data[31:1]} : data;
    assign s1 = shamt[1] ? {{2{fill_bit}}, s0[31:2]} : s0;
    assign s2 = shamt[2] ? {{4{fill_bit}}, s1[31:4]} : s1;
    assign s3 = shamt[3] ? {{8{fill_bit}}, s2[31:8]} : s2;
    assign out = shamt[4] ? {{16{fill_bit}}, s3[31:16]} : s3;

endmodule