module ipHeader(
	input isIp,
	input [7:0] datain,
	input [31:0] PC_IP,
	input [31:0] BOARD_IP,
	input clock,
	output reg isNotAValidPacket,
	output reg dataen,
	input sclr
);


reg EOP = 0;
reg [4:0] counter = 0;
reg [15:0] checksum = 0;
wire [15:0] newChecksum;
reg [15:0] sumReg = 0;
reg [15:0] checkSave = 0;

reg p;
wire np;

always @(posedge clock) begin
	if (sclr) begin
		isNotAValidPacket <= 0;
		dataen <= 0;
		counter <= 0;
		EOP <= 0;
		checksum <= 0;
		sumReg <= 0;
	end else
	if(isIp)begin
		case(counter)
			0:sumReg[15:8] <= datain[7:0];
			1:begin
				sumReg[7:0] <= datain[7:0];
				p<=np;
			end
			2:begin
				sumReg[15:8] <= datain[7:0];
				checksum <= newChecksum;
			end
			3:begin
				sumReg[7:0] <= datain[7:0];
				p<=np;
			end
			4:begin
				sumReg[15:8] <= datain[7:0];
				checksum <= newChecksum;
			end
			5:begin
				sumReg[7:0] <= datain[7:0];
				p<=np;
			end
			6:begin
				sumReg[15:8] <= datain[7:0];
				checksum <= newChecksum;
			end
			7:begin
				sumReg[7:0] <= datain[7:0];
				p<=np;
			end
			8:begin
				sumReg[15:8] <= datain[7:0];
				checksum <= newChecksum;
			end
			9:begin
				sumReg[7:0] <= datain[7:0];
				p<=np;
			end
			
			10: checkSave[15:8] <= ~datain[7:0];
			11:	checkSave[7:0] <= ~datain[7:0];
			
			12:begin
				sumReg[15:8] <= datain[7:0];
				checksum <= newChecksum;
				if(datain[7:0] != PC_IP[31:24])begin
					isNotAValidPacket <= 1;
					EOP <= 1;	
				end
			end
			13:begin
				sumReg[7:0] <= datain[7:0];
				p<=np;
				if(datain[7:0] != PC_IP[23:16])begin
					isNotAValidPacket <= 1;
					EOP <= 1;
				end
			end
			14:begin
				sumReg[15:8] <= datain[7:0];
				checksum <= newChecksum;
				if(datain[7:0] != PC_IP[15:8])begin
					isNotAValidPacket <= 1;
					EOP <= 1;	
				end
			end
			15:begin
				sumReg[7:0] <= datain[7:0];
				p<=np;
				if(datain[7:0] != PC_IP[7:0])begin
					isNotAValidPacket <= 1;
					EOP <= 1;
				end
			end
			16:begin
				sumReg[15:8] <= datain[7:0];
				checksum <= newChecksum;
				if(datain[7:0] != BOARD_IP[31:24])begin
					isNotAValidPacket <= 1;
					EOP <= 1;	
				end
			end
			17:begin
				sumReg[7:0] <= datain[7:0];
				p<=np;
				if(datain[7:0] != BOARD_IP[23:16])begin
					isNotAValidPacket <= 1;
					EOP <= 1;
				end
			end
			18:begin
				sumReg[15:8] <= datain[7:0];
				checksum <= newChecksum;
				if(datain[7:0] != BOARD_IP[15:8])begin
					isNotAValidPacket <= 1;
					EOP <= 1;	
				end
			end
			19:begin
				sumReg[7:0] <= datain[7:0];
				p<=np;
				
				if(datain[7:0] != BOARD_IP[7:0])begin
					EOP <= 1;
					isNotAValidPacket <= 1;
					
				end
				dataen<=1;
			end
			20: begin
				if(newChecksum != checkSave)begin
					isNotAValidPacket <= 1;
				end
				EOP<=1;
			end
		endcase
		
		if(~EOP) counter <= counter + 5'b1;
	end else begin
		isNotAValidPacket <= 0;
		dataen <= 0;
		counter <= 0;
		EOP <= 0;
		checksum <= 0;
		sumReg <= 0;
	end
end

sum summator(
	.c_in (p),
	.a (checksum),
	.b (sumReg),
	.c_out(np),
	.s (newChecksum)
	);
	

endmodule
