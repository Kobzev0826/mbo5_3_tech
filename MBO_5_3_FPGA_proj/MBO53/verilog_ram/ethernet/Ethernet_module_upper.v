module Ethernet_module_upper #(
parameter CONST_BOARD_IP = {8'd192,8'd168,8'd0,8'd127},
parameter CONST_BOARD_MAC = {24'h902b34,24'h0D0EE6}
)(
input [3:0] RX_D,
input RX_DV,
input RX_CLK,

output [3:0] TX_D,
output TX_EN,
input TX_CLK, //ЕРЕСЬ, ну ладно

input clk_main, //тактовая частота обработчиков данных, если такие вдруг будут
//input clk_25, //несущая частота для выдачи данных если TX_CLK всё же output
input clk_12_5, //частота поступления данных (25MHz x 4 bit = 12.5MHz x 1 byte)

input reset_global_in_1, //входы ресета, по 1 на каждую pll в проекте
input reset_global_in_2,
input reset_global_in_3, // + 1 кастомный

input [15:0] data_blocks1, //входящие данные от АЦП
input [15:0] data_blocks2,


input is_there_256_1, //сигнал наличия входящих данных от АЦП
input is_there_256_2,
//input [991:0] RAW_STATIC_DATA, //данные заголовка отправляемого пакета
output rdreq1, //запрос данных АЦП
output rdreq2,

input [7:0] RAM_120_IN,
output RAM_120_RDEN,
output [7:0] RAM_120_OUT,
output RAM_120_WREN,

//output [991:0] header_parsed, //данные заголовка получаемого пакета
//output header_parsed_valid,   // ... и их валидность

output [15:0] data_type_one, //данные тела пакета типа 1
output data_type_one_wren	 // ... и их валидность

,
output debug_led_2,
output debug_led_1,

output local_reset_summary
);
//=======================================================

assign debug_led_2 = local_reset_signal_5;
assign debug_led_1 = (state == 2) && arp_request;

//======================GLOBAL===========================

integer i;

wire local_reset_signal_1, local_reset_signal_2, local_reset_signal_3, local_reset_signal_4;
reg local_reset_signal_5;
wire local_reset_summary, global_reset_summary;

assign local_reset_summary = global_reset_summary | local_reset_signal_1 | local_reset_signal_2 | local_reset_signal_3 | local_reset_signal_4 | local_reset_signal_5; 
assign global_reset_summary = reset_global_in_1 | reset_global_in_2 | reset_global_in_3;

//================INPUT=START============================

wire [7:0] input_8bit_init;
wire input_8bit_init_ena;

reg [3:0] RX_DATA;

always @(negedge RX_CLK) begin
	RX_DATA <= RX_D;
end

FourToEight fte( //module that translates 25Mhz 4bit Ethernet wire input
				//into 12.5 mhz 8bit format with 25MHz enable signal for
			   //writing into FIFO by 25 MHz clock to switch clock domain
	.clock(RX_CLK),
	.datain(RX_DATA),
	.ena(RX_DV),
	.dataout(input_8bit_init),
	.wren(input_8bit_init_ena),
	.error_pzdc(local_reset_signal_1)
);

//=============CLOCK=DOMAIN=CHANGE=======================

wire input_empty, input_rd_req;
wire [7:0] input_8bit;

assign input_rd_req = input_info_valid_read;
reg fifo_flush;

fifo_25_12_5 fifo_input(
	.rst(1'b0),//local_reset_summary),
	.wr_clk(RX_CLK),
	.rd_clk(clk_12_5),
	.din(input_8bit_init),
	.wr_en(input_8bit_init_ena),
	.rd_en(input_rd_req),
	.dout(input_8bit),
	.full(),
	.empty(input_empty),
	.rd_data_count()
);

always @(posedge RX_CLK) begin
	if (local_reset_summary) begin
		fifo_flush <= 1;
	end else if (input_empty) begin
		fifo_flush <= 0;
	end
end

//===========INNER=DATA=VALIDATION=======================

localparam DATA_VALIDATION_PROLONGING = 4'd4; 
wire input_info_valid_read;
reg [3:0] counter_for_prolonging_data_validation;
reg preambula_ended, preambula_ended_short;
wire [7:0] input_data;
reg [18:0] input_fifo_rdempty_delay;//задержка для выхода фифо ( 16 тактов буффер в фифо)

assign input_info_valid_read = input_fifo_rdempty_delay[0] & input_fifo_rdempty_delay[15];

always @(posedge clk_12_5) begin
	if (input_info_valid_read) begin
		if (input_fifo_rdempty_delay[18] & ~fifo_flush) begin 
			preambula_ended <= 1;
			preambula_ended_short <= 1;
		end else begin
			preambula_ended <= 0;
			preambula_ended_short <= 0;
		end
	end else begin
		if (preambula_ended) begin
			if (counter_for_prolonging_data_validation == DATA_VALIDATION_PROLONGING) begin
				preambula_ended <= 0;
			end else begin
				//nothing
			end
			counter_for_prolonging_data_validation <= counter_for_prolonging_data_validation + 1;
		end else begin
			counter_for_prolonging_data_validation <= 0;
		end
		preambula_ended_short <= 0;
	end
end

//======INPUT=DATA=DOMAIN=CHANGED========================

reg [7:0] input_last_4_bytes [3:0];

assign input_data = input_last_4_bytes[3][7:0];

always @(negedge clk_12_5) begin
	for (i = 0; i < 18; i = i + 1) begin
		input_fifo_rdempty_delay[i+1] <= input_fifo_rdempty_delay[i];
	end
	input_fifo_rdempty_delay[0] <= ~input_empty;
	//отсекание CRC32-суммы в хвосте Ethernet-фрейма от данных
	if (input_info_valid_read) begin 
		input_last_4_bytes[0][7:0] <= input_8bit[7:0];
		for (i = 0; i < 3; i = i + 1) begin
			input_last_4_bytes[i+1][7:0] <= input_last_4_bytes[i][7:0];
		end
	end
end

//==========ETHERNET=HEADER==============================

wire flag_is_input_ARP;
wire flag_is_input_IP;
wire flag_for_mac_write;

wire mac_wren, ip_wren_ip_1, ip_wren_ip_2, ip_wren_partial_1, ip_wren_partial_2, port_wren;
assign mac_wren = preambula_ended & flag_for_mac_write;

headerCutter hc( //parse Ethernet-header
	.datain(input_data),
	.data_en(preambula_ended),
	.clock(clk_12_5),
	.mac_wren(flag_for_mac_write),
	.isIp(flag_is_input_IP),
	.isARP(flag_is_input_ARP),
	.isNotAValidPacket(local_reset_signal_2),
	.sclr(local_reset_summary)
);

//==================ARP=REQUEST==========================

wire [31:0] input_BOARD_IP, input_PC_IP;
//wire flag_is_input_IP_valid;

arp_parser ap(
	.clock(clk_12_5),
	.data_en(flag_is_input_ARP),
	.sclr(local_reset_summary),
	.data(input_data),
	.ip_wren(ip_wren_partial_1),
	.ip_wren2(ip_wren_partial_2)
);

//===================IP=HEADER===========================

wire flag_is_IP_frame_valid;

ipHeader ih(
	.isIp(flag_is_input_IP),
	.datain(input_data),
	.ip_wren_1(ip_wren_ip_1),
	.ip_wren_2(ip_wren_ip_2),
	.clock(clk_12_5),
	.isNotAValidPacket(local_reset_signal_4),
	.dataen(flag_is_IP_frame_valid),
	.sclr(local_reset_summary)
);

//===================UDP=HEADER==========================

wire [15:0] input_BOARD_PORT, input_PC_PORT;
wire flag_is_input_PORT_valid;

assign port_wren = flag_for_port_write & flag_is_IP_frame_valid;

udpHeader uh(
	.clock(clk_12_5),
	.datain(input_data),
	.data_en(flag_is_IP_frame_valid),
	.dataen(flag_is_input_PORT_valid),
	.port_wren(flag_for_port_write),
	.sclr(local_reset_summary)
);

//===================OUR=HEADER==========================

wire flag_is_input_data_type_one, flag_is_input_data_type_two;

ourHeader oh(
	.datain(input_data),
	.clock(clk_12_5),
	.ena(flag_is_input_PORT_valid),
	.sclr(local_reset_summary),
	.is_type_1(flag_is_input_data_type_one),
	.is_type_2(flag_is_input_data_type_two)
);

//============OUR=DATA=IN=UDP=PACKADGE===================

ourDataTypeOne odto(
	.datain(input_data),
	.clock(clk_12_5),
	.ena(flag_is_input_data_type_one),
	.sclr(local_reset_summary),
	.wren(data_type_one_wren),
	.data(data_type_one),
	.header_ena(header_parsed_valid)
);

//======VALID=UDP-IP=DATA=STORAGE=ABOUT=CONNECTION=======

/////////////////////////////////////////////////////////
//////////////////ВОТ ДО СЮДА ОКЕЙ///////////////////////
/////////////////////////////////////////////////////////
reg [4:0] mem_24_in_ADRESS, mem_24_prove_ADRESS_rd;
reg mac_prove, ip_prove, port_prove;
wire mac_proven, ip_proven, port_proven;

reg [4:0] mem_24_sync_ADRESS;
wire [7:0] mem_24_sync_data;
reg [1:0] state;

always @(posedge clk_12_5) begin
	if (local_reset_summary) begin
		mac_prove <= 0;
		ip_prove <= 0;
		port_prove <= 0;
	end else
	if (mac_wren) begin
		mem_24_in_ADRESS <= mem_24_in_ADRESS + 1'b1;
		mac_prove <= 1;
	end else
	if (ip_wren_ip_1 || ip_wren_ip_2 || ip_wren_partial_1 || ip_wren_partial_2) begin
		mem_24_in_ADRESS <= mem_24_in_ADRESS + 1'b1;
		ip_prove <= 1;
	end else
	if (port_wren) begin
		mem_24_in_ADRESS <= mem_24_in_ADRESS + 1'b1;
		port_prove <= 1;
	end else
	if (!preambula_ended) begin
		mem_24_in_ADRESS <= 0;
	end
end

Eth_RAM_holder mem_24_in(
  .clka(clk_12_5),
  .ena(input_info_valid_read),
  .wea(mac_wren | ip_wren_ip_1 | ip_wren_ip_2 | ip_wren_partial_1 | ip_wren_partial_2 | port_wren),
  .addra(mem_24_in_ADRESS),
  .dina(input_data),
  .clkb(TX_CLK),
  .enb((state == 0)),
  .addrb(mem_24_sync_ADRESS),
  .doutb(mem_24_sync_data)
);

assign mem_24_prove_ADRESS = (preambula_ended) ? (mem_24_in_ADRESS) : (mem_24_prove_ADRESS_rd);

wire [7:0] data_24_prove;
reg mem_24_sync_wren;

Eth_RAM_holder mem_24_prove(
  .clka(TX_CLK),
  .ena((state == 0)),
  .wea(mem_24_sync_wren),
  .addra(mem_24_sync_ADRESS),
  .dina(mem_24_sync_data),
  .clkb(TX_CLK),
  .enb((state != 0)),
  .addrb(mem_24_prove_ADRESS),
  .doutb(data_24_prove)
);

reg [7:0] data_ft;
reg wren_ft;
wire norm;
//reg local_reset_signal_5;
reg flagged_norm_ft;
assign norm = 	(data_ft == 8'hFF) || 
				(
					flagged_norm_ft
				) || 
				(data_ft == data_24_prove);

always @(posedge clk_12_5) begin
	data_ft <= input_data;
	wren_ft <= mac_wren | ip_wren_ip_1 | ip_wren_ip_2 | ip_wren_partial_1 | ip_wren_partial_2 | port_wren;
	flagged_norm_ft <= (!mac_proven && mac_wren) || 
					(	(!ip_proven_pc && (ip_wren_partial_1 || ip_wren_ip_1)) ||
						(!ip_proven_board && (ip_wren_partial_2 || ip_wren_ip_2))
					) || 
					(!port_proven && port_wren);
	if (local_reset_summary) begin
		local_reset_signal_5 <= 0;
	end else
	if (wren_ft) begin
		local_reset_signal_5 <= (!norm) || (flag_is_input_IP & (!mac_proven)) ;
	end else begin
		local_reset_signal_5 <= 0;
	end
end

//=============ANSWER=ORDER=SOLVER=======================

wire tx_ena [1:0];
reg TX_EN_res;
wire [3:0] tx_d [1:0];
reg [3:0] TX_D_res;

assign TX_EN = TX_EN_res;
assign TX_D = TX_D_res;

reg [7:0] in_state_counter;
reg arp_request;

reg ram_arp_wren;
reg [5:0] ram_arp_wr_adress;
wire [7:0] ram_arp_wr_data;

assign ram_arp_wr_data = data_24_prove;

reg ram_udp_wren;
reg [5:0] ram_udp_wr_adress;
wire [7:0] ram_udp_wr_data;

assign ram_udp_wr_data = data_24_prove;

reg mac_proven_pc, mac_proven_board, ip_proven_pc, ip_proven_board, port_proven_pc, port_proven_board;

assign mac_proven = mac_proven_pc & mac_proven_board;
assign ip_proven = ip_proven_pc & ip_proven_board;
assign port_proven = port_proven_pc & port_proven_board;

reg arp_eth_mac_set, arp_body_1_set, arp_body_2_set, arp_body_3_set, arp_body_4_set, udp_eth_mac_set, udp_ip_ip_set, udp_port_set;

reg module_ena [1:0];
reg request_for_udp;

always @(posedge TX_CLK) begin
	if (global_reset_summary) begin
		mac_proven_pc <= 0;
		ip_proven_pc <= 0;
		port_proven_pc <= 0;
		
		mac_proven_board <= 1;
		ip_proven_board <= 0;
		port_proven_board <= 0;
		
		// 24: BOARD_MAC, PC_MAC , PC_IP , BOARD_IP , PC_PORT , BOARD_PORT
		
		arp_eth_mac_set <= 0;
		arp_body_1_set <= 0;
		arp_body_2_set <= 0;
		arp_body_3_set <= 0;
		arp_body_4_set <= 0;
		udp_eth_mac_set <= 0;
		udp_ip_ip_set <= 0;
		udp_port_set <= 0;
		ram_arp_wren <= 0;
		
		module_ena[0] <= 0;
		module_ena[1] <= 0;
		TX_D_res <= 0;
		TX_EN_res <= 0;
		request_for_udp <= 0;
		
		state <= 0;
	end else begin 
		if (local_reset_summary) begin
			arp_request <= 0;
		end else begin 
			if (request_for_udp) begin
				if (!tx_ena[1]) in_state_counter <= in_state_counter + 1'b1;
				else module_ena[1] <= 0;
				TX_EN_res <= tx_ena[1];
				TX_D_res <= tx_d[1][3:0];
				case (in_state_counter)
					0: if (!tx_ena[1]) module_ena[1] <= 1;
					255: request_for_udp <= 0;
				endcase
			end else if (preambula_ended) begin 
				if (flag_is_input_ARP) begin
					arp_request <= 1;
				end
			end else begin
				case (state)
					0 : //check income 24
						begin
							if ( 	(	((mac_prove && mac_proven) || (!mac_prove)) &&
										((ip_prove && ip_proven) || (!ip_prove)) &&
										((port_prove && port_proven) || (!port_prove))
									) ||
									(mac_proven && ip_proven && port_proven)) begin
								state <= state + 1'b1;
								request_for_udp <= is_there_256_1 & is_there_256_2;
								in_state_counter <= 0;
							end else if (!preambula_ended) begin
								in_state_counter[0] <= ~in_state_counter[0];
								//mem_24_sync_wren <= ~in_state_counter[0];
								
								
								
								mem_24_sync_wren <=
													(~( 
														((mem_24_sync_ADRESS < 6) & (mac_proven_board)) ||
														((mem_24_sync_ADRESS > 5) & (mem_24_sync_ADRESS < 12) & (mac_proven_pc)) ||
														((mem_24_sync_ADRESS > 11) & (mem_24_sync_ADRESS < 16) & (ip_proven_pc)) ||
														((mem_24_sync_ADRESS > 15) & (mem_24_sync_ADRESS < 20) & (ip_proven_board)) ||
														((mem_24_sync_ADRESS > 19) & (mem_24_sync_ADRESS < 22) & (port_proven_pc)) ||
														((mem_24_sync_ADRESS > 21) & (mem_24_sync_ADRESS < 24) & (port_proven_board))
													)) &
													(~in_state_counter[0]);
								if (in_state_counter[0]) begin
									mem_24_sync_ADRESS <= mem_24_sync_ADRESS + 1'b1;
									case (mem_24_sync_ADRESS)
										6: mac_proven_board <= 1;
										12: mac_proven_pc <= 1;
										16: ip_proven_pc <= 1;
										20:	ip_proven_board <= 1;
										22: port_proven_pc <= 1;
										24: port_proven_board <= 1;
										//12: mac_proven <= mac_prove;
										//20: ip_proven <= ip_prove;
										//24: port_proven <= port_prove;
									endcase
								end
							end
						end
					1 : //rewrite ARP/UDP if updated
						begin
							if ((arp_eth_mac_set || !mac_proven) &&
								(arp_body_1_set || !mac_proven_board) &&
								(arp_body_2_set || !ip_proven_board) &&
								(arp_body_3_set || !mac_proven_pc) &&
								(arp_body_4_set || !ip_proven_pc) &&
								(udp_eth_mac_set || !mac_proven) &&
								(udp_ip_ip_set || !ip_proven) &&
								(udp_port_set || !port_proven)
								) begin
								state <= state + 1'b1;
								request_for_udp <= is_there_256_1 & is_there_256_2;
							end else begin
								if (!arp_eth_mac_set) begin
									case (in_state_counter)
										0:
											begin
												mem_24_prove_ADRESS_rd <= 6;
												in_state_counter <= in_state_counter + 1'b1;
											end
										1:
											begin
												ram_arp_wr_adress <= 0;
												mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
												ram_arp_wren <= 1;
												in_state_counter <= in_state_counter + 1'b1;
											end
										2:
											begin
												if (mem_24_prove_ADRESS_rd < 12) begin
													mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
													ram_arp_wr_adress <= ram_arp_wr_adress + 1'b1;
												end else begin
													ram_arp_wren <= 0;
													in_state_counter <= in_state_counter + 1'b1;
												end
											end
										3:
											begin
												mem_24_prove_ADRESS_rd <= 0;
												in_state_counter <= in_state_counter + 1'b1;
											end
										4:
											begin
												ram_arp_wr_adress <= 6;
												mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
												ram_arp_wren <= 1;
												in_state_counter <= in_state_counter + 1'b1;
											end
										5:
											begin
												if (mem_24_prove_ADRESS_rd < 6) begin
													mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
													ram_arp_wr_adress <= ram_arp_wr_adress + 1'b1;
												end else begin
													ram_arp_wren <= 0;
													in_state_counter <= 0;
													arp_eth_mac_set <= 1;
												end
											end
									endcase
								end else if (!arp_body_1_set) begin
									case (in_state_counter)
										0:
											begin
												mem_24_prove_ADRESS_rd <= 0;
												in_state_counter <= in_state_counter + 1'b1;
											end
										1:
											begin
												ram_arp_wr_adress <= 22;
												mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
												ram_arp_wren <= 1;
												in_state_counter <= in_state_counter + 1'b1;
											end
										2:
											begin
												if (mem_24_prove_ADRESS_rd < 6) begin
													mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
													ram_arp_wr_adress <= ram_arp_wr_adress + 1'b1;
												end else begin
													ram_arp_wren <= 0;
													in_state_counter <= 0;
													arp_body_1_set <= 1;
												end
											end
									endcase
								end else if (!arp_body_2_set) begin
									case (in_state_counter)
										0:
											begin
												mem_24_prove_ADRESS_rd <= 16;
												in_state_counter <= in_state_counter + 1'b1;
											end
										1:
											begin
												ram_arp_wr_adress <= 28;
												mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
												ram_arp_wren <= 1;
												in_state_counter <= in_state_counter + 1'b1;
											end
										2:
											begin
												if (mem_24_prove_ADRESS_rd < 20) begin
													mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
													ram_arp_wr_adress <= ram_arp_wr_adress + 1'b1;
												end else begin
													ram_arp_wren <= 0;
													in_state_counter <= 0;
													arp_body_2_set <= 1;
												end
											end
									endcase
								end else if (!arp_body_3_set) begin
									case (in_state_counter)
										0:
											begin
												mem_24_prove_ADRESS_rd <= 6;
												in_state_counter <= in_state_counter + 1'b1;
											end
										1:
											begin
												ram_arp_wr_adress <= 32;
												mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
												ram_arp_wren <= 1;
												in_state_counter <= in_state_counter + 1'b1;
											end
										2:
											begin
												if (mem_24_prove_ADRESS_rd < 12) begin
													mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
													ram_arp_wr_adress <= ram_arp_wr_adress + 1'b1;
												end else begin
													ram_arp_wren <= 0;
													in_state_counter <= 0;
													arp_body_3_set <= 1;
												end
											end
									endcase
								end else if (!arp_body_4_set) begin
									case (in_state_counter)
										0:
											begin
												mem_24_prove_ADRESS_rd <= 12;
												in_state_counter <= in_state_counter + 1'b1;
											end
										1:
											begin
												ram_arp_wr_adress <= 38;
												mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
												ram_arp_wren <= 1;
												in_state_counter <= in_state_counter + 1'b1;
											end
										2:
											begin
												if (mem_24_prove_ADRESS_rd < 16) begin
													mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
													ram_arp_wr_adress <= ram_arp_wr_adress + 1'b1;
												end else begin
													ram_arp_wren <= 0;
													in_state_counter <= 0;
													arp_body_4_set <= 1;
												end
											end
									endcase
								end else if (!udp_eth_mac_set) begin
									case (in_state_counter)
										0:
											begin
												mem_24_prove_ADRESS_rd <= 6;
												in_state_counter <= in_state_counter + 1'b1;
											end
										1:
											begin
												ram_udp_wr_adress <= 0;
												mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
												ram_udp_wren <= 1;
												in_state_counter <= in_state_counter + 1'b1;
											end
										2:
											begin
												if (mem_24_prove_ADRESS_rd < 12) begin
													mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
													ram_udp_wr_adress <= ram_udp_wr_adress + 1'b1;
												end else begin
													ram_udp_wren <= 0;
													in_state_counter <= in_state_counter + 1'b1;
												end
											end
										3:
											begin
												mem_24_prove_ADRESS_rd <= 0;
												in_state_counter <= in_state_counter + 1'b1;
											end
										4:
											begin
												ram_udp_wr_adress <= 6;
												mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
												ram_udp_wren <= 1;
												in_state_counter <= in_state_counter + 1'b1;
											end
										5:
											begin
												if (mem_24_prove_ADRESS_rd < 6) begin
													mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
													ram_udp_wr_adress <= ram_udp_wr_adress + 1'b1;
												end else begin
													ram_udp_wren <= 0;
													in_state_counter <= 0;
													udp_eth_mac_set <= 1;
												end
											end
									endcase
								end else if (!udp_ip_ip_set) begin
									case (in_state_counter)
										0:
											begin
												mem_24_prove_ADRESS_rd <= 16;
												in_state_counter <= in_state_counter + 1'b1;
											end
										1:
											begin
												ram_udp_wr_adress <= 26;
												mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
												ram_udp_wren <= 1;
												in_state_counter <= in_state_counter + 1'b1;
											end
										2:
											begin
												if (mem_24_prove_ADRESS_rd < 20) begin
													mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
													ram_udp_wr_adress <= ram_udp_wr_adress + 1'b1;
												end else begin
													ram_udp_wren <= 0;
													in_state_counter <= in_state_counter + 1'b1;
												end
											end
										3:
											begin
												mem_24_prove_ADRESS_rd <= 12;
												in_state_counter <= in_state_counter + 1'b1;
											end
										4:
											begin
												ram_udp_wr_adress <= 30;
												mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
												ram_udp_wren <= 1;
												in_state_counter <= in_state_counter + 1'b1;
											end
										5:
											begin
												if (mem_24_prove_ADRESS_rd < 16) begin
													mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
													ram_udp_wr_adress <= ram_udp_wr_adress + 1'b1;
												end else begin
													ram_udp_wren <= 0;
													in_state_counter <= 0;
													udp_ip_ip_set <= 1;
												end
											end
									endcase
								end else if (!udp_port_set) begin
									case (in_state_counter)
										0:
											begin
												mem_24_prove_ADRESS_rd <= 22;
												in_state_counter <= in_state_counter + 1'b1;
											end
										1:
											begin
												ram_udp_wr_adress <= 34;
												mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
												ram_udp_wren <= 1;
												in_state_counter <= in_state_counter + 1'b1;
											end
										2:
											begin
												if (mem_24_prove_ADRESS_rd < 22) begin
													mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
													ram_udp_wr_adress <= ram_udp_wr_adress + 1'b1;
												end else begin
													ram_udp_wren <= 0;
													in_state_counter <= in_state_counter + 1'b1;
												end
											end
										3:
											begin
												mem_24_prove_ADRESS_rd <= 20;
												in_state_counter <= in_state_counter + 1'b1;
											end
										4:
											begin
												ram_udp_wr_adress <= 36;
												mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
												ram_udp_wren <= 1;
												in_state_counter <= in_state_counter + 1'b1;
											end
										5:
											begin
												if (mem_24_prove_ADRESS_rd < 22) begin
													mem_24_prove_ADRESS_rd <= mem_24_prove_ADRESS_rd + 1'b1;
													ram_udp_wr_adress <= ram_udp_wr_adress + 1'b1;
												end else begin
													ram_udp_wren <= 0;
													in_state_counter <= 0;
													udp_port_set <= 1;
												end
											end
									endcase
								end
							end
						end
					2 : //answer ARP if needed
						begin
							if (!arp_request) begin
								state <= state + 1'b1;
								request_for_udp <= is_there_256_1 & is_there_256_2;
							end else begin
								if (!tx_ena[0]) in_state_counter <= in_state_counter + 1'b1;
								else module_ena[0] <= 0;
								TX_EN_res <= tx_ena[0];
								TX_D_res <= tx_d[0][3:0];
								case (in_state_counter)
									0: if (!tx_ena[0]) module_ena[0] <= 1;
									255: arp_request <= 0;
								endcase
							end
						end
					/*3 : //rewrite UDP 120
						begin
							request_for_udp <= is_there_256_1 & is_there_256_2;
							state <= state + 1'b1;
						end*/
					default: state <= state + 1'b1;
					//all: if ended current state, check udp request
				endcase
			end 
		end 
	end
end


/*
reg [7:0] counter_for_solving_answers;

reg is_there_request_for_send [1:0];
reg [1:0] state_of_solving;



always @(negedge TX_CLK) begin
	case(state_of_solving)
		0: 	begin
				is_there_request_for_send[0] <= ~preambula_ended_short & flag_is_input_ARP & ~local_reset_summary;
				is_there_request_for_send[1] <= is_there_256_1 & is_there_256_2;
				state_of_solving <= state_of_solving + 1'b1;
			end
		1:	begin
				is_there_request_for_send[1] <= is_there_256_1 & is_there_256_2;
				if (is_there_request_for_send[0]) begin
					module_ena[0] <= 1;
					is_there_request_for_send[0] <= 0;
					counter_for_solving_answers <= counter_for_solving_answers + 1'b1;
				end else begin
					module_ena[0] <= 0;
					TX_EN_res<=tx_ena[0];
					if (tx_ena[0]) begin
						TX_D_res<=tx_d[0];
					end else begin
						if (counter_for_solving_answers) begin
							counter_for_solving_answers <= counter_for_solving_answers + 1'b1;
						end else begin
							state_of_solving <= state_of_solving + 1'b1;
						end
					end
				end
			end
		2:	begin
				is_there_request_for_send[0] <= ~preambula_ended_short & flag_is_input_ARP & ~local_reset_summary;
				if (is_there_request_for_send[1]) begin
					module_ena[1] <= 1;
					is_there_request_for_send[1] <= 0;
					counter_for_solving_answers <= counter_for_solving_answers + 1'b1;
				end else begin
					module_ena[1] <= 0;
					TX_EN_res<=tx_ena[1];
					if (tx_ena[1]) begin
						TX_D_res<=tx_d[1];
					end else begin
						if (counter_for_solving_answers) begin
							counter_for_solving_answers <= counter_for_solving_answers + 1'b1;
						end else begin
							state_of_solving <= state_of_solving + 1'b1;
						end
					end
				end
			end
		3: 	begin
				state_of_solving <= state_of_solving + 1'b1;
				is_there_request_for_send[0] <= ~preambula_ended_short & flag_is_input_ARP & ~local_reset_summary;
				is_there_request_for_send[1] <= is_there_256_1 & is_there_256_2;//~rdempty1 & ~rdempty2;
			end
	endcase
end*/

/*always @(posedge TX_CLK) begin
	TX_D_res <= tx_d[0];
	TX_EN_res <= tx_ena[0];
	if (!tx_ena[0]) in_state_counter <= in_state_counter + 1'b1;
	case (in_state_counter)
		0: module_ena [0] <= 1;
		1: module_ena [0] <= 0;
	endcase
end*/


//==============ARP=REQUEST=ANSWER=======================

wire [7:0] RAM_ARP;
reg [5:0] RAM_addr_ARP;
wire RAM_RDEN_ARP;



ARPanswerFormer aa(
	.clock(TX_CLK),
	.ena(module_ena[0]),
	.dataout(tx_d[0]),
	.tx_en(tx_ena[0]),
	.sclr(global_reset_summary),
	.RAM_IN(RAM_ARP),
	.RAM_RDEN(RAM_RDEN_ARP)
);

Eth_RAM_ARP mem_arp(
	.clka(TX_CLK),	//STATE ARP WRITER
	.wea(ram_arp_wren),	    //STATE ARP WRITER
	.addra(ram_arp_wr_adress),	//STATE ARP WRITER
	.dina(ram_arp_wr_data),	//STATE ARP WRITER
	.clkb(TX_CLK),
	.addrb(RAM_addr_ARP),
	.doutb(RAM_ARP)
);

always @(negedge TX_CLK) begin
	if (tx_ena[0]) begin
		/*if (RAM_RDEN_ARP) begin
			RAM_addr_ARP <= RAM_addr_ARP + 1'b1;
		end*/
		RAM_addr_ARP <= RAM_addr_ARP + RAM_RDEN_ARP;
	end else begin
		RAM_addr_ARP <= 0;
	end
end

//=============ADC=DATA=REPORT===========================


wire [7:0] RAM_UDP;
reg [5:0] RAM_addr_UDP;
wire RAM_RDEN_UDP;

//wire [5:0] ram_udp_b_adress;
//
//assign ram_udp_b_adress = (state == 1) ? ram_udp_wr_adress : RAM_addr_UDP;

messagePartialReporter mpr(
	.clock(TX_CLK),
	.data_blocks1(data_blocks1),
	.data_blocks2(data_blocks2),
	.is_there_256_1(is_there_256_1),
	.is_there_256_2(is_there_256_2),
	.sclr(global_reset_summary),
	//.RAW_STATIC_DATA(RAW_STATIC_DATA),
	.ena(module_ena[1]),
	
	.dataout(tx_d[1]),
	.tx_en(tx_ena[1]),
	.rdreq1(rdreq1),
	.rdreq2(rdreq2),
	
	.RAM_IN(RAM_UDP),
	.RAM_RDEN(RAM_RDEN_UDP)
);

Eth_RAM_udp mem_udp(
	.clka(TX_CLK),	//STATE UDP WRITER(s)
	.wea(ram_udp_wren),     //STATE UDP WRITER(s)
	.addra(ram_udp_wr_adress),   //STATE UDP WRITER(s)
	.dina(ram_udp_wr_data),    //STATE UDP WRITER(s)
	.clkb(TX_CLK),
	.addrb(RAM_addr_UDP),
	.doutb(RAM_UDP)
);

always @(negedge TX_CLK) begin
	if (tx_ena[1]) begin
		/*if (RAM_RDEN_UDP) begin
			RAM_addr_UDP <= RAM_addr_UDP + 1'b1;
		end*/
		RAM_addr_UDP <= RAM_addr_UDP + RAM_RDEN_UDP;
	end else begin
		RAM_addr_UDP <= 0;
	end
end

//=======================================================

//CRC Check if needed
//no check rn



endmodule
