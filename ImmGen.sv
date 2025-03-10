module ImmGen(
	input logic [31:0] ins,
	output logic [31:0] imm_out
);
	always_comb begin
		case (ins[6:0])
			7'b0010011: begin	// I-type 
				case (ins[14:12])
					3'b001, 3'b101: imm_out <= $signed(ins[24:20]);
					default: imm_out <= $signed(ins[31:20]);
				endcase
			end
			7'b0000011: begin	// Load 
				imm_out <= $signed(ins[31:20]);
			end
			7'b0100011: begin	// S-type 
				imm_out <= {{20{ins[31]}}, ins[31:25], ins[11:7]};
			end
			7'b1100011: begin	// B-type 
				imm_out <= {{20{ins[31]}},ins[7],ins[30:25],ins[11:8],1'b0};
			end
			7'b0110111: begin	// U-type 
				imm_out <= {ins[31:12], 12'b0};
			end
			7'b1101111: begin	// J-type 
				imm_out <= {{12{ins[31]}}, ins[19:12], ins[20], ins[30:21], 1'b0};
			end
			default: begin
			imm_out = 32'b0; 
			end
		endcase
	end
endmodule