module SRL(
    input logic [31:0] data,
    input logic [4:0] shamt,
    output logic [31:0] out
);

    logic [31:0] s0;
    logic [31:0] s1;    
    logic [31:0] s2;
    logic [31:0] s3;


    assign s0 = shamt[0] ? {1'b0, data[31:1]} : data;
    assign s1 = shamt[1] ? {2'b0, s0[31:2]} : s0;
    assign s2 = shamt[2] ? {4'b0, s1[31:4]} : s1;
    assign s3 = shamt[3] ? {8'b0, s2[31:8]} : s2;
    assign out = shamt[4] ? {16'b0, s3[31:16]} : s3;

endmodule