module ourHeader (
	input [7:0] datain,
	input clock,
	input ena,
	input sclr,
	output reg is_type_1,
	output reg is_type_2
);

reg [31:0] flag_type;
reg [2:0] counter;
reg EOP;

always @(posedge clock) begin
	if (sclr) begin
		is_type_1 <= 0;
		is_type_2 <= 0;
		flag_type <= 0;
		counter <= 0;
		EOP <= 0;
	end else if (ena) begin
		if (~EOP) counter <= counter + 1'b1;
		case (counter)
			0: 	begin 
					flag_type[31:24] <= datain[7:0];
				end
			1: 	begin
					flag_type[23:16] <= datain[7:0];
				end
			2: 	begin
					flag_type[15:8]  <= datain[7:0];
				end
			3: 	begin
					flag_type[7:0]   <= datain[7:0];
						case (flag_type[31:24])
							0: is_type_1 <= 1;
							1: is_type_2 <= 1;
						endcase
				end
			4: 	EOP <= 1;
		endcase
	end else begin
		is_type_1 <= 0;
		is_type_2 <= 0;
		flag_type <= 0;
		counter <= 0;
		EOP <= 0;
	end
end

endmodule
