module headerCutter(
	input [7:0] datain,
	input data_en,
	input clock,
	output reg [47:0] BOARD_MAC,
	output reg [47:0] PC_MAC,
	output reg isIp,
	output reg isARP,
	output reg isNotAValidPacket,
	input sclr//,
	//output [15:0] packetID_out
);

//reg [47:0] MY_MAC = 0;
reg [15:0] packetID = 0;
//assign packetID_out = packetID;
reg [3:0] counter = 4'hF;
reg EOP = 0;
always @(posedge clock) begin
	if (sclr) begin
	PC_MAC<=0;
	BOARD_MAC<=0;
	isIp<=0;
	isARP<=0;
	isNotAValidPacket<=0;
	end else
	if (data_en) begin
		if (~EOP) counter<=counter+4'b1;
		case (counter)
			0:	BOARD_MAC[47:40]<=datain[7:0];
			1:	BOARD_MAC[39:32]<=datain[7:0];
			2:	BOARD_MAC[31:24]<=datain[7:0];
			3:	BOARD_MAC[23:16]<=datain[7:0];
			4:	BOARD_MAC[15:8]<=datain[7:0];
			5: 	BOARD_MAC[7:0]<=datain[7:0];
			6:	PC_MAC[47:40]<=datain[7:0];
			7:	PC_MAC[39:32]<=datain[7:0];
			8:	PC_MAC[31:24]<=datain[7:0];
			9:	PC_MAC[23:16]<=datain[7:0];
			10:	PC_MAC[15:8]<=datain[7:0];
			11:	PC_MAC[7:0]<=datain[7:0];
			12:	begin 
					packetID[15:8]<=datain[7:0];
					if (datain[7:0]!=8'h08)
						isNotAValidPacket<=1;
				end
			13:	begin 
					packetID[7:0]<=datain[7:0];
					if (datain[7:0]==8'h00)
						isIp<=1;
					else if (datain[7:0]==8'h06)
						isARP<=1;
					else
						isNotAValidPacket<=1;
				end
			14: EOP<=1;
		endcase
	end else begin
		counter<=4'hF;
		EOP<=0;
		isIp<=0;
		isARP<=0;
		isNotAValidPacket<=0;
	end
end

endmodule
