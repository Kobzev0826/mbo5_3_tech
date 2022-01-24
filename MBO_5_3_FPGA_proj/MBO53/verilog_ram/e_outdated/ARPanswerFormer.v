module ARPanswerFormer(
	input clock,
	input [47:0] BOARD_MAC,
	input [31:0] BOARD_IP,
	input [47:0] PC_MAC,
	input [31:0] PC_IP,
	input ena,
	output reg [3:0] dataout,
	output tx_en,
	input sclr
);

assign tx_en = ~EOA;

reg [7:0] counter = 0;
reg [7:0] crcin = 0;
wire [31:0] crcout;
reg EOA = 1;
reg state = 0;
reg crc_on, crc_on_ft;

genvar j;
generate
for (j = 0; j < 60; j = j + 1) begin : gen
	reg [7:0] Shift;
end
endgenerate
integer i;

always @(posedge clock) begin
	if (EOA) begin
		gen[0].Shift[7:0]<=PC_MAC[47:40];
		gen[1].Shift[7:0]<=PC_MAC[39:32];
		gen[2].Shift[7:0]<=PC_MAC[31:24];
		gen[3].Shift[7:0]<=PC_MAC[23:16];
		gen[4].Shift[7:0]<=PC_MAC[15:8];
		gen[5].Shift[7:0]<=PC_MAC[7:0];
		gen[6].Shift[7:0]<=BOARD_MAC[47:40];
		gen[7].Shift[7:0]<=BOARD_MAC[39:32];
		gen[8].Shift[7:0]<=BOARD_MAC[31:24];
		gen[9].Shift[7:0]<=BOARD_MAC[23:16];
		gen[10].Shift[7:0]<=BOARD_MAC[15:8];
		gen[11].Shift[7:0]<=BOARD_MAC[7:0];
		//Shift[12][3:0]<=4'h8;
		//Shift[12][7:4]<=4'h0;
		gen[12].Shift[7:0]<=8'h08;
		//Shift[13][3:0]<=4'h6;
		//Shift[13][7:4]<=4'h0;
		gen[13].Shift[7:0]<=8'h06;
		//Shift[14][3:0]<=4'h0;
		//Shift[14][7:4]<=4'h0;
		gen[14].Shift[7:0]<=8'h00;
		//Shift[15][3:0]<=4'h1;
		//Shift[15][7:4]<=4'h0;
		gen[15].Shift[7:0]<=8'h01;
		//Shift[16][3:0]<=4'h8;
		//Shift[16][7:4]<=4'h0;
		gen[16].Shift[7:0]<=8'h08;
		//Shift[17][3:0]<=4'h0;
		//Shift[17][7:4]<=4'h0;
		gen[17].Shift[7:0]<=8'h00;
		//Shift[18][3:0]<=4'h6;
		//Shift[18][7:4]<=4'h0;
		gen[18].Shift[7:0]<=8'h06;
		//Shift[19][3:0]<=4'h4;
		//Shift[19][7:4]<=4'h0;
		gen[19].Shift[7:0]<=8'h04;
		//Shift[20][3:0]<=4'h0;
		//Shift[20][7:4]<=4'h0;
		gen[20].Shift[7:0]<=8'h00;
		//Shift[21][3:0]<=4'h2;
		//Shift[21][7:4]<=4'h0;
		gen[21].Shift[7:0]<=8'h02;
		gen[22].Shift[7:0]<=BOARD_MAC[47:40];
		gen[23].Shift[7:0]<=BOARD_MAC[39:32];
		gen[24].Shift[7:0]<=BOARD_MAC[31:24];
		gen[25].Shift[7:0]<=BOARD_MAC[23:16];
		gen[26].Shift[7:0]<=BOARD_MAC[15:8];
		gen[27].Shift[7:0]<=BOARD_MAC[7:0];
		gen[28].Shift[7:0]<=BOARD_IP[31:24];
		gen[29].Shift[7:0]<=BOARD_IP[23:16];
		gen[30].Shift[7:0]<=BOARD_IP[15:8];
		gen[31].Shift[7:0]<=BOARD_IP[7:0];
		gen[32].Shift[7:0]<=PC_MAC[47:40];
		gen[33].Shift[7:0]<=PC_MAC[39:32];
		gen[34].Shift[7:0]<=PC_MAC[31:24];
		gen[35].Shift[7:0]<=PC_MAC[23:16];
		gen[36].Shift[7:0]<=PC_MAC[15:8];
		gen[37].Shift[7:0]<=PC_MAC[7:0];
		gen[38].Shift[7:0]<=PC_IP[31:24];
		gen[39].Shift[7:0]<=PC_IP[23:16];
		gen[40].Shift[7:0]<=PC_IP[15:8];
		gen[41].Shift[7:0]<=PC_IP[7:0];
		gen[42].Shift[7:0]<=8'b0;
		gen[43].Shift[7:0]<=8'b0;
		gen[44].Shift[7:0]<=8'b0;
		gen[45].Shift[7:0]<=8'b0;
		gen[46].Shift[7:0]<=8'b0;
		gen[47].Shift[7:0]<=8'b0;
		gen[48].Shift[7:0]<=8'b0;
		gen[49].Shift[7:0]<=8'b0;
		gen[50].Shift[7:0]<=8'b0;
		gen[51].Shift[7:0]<=8'b0;
		gen[52].Shift[7:0]<=8'b0;
		gen[53].Shift[7:0]<=8'b0;
		gen[54].Shift[7:0]<=8'b0;
		gen[55].Shift[7:0]<=8'b0;
		gen[56].Shift[7:0]<=8'b0;
		gen[57].Shift[7:0]<=8'b0;
		gen[58].Shift[7:0]<=8'b0;
		gen[59].Shift[7:0]<=8'b0;
	end else begin
		crcin[7:0]<=gen[0].Shift[7:0];
		for ( i = 0; i < 59; i = i + 1) begin
			if (state)
				gen[i].Shift[7:0]<=gen[i+1].Shift[7:0];
		end
	end
end

always @(posedge clock) begin
	if (sclr) begin
		state <= 0;
		EOA <= 1;
		counter <= 0;
		crc_on <= 0;
		crc_on_ft <= 0;
	end else
	if (ena) begin
		EOA<=0;
		crc_on<=1;
		dataout[3:0]<=4'h5;
	end else if (~EOA) begin
		counter<=counter+8'b1;
		//if (counter<15) 
		//	dataout[3:0]<=4'h5;
		if (counter>14 && counter<135) begin
			state <= ~state;
			if (state) begin
				dataout[3:0]<=gen[0].Shift[7:4];
				crc_on_ft<=0;
			end else begin
				dataout[3:0]<=gen[0].Shift[3:0];
				//if (counter<100) 
				crc_on_ft<=1;
			end
		end
		//if (counter == 133) dataout[3:0]<=Shift[0][3:0];
		//if (counter == 134) begin dataout[3:0]<=Shift[0][7:4]; crc_on_ft<=0; end
		/*if (counter>99 && counter<136) begin
			state = ~state;
			if (state) begin
				dataout[3:0]<=Shift[0][3:0];
			end else begin
				dataout[3:0]<=Shift[0][7:4];
			end
		end*/
		case(counter)
			14:  dataout[3:0]<=4'hD;
			141: dataout[3:0]<=crcout[3:0];
			142: dataout[3:0]<=crcout[7:4];
			139: dataout[3:0]<=crcout[11:8];
			140: dataout[3:0]<=crcout[15:12];
			137: dataout[3:0]<=crcout[19:16];
			138: dataout[3:0]<=crcout[23:20];
			135: dataout[3:0]<=crcout[27:24];
			136: dataout[3:0]<=crcout[31:28];
			143: EOA<=1;
		endcase
	end else begin
		state <= 0;
		EOA <= 1;
		counter <= 0;
		crc_on <= 0;
		crc_on_ft <= 0;
	end
end

CRC32 crc(
	.Eth_ON(crc_on),
	.Clk_125_MHz(clock),
	.D_In(crcin),
	.En_CRC(crc_on_ft),
	.CRC_out(crcout)
);

endmodule
