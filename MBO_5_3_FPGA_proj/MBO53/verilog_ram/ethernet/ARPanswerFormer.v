module ARPanswerFormer(
	input clock,
	//input [47:0] BOARD_MAC, //установленно верные данные текущего соединения о MAC	нашего устройства
	//input [31:0] BOARD_IP,  //установленно верные данные текущего соединения о IP	нашего устройства
	//input [47:0] PC_MAC,    //установленно верные данные текущего соединения о MAC	общающегося с нами устройства
	//input [31:0] PC_IP,     //установленно верные данные текущего соединения о IP	общающегося с нами устройства
	input ena,
	output reg [3:0] dataout,
	output tx_en,
	input sclr,
	
	input [7:0] RAM_IN,
	output RAM_RDEN
);

assign tx_en = ~EOA;
assign RAM_RDEN = state;


reg [7:0] counter = 0;
reg [7:0] crcin = 0;
wire [31:0] crcout;
reg EOA = 1;
reg state = 0;
reg crc_on, crc_on_ft;

//reg [7:0] Shift[59:0];

integer i;
/*
always @(posedge clock) begin
	if (EOA) begin	//формирование пакета согласно протокола ARP(Ethernet)
		Shift[0][7:0]	<=	PC_MAC[47:40];
		Shift[1][7:0]	<=	PC_MAC[39:32];
		Shift[2][7:0]	<=	PC_MAC[31:24];
		Shift[3][7:0]	<=	PC_MAC[23:16];
		Shift[4][7:0]	<=	PC_MAC[15:8];
		Shift[5][7:0]	<=	PC_MAC[7:0];
		Shift[6][7:0]	<=	BOARD_MAC[47:40];
		Shift[7][7:0]	<=	BOARD_MAC[39:32];
		Shift[8][7:0]	<=	BOARD_MAC[31:24];
		Shift[9][7:0]	<=	BOARD_MAC[23:16];
		Shift[10][7:0]	<=	BOARD_MAC[15:8];
		Shift[11][7:0]	<=	BOARD_MAC[7:0];
		Shift[12][7:0]	<=	8'h08;
		Shift[13][7:0]	<=	8'h06;
		Shift[14][7:0]	<=	8'h00;
		Shift[15][7:0]	<=	8'h01;
		Shift[16][7:0]	<=	8'h08;
		Shift[17][7:0]	<=	8'h00;
		Shift[18][7:0]	<=	8'h06;
		Shift[19][7:0]	<=	8'h04;
		Shift[20][7:0]	<=	8'h00;
		Shift[21][7:0]	<=	8'h02;
		Shift[22][7:0]	<=	BOARD_MAC[47:40];
		Shift[23][7:0]	<=	BOARD_MAC[39:32];
		Shift[24][7:0]	<=	BOARD_MAC[31:24];
		Shift[25][7:0]	<=	BOARD_MAC[23:16];
		Shift[26][7:0]	<=	BOARD_MAC[15:8];
		Shift[27][7:0]	<=	BOARD_MAC[7:0];
		Shift[28][7:0]	<=	BOARD_IP[31:24];
		Shift[29][7:0]	<=	BOARD_IP[23:16];
		Shift[30][7:0]	<=	BOARD_IP[15:8];
		Shift[31][7:0]	<=	BOARD_IP[7:0];
		Shift[32][7:0]	<=	PC_MAC[47:40];
		Shift[33][7:0]	<=	PC_MAC[39:32];
		Shift[34][7:0]	<=	PC_MAC[31:24];
		Shift[35][7:0]	<=	PC_MAC[23:16];
		Shift[36][7:0]	<=	PC_MAC[15:8];
		Shift[37][7:0]	<=	PC_MAC[7:0];
		Shift[38][7:0]	<=	PC_IP[31:24];
		Shift[39][7:0]	<=	PC_IP[23:16];
		Shift[40][7:0]	<=	PC_IP[15:8];
		Shift[41][7:0]	<=	PC_IP[7:0];
		Shift[42][7:0]	<=	8'b0;
		Shift[43][7:0]	<=	8'b0;
		Shift[44][7:0]	<=	8'b0;
		Shift[45][7:0]	<=	8'b0;
		Shift[46][7:0]	<=	8'b0;
		Shift[47][7:0]	<=	8'b0;
		Shift[48][7:0]	<=	8'b0;
		Shift[49][7:0]	<=	8'b0;
		Shift[50][7:0]	<=	8'b0;
		Shift[51][7:0]	<=	8'b0;
		Shift[52][7:0]	<=	8'b0;
		Shift[53][7:0]	<=	8'b0;
		Shift[54][7:0]	<=	8'b0;
		Shift[55][7:0]	<=	8'b0;
		Shift[56][7:0]	<=	8'b0;
		Shift[57][7:0]	<=	8'b0;
		Shift[58][7:0]	<=	8'b0;
		Shift[59][7:0]	<=	8'b0;
	end else begin
		crcin[7:0]<=Shift[0][7:0];
		for ( i = 0; i < 59; i = i + 1) begin
			if (state)
				Shift[i][7:0] <= Shift[i+1][7:0];
		end
	end
end*/

always @(posedge clock) begin
	crcin <= RAM_IN;
	if (sclr) begin
		state 		<= 0;
		EOA 		<= 1;
		counter 	<= 0;
		crc_on 		<= 0;
		crc_on_ft 	<= 0;
	end else
	if (ena) begin
		EOA			<=0;
		crc_on		<=1;
		dataout[3:0]<=4'h5;
	end else if (~EOA) begin //отправка сформированного пакета
		counter <= counter + 1'b1;
		if (counter > 14 && counter < 135) begin
			state <= ~state;
			if (state) begin
				dataout[3:0] <= RAM_IN[7:4];
				crc_on_ft <= 0;
			end else begin
				dataout[3:0] <= RAM_IN[3:0];
				crc_on_ft <= 1;
			end
		end 
		case(counter)
			14:  dataout[3:0] <= 4'hD; 
			141: dataout[3:0] <= crcout[3:0]; //отправка вслед за пакетом соответствующей ему CRC-32
			142: dataout[3:0] <= crcout[7:4];
			139: dataout[3:0] <= crcout[11:8];
			140: dataout[3:0] <= crcout[15:12];
			137: dataout[3:0] <= crcout[19:16];
			138: dataout[3:0] <= crcout[23:20];
			135: dataout[3:0] <= crcout[27:24];
			136: dataout[3:0] <= crcout[31:28];
			143: EOA<=1;
		endcase
	end else begin
		state 		<= 0;
		EOA 		<= 1;
		counter 	<= 0;
		crc_on 		<= 0;
		crc_on_ft 	<= 0;
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
