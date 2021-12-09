module messagePartialReporter (
	input clock,
	input [47:0] BOARD_MAC,
	input [31:0] BOARD_IP,
	input [15:0] BOARD_PORT,
	input [47:0] PC_MAC,
	input [31:0] PC_IP,
	input [15:0] PC_PORT,
	input [15:0] data_blocks1,
	input [15:0] data_blocks2,
	input rdempty1,
	input rdempty2,
	input is_there_256_1,
	input is_there_256_2,
	input sclr,
	input [991:0] RAW_STATIC_DATA;
	
	output reg [3:0] dataout,
	output reg tx_en,
	output reg rdreq1,
	output reg rdreq2
);

assign tx_en = ~EOA;

//logic ena = rdempty;

reg [15:0] counter = 0;
reg [2:0] counter1 = 0;
reg [7:0] crcin = 0;
reg [31:0] crcout = 0;
reg EOA = 1;
reg state = 0;
reg crc_on, crc_on_ft;
reg flag1 = 0;
reg flag2 = 0;
reg anti_loop = 0;

reg [173:0][7:0] Shift;
//reg [3:0] c1;
//wire [15:0] d_b;
//assign d_b = {4{c1}};


reg [15:0] ipsum1r, ipsum2r, ipsum3r, ipsum4r, ipsum5r, ipsum6r, ipsum7r;
//reg [65:0][15:0] udpsumr;
reg ipp1, ipp2, ipp3, ipp4, ipp5, ipp6, ipp7;
//reg [65:0] udpp;
//reg ipnp1, ipnp2, ipnp3, ipnp4, ipnp5, ipnp6, ipnp7;
//reg [65:0] udpnp;

reg [31:0] counter_for_sends = 0;

always @(negedge clock) begin
	/*ipp1<=ipnp1;
	ipp2<=ipnp2;
	ipp3<=ipnp3;
	ipp4<=ipnp4;
	ipp5<=ipnp5;
	ipp6<=ipnp6;
	ipp7<=ipnp7;
	for (int i = 0; i<66; i = i+1) begin
		udpp[i]<=udpnp[i];
	end*/
	anti_loop<=~anti_loop;
end

always @(posedge clock) begin
	if (EOA) begin
		Shift[0][7:0]<=PC_MAC[47:40];
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
		
		Shift[24][7:0]<=~ipsum7r[15:8];//IP_CHECKSUM;
		Shift[25][7:0]<=~ipsum7r[7:0];//IP_CHECKSUM;
		
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

		Shift[40][7:0]<=8'h00;//UDP_CHECKSUM
		Shift[41][7:0]<=8'h00;//UDP_CHECKSUM
		
		/*if (flag1) begin
			counter1=counter1+1;
			//c1=c1+1;
			Shift[42][7:0]<=8'h05;
			Shift[43][7:0]<=8'h00; //packetid (cycles mod 256) —ƒ≈Ћј“№!!!
			Shift[44][7:0]<=8'h00; //flag_field 1
			Shift[45][7:0]<=counter1;//8'b0; //flag_field 2
			for (int i = 46; i<169; i = i + 1) begin
				Shift[i][7:0]<=Shift[i+1][7:0];
			end
			Shift[169][7:0]<=data_blocks[7:0];//d_b[7:0];//data_blocks[7:0];
		end else if (~flag2 && EOA) begin
			counter1<=8'hFF;
		end*/
		
	end else begin
		crcin[7:0]<=Shift[0][7:0];
		for (int i = 0; i < 173; i = i + 1) begin
			if (state & ~flag2)
				Shift[i][7:0]<=Shift[i+1][7:0];
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
		flag1<=0;
		flag2<=0;
	end else
	if (~rdempty1 & ~rdempty2 & is_there_256_1 & is_there_256_2 & ~flag1) begin
		flag1 <= 1;
		counter_for_sends <= counter_for_sends + 1;
	end else
	if (EOA & flag1) begin
		if (anti_loop) begin
			EOA<=0;
			crc_on<=1;
			dataout[3:0]<=4'h5;
		end
	end else
	if (~EOA & ~flag2) begin
		counter<=counter+16'b1;
		if (counter>14) crc_on_ft <= 1; //возможно можно вырезать нахер?
		if (counter>14 && counter<363) begin
			state <= ~state;
			if (state) begin
				dataout[3:0]<=Shift[0][7:4];
			end else begin
				dataout[3:0]<=Shift[0][3:0];
			end
		end
		if (counter == 362) begin
			flag2 <= 1;
			rdreq1 <= 1;
		end
	end else
	if (flag2) begin
		state = ~state;
		counter <= counter + 16'b1;
		counter1 <= counter1 + 1'b1;
		case (counter1)
			0: begin rdreq1 <= 0; dataout[3:0] <= data_blocks1[15:12]; Shift[0][7:0] <= data_blocks1[15:8]; end
			1: dataout[3:0] <= data_blocks1[11:8];
			2: begin dataout[3:0] <= data_blocks1[7:4]; Shift[0][7:0] <= data_blocks1[7:0];
			3: begin dataout[3:0] <= data_blocks1[3:0]; rdreq2 <= 1; end
			4: begin rdreq2 <= 0; dataout[3:0] <= data_blocks2[15:12]; Shift[0][7:0] <= data_blocks2[15:8]; end
			5: dataout[3:0] <= data_blocks2[11:8];
			6: begin dataout[3:0] <= data_blocks2[7:4]; Shift[0][7:0] <= data_blocks2[7:0];
			7: begin dataout[3:0] <= data_blocks2[3:0]; rdreq1 <= 1; end
		endcase
	end
	/*
	if (~rdempty && ~flag2) begin
		flag1 <= 1;
		rdreq <= 1;
		if (flag1 && (counter1 == 123)) begin
			flag1 <=0;
			flag2 <=1;
			rdreq <=0;
		end
	end else
	if (flag1) begin
		flag1 <=0;
		flag2 <=1;
		rdreq <=0;
	end else
	if (flag2 && EOA) begin
		if (anti_loop) begin
			EOA<=0;
			crc_on<=1;
			dataout[3:0]<=4'h5;
		end
	end else if (~EOA) begin
		counter<=counter+8'b1;
		if (counter>14 && counter<363) begin
			state <= ~state;
			if (state) begin
				dataout[3:0]<=Shift[0][7:4];
				crc_on_ft<=0;
			end else begin
				dataout[3:0]<=Shift[0][3:0];
				crc_on_ft<=1;
			end
		end
		case(counter)
			14:  dataout[3:0]<=4'hD;
			361: dataout[3:0]<=crcout[3:0];
			362: dataout[3:0]<=crcout[7:4];
			359: dataout[3:0]<=crcout[11:8];
			360: dataout[3:0]<=crcout[15:12];
			357: dataout[3:0]<=crcout[19:16];
			358: dataout[3:0]<=crcout[23:20];
			355: dataout[3:0]<=crcout[27:24];
			356: dataout[3:0]<=crcout[31:28];
			363: begin EOA<=1; flag2<=0; end
		endcase
	end else begin
		state <= 0;
		EOA <= 1;
		counter <= 0;
		crc_on <= 0;
		crc_on_ft <= 0;
		flag1<=0;
		flag2<=0;
	end*/
end

CRC32 crc(
	.Eth_ON(crc_on),
	.Clk_125_MHz(clock),
	.D_In(crcin),
	.En_CRC(crc_on_ft & state),
	.CRC_out(crcout)
);

sum ipsum11(
	.cin (ipp1),
	.dataa ({Shift[14][7:0],Shift[15][7:0]}),
	.datab ({Shift[16][7:0],Shift[17][7:0]}),
	.cout(ipp1&anti_loop),
	.result (ipsum1r)
);
sum ipsum12(
	.cin (ipp2),
	.dataa ({Shift[18][7:0],Shift[19][7:0]}),
	.datab ({Shift[22][7:0],Shift[23][7:0]}),
	.cout(ipp2&anti_loop),
	.result (ipsum2r)
);
sum ipsum13(
	.cin (ipp3),
	.dataa ({Shift[26][7:0],Shift[27][7:0]}),
	.datab ({Shift[28][7:0],Shift[29][7:0]}),
	.cout(ipp3&anti_loop),
	.result (ipsum3r)
);
sum ipsum14(
	.cin (ipp4),
	.dataa ({Shift[30][7:0],Shift[31][7:0]}),
	.datab ({Shift[32][7:0],Shift[33][7:0]}),
	.cout(ipp4&anti_loop),
	.result (ipsum4r)
);
sum ipsum21(
	.cin (ipp5),
	.dataa (ipsum1r),
	.datab (ipsum2r),
	.cout (ipp5&anti_loop),
	.result (ipsum5r)
);
sum ipsum22(
	.cin (ipp6),
	.dataa (ipsum3r),
	.datab (ipsum4r),
	.cout (ipp6&anti_loop),
	.result (ipsum6r)
);
sum ipsum31(
	.cin (ipp7),
	.dataa (ipsum5r),
	.datab (ipsum6r),
	.cout (ipp7&anti_loop),
	.result (ipsum7r)
);



/*sum udpsummer0(
	.cin(udpp[0]),
	.dataa({Shift[34][7:0],Shift[35][7:0]}),
	.datab({Shift[36][7:0],Shift[37][7:0]}),
	.cout(udpp[0]&anti_loop),
	.result(udpsumr[0])
);
sum udpsummer1(
	.cin(udpp[1]),
	.dataa(16'h0121),
	.datab(udpsumr[0]),
	.cout(udpp[1]&anti_loop),
	.result(udpsumr[1])
);
genvar i;
generate
	for (i = 2; i<66; i=i+1) begin : generated 
		sum udpsummer(
			.cin(udpp[i]),
			.dataa({Shift[38 + (2 * i)][7:0],Shift[38 + (2 * i) + 1][7:0]}),
			.datab(udpsumr[i-1]),
			.cout(udpp[i]&anti_loop),
			.result(udpsumr[i])
		);
	end
endgenerate*/
endmodule
