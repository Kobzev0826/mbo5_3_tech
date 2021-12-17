module messagePartialReporter (
	input clock,
	input [47:0] BOARD_MAC,		//???????????? ?????? ?????? ? ??????? ??????????
	input [31:0] BOARD_IP,      //???????????? ?????? ?????? ? ??????? ??????????
	input [15:0] BOARD_PORT,    //???????????? ?????? ?????? ? ??????? ??????????
	input [47:0] PC_MAC,        //???????????? ?????? ?????? ? ??????? ??????????
	input [31:0] PC_IP,         //???????????? ?????? ?????? ? ??????? ??????????
	input [15:0] PC_PORT,       //???????????? ?????? ?????? ? ??????? ??????????
	input [15:0] data_blocks1,	//??????, ??????????? ?? ???-1
	input [15:0] data_blocks2,  //??????, ??????????? ?? ???-2
	input is_there_256_1,		//???? ??????? ?????? ?? ???-1
	input is_there_256_2,       //???? ??????? ?????? ?? ???-2
	input sclr,
	input [991:0] RAW_STATIC_DATA,	//?????? ????????????? ?????????
	input ena,
	
	output reg [3:0] dataout,
	output tx_en,
	output reg rdreq1,
	output reg rdreq2
);
integer i;
assign tx_en = ~EOA;

reg [15:0] counter = 0;
reg [2:0] counter1 = 0;
reg [7:0] crcin = 0;
wire [31:0] crcout;
reg EOA = 1;
reg EOC1 = 1;
reg state = 0;
reg crc_on, crc_on_ft;
reg flag1 = 0;
reg flag2 = 0;
reg anti_loop = 0;

reg [7:0] Shift[169:0];

wire [15:0] ipsum1r, ipsum2r, ipsum3r, ipsum4r, ipsum5r, ipsum6r, ipsum7r;
wire ipp1, ipp2, ipp3, ipp4, ipp5, ipp6, ipp7;

reg [31:0] counter_for_sends = 0;

always @(negedge clock) begin
	anti_loop<=~anti_loop;
end

always @(posedge clock) begin
	if (EOA) begin //???????????? ?????? ? ?????? ??? ???????? ????????? UDP-IP(Ethernet)
		Shift[1][7:0]<=PC_MAC[39:32];
		Shift[2][7:0]<=PC_MAC[31:24];
		Shift[3][7:0]<=PC_MAC[23:16];
		Shift[4][7:0]<=PC_MAC[15:8];
		Shift[5][7:0]<=PC_MAC[7:0];
		Shift[6][7:0]<=BOARD_MAC[47:40];
		Shift[7][7:0]<=BOARD_MAC[39:32];
		Shift[8][7:0]<=BOARD_MAC[31:24];
		Shift[9][7:0]<=BOARD_MAC[23:16];
		Shift[10][7:0]<=BOARD_MAC[15:8];
		Shift[11][7:0]<=BOARD_MAC[7:0];
		
		Shift[12][7:0]<=8'h08;
		Shift[13][7:0]<=8'h00;
		
		Shift[14][7:0]<=8'h45;
		Shift[15][7:0]<=8'h00;
		Shift[16][7:0]<=8'h04;
		Shift[17][7:0]<=8'h9C;
		
		Shift[18][7:0]<=8'h23;
		Shift[19][7:0]<=8'h32;
		Shift[20][7:0]<=8'h00;
		Shift[21][7:0]<=8'h00;
		
		Shift[22][7:0]<=8'h80;
		Shift[23][7:0]<=8'h11;
		
		Shift[24][7:0]<=~ipsum7r[15:8];
		Shift[25][7:0]<=~ipsum7r[7:0];
		
		Shift[26][7:0]<=BOARD_IP[31:24];
		Shift[27][7:0]<=BOARD_IP[23:16];
		Shift[28][7:0]<=BOARD_IP[15:8];
		Shift[29][7:0]<=BOARD_IP[7:0];
		Shift[30][7:0]<=PC_IP[31:24];
		Shift[31][7:0]<=PC_IP[23:16];
		Shift[32][7:0]<=PC_IP[15:8];
		Shift[33][7:0]<=PC_IP[7:0];
		
		Shift[34][7:0]<=BOARD_PORT[15:8];
		Shift[35][7:0]<=BOARD_PORT[7:0];
		Shift[36][7:0]<=PC_PORT[15:8];
		Shift[37][7:0]<=PC_PORT[7:0];
		
		Shift[38][7:0]<=8'h04;
		Shift[39][7:0]<=8'h88;

		Shift[40][7:0]<=8'h00;
		Shift[41][7:0]<=8'h00;


Shift[42][7:0]<=RAW_STATIC_DATA[991:984];
Shift[43][7:0]<=RAW_STATIC_DATA[983:976];
Shift[44][7:0]<=RAW_STATIC_DATA[975:968];
Shift[45][7:0]<=RAW_STATIC_DATA[967:960];
Shift[46][7:0]<=RAW_STATIC_DATA[959:952];
Shift[47][7:0]<=RAW_STATIC_DATA[951:944];
Shift[48][7:0]<=RAW_STATIC_DATA[943:936];
Shift[49][7:0]<=RAW_STATIC_DATA[935:928];
Shift[50][7:0]<=RAW_STATIC_DATA[927:920];
Shift[51][7:0]<=RAW_STATIC_DATA[919:912];
Shift[52][7:0]<=RAW_STATIC_DATA[911:904];
Shift[53][7:0]<=RAW_STATIC_DATA[903:896];
Shift[54][7:0]<=RAW_STATIC_DATA[895:888];
Shift[55][7:0]<=RAW_STATIC_DATA[887:880];
Shift[56][7:0]<=RAW_STATIC_DATA[879:872];
Shift[57][7:0]<=RAW_STATIC_DATA[871:864];
Shift[58][7:0]<=RAW_STATIC_DATA[863:856];
Shift[59][7:0]<=RAW_STATIC_DATA[855:848];
Shift[60][7:0]<=RAW_STATIC_DATA[847:840];
Shift[61][7:0]<=RAW_STATIC_DATA[839:832];
Shift[62][7:0]<=RAW_STATIC_DATA[831:824];
Shift[63][7:0]<=RAW_STATIC_DATA[823:816];
Shift[64][7:0]<=RAW_STATIC_DATA[815:808];
Shift[65][7:0]<=RAW_STATIC_DATA[807:800];
Shift[66][7:0]<=RAW_STATIC_DATA[799:792];
Shift[67][7:0]<=RAW_STATIC_DATA[791:784];
Shift[68][7:0]<=RAW_STATIC_DATA[783:776];
Shift[69][7:0]<=RAW_STATIC_DATA[775:768];
Shift[70][7:0]<=RAW_STATIC_DATA[767:760];
Shift[71][7:0]<=RAW_STATIC_DATA[759:752];
Shift[72][7:0]<=RAW_STATIC_DATA[751:744];
Shift[73][7:0]<=RAW_STATIC_DATA[743:736];
Shift[74][7:0]<=RAW_STATIC_DATA[735:728];
Shift[75][7:0]<=RAW_STATIC_DATA[727:720];
Shift[76][7:0]<=RAW_STATIC_DATA[719:712];
Shift[77][7:0]<=RAW_STATIC_DATA[711:704];
Shift[78][7:0]<=RAW_STATIC_DATA[703:696];
Shift[79][7:0]<=RAW_STATIC_DATA[695:688];
Shift[80][7:0]<=RAW_STATIC_DATA[687:680];
Shift[81][7:0]<=RAW_STATIC_DATA[679:672];
Shift[82][7:0]<=RAW_STATIC_DATA[671:664];
Shift[83][7:0]<=RAW_STATIC_DATA[663:656];
Shift[84][7:0]<=RAW_STATIC_DATA[655:648];
Shift[85][7:0]<=RAW_STATIC_DATA[647:640];
Shift[86][7:0]<=RAW_STATIC_DATA[639:632];
Shift[87][7:0]<=RAW_STATIC_DATA[631:624];
Shift[88][7:0]<=RAW_STATIC_DATA[623:616];
Shift[89][7:0]<=RAW_STATIC_DATA[615:608];
Shift[90][7:0]<=RAW_STATIC_DATA[607:600];
Shift[91][7:0]<=RAW_STATIC_DATA[599:592];
Shift[92][7:0]<=RAW_STATIC_DATA[591:584];
Shift[93][7:0]<=RAW_STATIC_DATA[583:576];
Shift[94][7:0]<=RAW_STATIC_DATA[575:568];
Shift[95][7:0]<=RAW_STATIC_DATA[567:560];
Shift[96][7:0]<=RAW_STATIC_DATA[559:552];
Shift[97][7:0]<=RAW_STATIC_DATA[551:544];
Shift[98][7:0]<=RAW_STATIC_DATA[543:536];
Shift[99][7:0]<=RAW_STATIC_DATA[535:528];
Shift[100][7:0]<=RAW_STATIC_DATA[527:520];
Shift[101][7:0]<=RAW_STATIC_DATA[519:512];
Shift[102][7:0]<=RAW_STATIC_DATA[511:504];
Shift[103][7:0]<=RAW_STATIC_DATA[503:496];
Shift[104][7:0]<=RAW_STATIC_DATA[495:488];
Shift[105][7:0]<=RAW_STATIC_DATA[487:480];
Shift[106][7:0]<=RAW_STATIC_DATA[479:472];
Shift[107][7:0]<=RAW_STATIC_DATA[471:464];
Shift[108][7:0]<=RAW_STATIC_DATA[463:456];
Shift[109][7:0]<=RAW_STATIC_DATA[455:448];
Shift[110][7:0]<=RAW_STATIC_DATA[447:440];
Shift[111][7:0]<=RAW_STATIC_DATA[439:432];
Shift[112][7:0]<=RAW_STATIC_DATA[431:424];
Shift[113][7:0]<=RAW_STATIC_DATA[423:416];
Shift[114][7:0]<=RAW_STATIC_DATA[415:408];
Shift[115][7:0]<=RAW_STATIC_DATA[407:400];
Shift[116][7:0]<=RAW_STATIC_DATA[399:392];
Shift[117][7:0]<=RAW_STATIC_DATA[391:384];
Shift[118][7:0]<=RAW_STATIC_DATA[383:376];
Shift[119][7:0]<=RAW_STATIC_DATA[375:368];
Shift[120][7:0]<=RAW_STATIC_DATA[367:360];
Shift[121][7:0]<=RAW_STATIC_DATA[359:352];
Shift[122][7:0]<=RAW_STATIC_DATA[351:344];
Shift[123][7:0]<=RAW_STATIC_DATA[343:336];
Shift[124][7:0]<=RAW_STATIC_DATA[335:328];
Shift[125][7:0]<=RAW_STATIC_DATA[327:320];
Shift[126][7:0]<=RAW_STATIC_DATA[319:312];
Shift[127][7:0]<=RAW_STATIC_DATA[311:304];
Shift[128][7:0]<=RAW_STATIC_DATA[303:296];
Shift[129][7:0]<=RAW_STATIC_DATA[295:288];
Shift[130][7:0]<=RAW_STATIC_DATA[287:280];
Shift[131][7:0]<=RAW_STATIC_DATA[279:272];
Shift[132][7:0]<=RAW_STATIC_DATA[271:264];
Shift[133][7:0]<=RAW_STATIC_DATA[263:256];
Shift[134][7:0]<=RAW_STATIC_DATA[255:248];
Shift[135][7:0]<=RAW_STATIC_DATA[247:240];
Shift[136][7:0]<=RAW_STATIC_DATA[239:232];
Shift[137][7:0]<=RAW_STATIC_DATA[231:224];
Shift[138][7:0]<=RAW_STATIC_DATA[223:216];
Shift[139][7:0]<=RAW_STATIC_DATA[215:208];
Shift[140][7:0]<=RAW_STATIC_DATA[207:200];
Shift[141][7:0]<=RAW_STATIC_DATA[199:192];
Shift[142][7:0]<=RAW_STATIC_DATA[191:184];
Shift[143][7:0]<=RAW_STATIC_DATA[183:176];
Shift[144][7:0]<=RAW_STATIC_DATA[175:168];
Shift[145][7:0]<=RAW_STATIC_DATA[167:160];
Shift[146][7:0]<=RAW_STATIC_DATA[159:152];
Shift[147][7:0]<=RAW_STATIC_DATA[151:144];
Shift[148][7:0]<=RAW_STATIC_DATA[143:136];
Shift[149][7:0]<=RAW_STATIC_DATA[135:128];
Shift[150][7:0]<=RAW_STATIC_DATA[127:120];
Shift[151][7:0]<=RAW_STATIC_DATA[119:112];
Shift[152][7:0]<=RAW_STATIC_DATA[111:104];
Shift[153][7:0]<=RAW_STATIC_DATA[103:96];
Shift[154][7:0]<=RAW_STATIC_DATA[95:88];
Shift[155][7:0]<=RAW_STATIC_DATA[87:80];
Shift[156][7:0]<=RAW_STATIC_DATA[79:72];
Shift[157][7:0]<=RAW_STATIC_DATA[71:64];
Shift[158][7:0]<=RAW_STATIC_DATA[63:56];
Shift[159][7:0]<=RAW_STATIC_DATA[55:48];
Shift[160][7:0]<=RAW_STATIC_DATA[47:40];
Shift[161][7:0]<=RAW_STATIC_DATA[39:32];
Shift[162][7:0]<=RAW_STATIC_DATA[31:24];
Shift[163][7:0]<=RAW_STATIC_DATA[23:16];
Shift[164][7:0]<=RAW_STATIC_DATA[15:8];
Shift[165][7:0]<=RAW_STATIC_DATA[7:0];

    Shift[166][7:0]<=counter_for_sends[31:24];
    Shift[167][7:0]<=counter_for_sends[23:16];
    Shift[168][7:0]<=counter_for_sends[15:8];
    Shift[169][7:0]<=counter_for_sends[7:0];
		
	end else begin
		crcin[7:0] <= Shift[0][7:0];
		for (i = 1; i < 169; i = i + 1) begin
			if (state)
				Shift[i][7:0]<=Shift[i+1][7:0];
		end
	end
end

always @(posedge clock) begin
	if (sclr) begin
		state 		<= 0;
		EOA 		<= 1;
		counter 	<= 0;
		crc_on 		<= 0;
		crc_on_ft 	<= 0;
		flag1		<=0;
		flag2		<=0;
		rdreq1		<=0;
		rdreq2		<=0;
	end else
	if (is_there_256_1 & is_there_256_2 & ~flag1 & ena) begin
		flag1 		<= 1;
		Shift[0][7:0] <= PC_MAC[47:40];
		state 		<= 0;
		EOA 		<= 1;
		counter 	<= 0;
		crc_on 		<= 0;
		crc_on_ft 	<= 0;
		flag2		<=0;
		rdreq1		<=0;
		rdreq2		<=0;
	end else
	if (EOA & flag1) begin
		if (anti_loop) begin
			EOA <= 0;
			crc_on <= 1;
			dataout[3:0] <= 4'h5;
		end
	end else
	if (~EOA & ~flag2) begin
		if ((counter>13) & state) Shift[0][7:0]<=Shift[1][7:0];
		counter <= counter + 1'b1;
		if (counter == 13) dataout[3:0] <= 4'hD; 
		if (counter > 13) crc_on_ft <= 1;
		if (counter > 13 && counter < 354) begin
			state <= ~state;
			if (state) begin
				dataout[3:0] <= Shift[0][7:4];
			end else begin
				dataout[3:0] <= Shift[0][3:0];
			end
		end
		if (counter == 353) begin
			flag2 	 <= 1;
			rdreq1 	 <= 1;
			EOC1 	 <= 0;
			counter1 <= 0;
		end //?????????? ?????????? ????????????? ????? ??????
	end else
	if (flag2) begin //???????? ???????????? ????? ?????? (?????? ?? ??? ?? fifo)
		state <= ~state;
		counter <= counter + 1'b1;
		if (~EOC1) counter1 <= counter1 + 1'b1;
		case (counter1)
			0: 	begin 
					rdreq1 <= 0; 
					dataout[3:0] <= data_blocks1[11:8]; 
					Shift[0][7:0] <= data_blocks1[15:8]; 
				end
			1: 	dataout[3:0] <= data_blocks1[15:12];
			2:	begin 
					dataout[3:0] <= data_blocks1[3:0]; 
					Shift[0][7:0] <= data_blocks1[7:0]; 
				end
			3: 	begin 
					dataout[3:0] <= data_blocks1[7:4]; 
					rdreq2 <= 1; 
				end
			4: 	begin 
					rdreq2 <= 0; 
					dataout[3:0] <= data_blocks2[11:8]; 
					Shift[0][7:0] <= data_blocks2[15:8];
				end                     
			5: 	dataout[3:0] <= data_blocks2[15:12];
			6: 	begin                   
					dataout[3:0] <= data_blocks2[3:0]; 
					Shift[0][7:0] <= data_blocks2[7:0]; 
				end                     
			7: 	begin                   
					dataout[3:0] <= data_blocks2[7:4]; 
					if (counter!=2410) begin //?????????? ???????????? ????? ?????? 
						rdreq1 <= 1;
					end else begin
						EOC1 <= 1;
					end
				end
		endcase

		case(counter)	//???????? CRC-32 ??????
			2401: begin crc_on_ft <= 0; counter_for_sends <= counter_for_sends + 1'b1; end
			2408: dataout[3:0] <= crcout[3:0];
			2409: dataout[3:0] <= crcout[7:4];
			2406: dataout[3:0] <= crcout[11:8];
			2407: dataout[3:0] <= crcout[15:12];
			2404: dataout[3:0] <= crcout[19:16];
			2405: dataout[3:0] <= crcout[23:20];
			2402: dataout[3:0] <= crcout[27:24];
			2403: dataout[3:0] <= crcout[31:28];
			2410: begin EOA <= 1; flag1 <= 0; flag2 <= 0; end
		endcase
	end
end

CRC32 crc(
	.Eth_ON(crc_on),
	.Clk_125_MHz(clock),
	.D_In(crcin),
	.En_CRC(crc_on_ft & state),
	.CRC_out(crcout)
);

sum ipsum11(
	.c_in (ipp1&anti_loop),
	.a ({Shift[14][7:0],Shift[15][7:0]}),
	.b ({Shift[16][7:0],Shift[17][7:0]}),
	.c_out(ipp1),
	.s (ipsum1r)
);
sum ipsum12(
	.c_in (ipp2&anti_loop),
	.a ({Shift[18][7:0],Shift[19][7:0]}),
	.b ({Shift[22][7:0],Shift[23][7:0]}),
	.c_out(ipp2),
	.s (ipsum2r)
);
sum ipsum13(
	.c_in (ipp3&anti_loop),
	.a ({Shift[26][7:0],Shift[27][7:0]}),
	.b ({Shift[28][7:0],Shift[29][7:0]}),
	.c_out(ipp3),
	.s (ipsum3r)
);
sum ipsum14(
	.c_in (ipp4&anti_loop),
	.a ({Shift[30][7:0],Shift[31][7:0]}),
	.b ({Shift[32][7:0],Shift[33][7:0]}),
	.c_out(ipp4),
	.s (ipsum4r)
);
sum ipsum21(
	.c_in (ipp5&anti_loop),
	.a (ipsum1r),
	.b (ipsum2r),
	.c_out (ipp5),
	.s (ipsum5r)
);
sum ipsum22(
	.c_in (ipp6&anti_loop),
	.a (ipsum3r),
	.b (ipsum4r),
	.c_out (ipp6),
	.s (ipsum6r)
);
sum ipsum31(
	.c_in (ipp7&anti_loop),
	.a (ipsum5r),
	.b (ipsum6r),
	.c_out (ipp7),
	.s (ipsum7r)
);

endmodule
