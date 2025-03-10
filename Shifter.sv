module Shifter(
    input logic [31:0] data,
    input logic [4:0] shamt,
    input logic [3:0] op, 
    output logic [31:0] out
);

    logic [31:0] o_SLL;
    logic [31:0] o_SRL;
    logic [31:0] o_SRA;
   

    SLL sll(.data(data), .shamt(shamt), .out(o_SLL));
    SRL slr(.data(data), .shamt(shamt), .out(o_SRL));
    SRA bsl(.data(data), .shamt(shamt), .out(o_SRA));


    assign out = (op == 4'b0111) ? o_SLL :
                 (op == 4'b1000) ? o_SRL :
					  (op == 4'b1000) ? o_SRL : 31'b0;

endmodule