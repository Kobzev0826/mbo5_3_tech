module udpHeader(
	input clock,
	input [7:0] datain,
	input data_en,
	output reg dataen,
	output reg [15:0] PC_PORT,
	output reg [15:0] BOARD_PORT,
	input sclr
);

reg EOP = 0;
reg [4:0] counter = 0;

always @(posedge clock)begin
	if (sclr) begin
			dataen <= 0;
			counter <= 0;
			EOP <= 0;
	end else begin
	if(data_en)begin
		case(counter)
			0:PC_PORT[15:8] <= datain[7:0];
			1:PC_PORT[7:0] <= datain[7:0];
			2:BOARD_PORT[15:8] <= datain[7:0];
			3:BOARD_PORT[7:0] <= datain[7:0];
			7:dataen<=1;
			8:EOP<=1;
		endcase
		if(~EOP) counter <= counter + 5'b1;
	end else begin
		dataen <= 0;
		counter <= 0;
		EOP <= 0;
	end
	end
end
	
endmodule


	


