module ALU (
	input logic [31:0] i_operand_a,   
   input logic [31:0] i_operand_b,   
   input logic [3:0]  i_alu_op,      
   output logic [31:0] o_alu_data     
);

    // Định nghĩa các mã lệnh ALU
   localparam ADD  = 4'b0000;
   localparam SUB  = 4'b0001;
   localparam SLT  = 4'b0010;
   localparam SLTU = 4'b0011;
   localparam XOR  = 4'b0100;
   localparam OR   = 4'b0101;
   localparam AND  = 4'b0110;
   localparam SLL  = 4'b0111;
   localparam SRL  = 4'b1000;
   localparam SRA  = 4'b1001;
	
	logic [31:0] o_shifter,slt;
//	logic signed [31:0] a_signed, b_signed;
	logic [32:0] ex_a,ex_b,ex_data;

	Shifter shifter(.data(i_operand_a), .shamt(i_operand_b[4:0]), .op(i_alu_op), .out(o_shifter));

//	assign a_signed = i_operand_a;
//	assign b_signed = i_operand_b;
	assign slt = i_operand_a + ~i_operand_b + 32'h1;
	
	assign ex_a = {1'b0,i_operand_a};
	assign ex_b = {1'b0,i_operand_b};
	assign ex_data = ex_a + ~ex_b + 33'h1;
	
	
    always_comb begin
        case (i_alu_op)
            ADD:  o_alu_data = i_operand_a + i_operand_b;                   
            SUB:  o_alu_data = i_operand_a + ~i_operand_b + 32'h1 ;                  
            SLT:  o_alu_data = slt[31] ? 1 : 0;   
            SLTU: o_alu_data = (~(ex_data[32])) ? 1 : 0; 
            XOR:  o_alu_data = i_operand_a ^ i_operand_b;  
            OR:   o_alu_data = i_operand_a | i_operand_b; 
            AND:  o_alu_data = i_operand_a & i_operand_b;    
            SLL:  o_alu_data = o_shifter;
            SRL:  o_alu_data = o_shifter;
            SRA:  o_alu_data = o_shifter;
            default: o_alu_data = 32'h0;                  
        endcase
    end
endmodule