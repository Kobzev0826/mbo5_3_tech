module ipHeader(
	input isIp,
	input [7:0] datain, //входящие данные
	output reg ip_wren_1,
	output reg ip_wren_2,
	input clock,
	output reg isNotAValidPacket,
	output reg dataen,	//строб сопровождения содержимого IP-датаграммы
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

always @(negedge clock) begin
	p <= np & ~counter[0];
end

always @(posedge clock) begin
	if (sclr) begin
		isNotAValidPacket 	<= 0;
		dataen 				<= 0;
		counter 			<= 0;
		EOP 				<= 0;
		checksum 			<= 0;
		sumReg 				<= 0;
	end else
	if (isIp) begin
		case(counter)
			0:sumReg[15:8] <= datain[7:0];
			1:	begin
				sumReg[7:0] <= datain[7:0];
			end
			2:	begin
				sumReg[15:8] <= datain[7:0];
				checksum <= newChecksum;
			end
			3:	begin
				sumReg[7:0] <= datain[7:0];
			end
			4:	begin
				sumReg[15:8] <= datain[7:0];
				checksum <= newChecksum;
			end
			5:	begin
				sumReg[7:0] <= datain[7:0];
			end
			6:	begin
				sumReg[15:8] <= datain[7:0];
				checksum <= newChecksum;
			end
			7:	begin
				sumReg[7:0] <= datain[7:0];
			end
			8:	begin
				sumReg[15:8] <= datain[7:0];
				checksum <= newChecksum;
			end
			9:	begin
				sumReg[7:0] <= datain[7:0];
			end
			
			10: checkSave[15:8] <= ~datain[7:0];
			11:	checkSave[7:0] <= ~datain[7:0];
			
			12:	begin
				sumReg[15:8] <= datain[7:0];
				checksum <= newChecksum;
			end
			13:	begin
				sumReg[7:0] <= datain[7:0];
			end
			14:	begin
				sumReg[15:8] <= datain[7:0];
				checksum <= newChecksum;
			end
			15:	begin
				sumReg[7:0] <= datain[7:0];
			end
			16:	begin
				sumReg[15:8] <= datain[7:0];
				checksum <= newChecksum;
			end
			17:begin
				sumReg[7:0] <= datain[7:0];
			end
			18:	begin
				sumReg[15:8] <= datain[7:0];
				checksum <= newChecksum;
			end
			19:	begin
				sumReg[7:0] <= datain[7:0];
				dataen <= 1;
			end
			20: begin
				if(newChecksum != checkSave)begin
					isNotAValidPacket <= 1;
				end
				EOP <= 1;
			end
		endcase
		
		if (~EOP) counter <= counter + 1'b1;
	end else begin
		isNotAValidPacket 	<= 0;
		dataen 				<= 0;
		counter 			<= 0;
		EOP 				<= 0;
		checksum 			<= 0;
		sumReg 				<= 0;
	end
end

always @(negedge clock) begin
	if (sclr) begin
		ip_wren_1 <= 0;
		ip_wren_2 <= 0;
	end else begin
		case (counter)
			12:	ip_wren_1 <= 1;
			16: begin ip_wren_1 <= 0; ip_wren_2 <= 0; end
			20: ip_wren_2 <= 0;
		endcase
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
