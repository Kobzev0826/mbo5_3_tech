module Ethernet_module_upper #(
parameter CONST_BOARD_IP = {8'd192,8'd168,8'd0,8'd113},
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
input [991:0] RAW_STATIC_DATA, //данные заголовка отправляемого пакета
output rdreq1, //запрос данных АЦП
output rdreq2,

output [991:0] header_parsed, //данные заголовка получаемого пакета
output header_parsed_valid,   // ... и их валидность

output [15:0] data_type_one, //данные тела пакета типа 1
output data_type_one_wren	 // ... и их валидность

);

integer i;

wire local_reset_signal_1, local_reset_signal_2, local_reset_signal_3, local_reset_signal_4;
wire local_reset_summary, global_reset_summary;

assign local_reset_summary = global_reset_summary | local_reset_signal_1 | local_reset_signal_2 | local_reset_signal_3 | local_reset_signal_4; 
assign global_reset_summary = reset_global_in_1 | reset_global_in_2 | reset_global_in_3;






localparam DATA_VALIDATION_PROLONGING = 4'd4; 

wire [7:0] input_8bit_init;
wire input_8bit_init_ena;

wire input_empty, input_rd_req;
wire [7:0] input_8bit;

reg [15:0] input_fifo_rdempty_delay;//задержка для выхода фифо ( 16 тактов буффер в фифо)


reg [7:0] input_last_4_bytes [3:0];

wire input_info_valid_read;

wire [7:0] input_data;

//reg [3:0] counter_for_skipping_preambula, 
reg [3:0] counter_for_prolonging_data_validation;
(*mark_debug = "true"*)reg preambula_ended, preambula_ended_short;

wire [47:0] input_BOARD_MAC, input_PC_MAC;
(*mark_debug = "true"*)wire flag_is_input_ARP;
wire flag_is_input_IP;

wire [47:0] BOARD_MAC, PC_MAC;
wire [31:0] BOARD_IP, PC_IP;
wire [15:0] BOARD_PORT, PC_PORT;

wire [31:0] input_BOARD_IP, input_PC_IP;
wire flag_is_input_IP_valid;

wire [15:0] input_BOARD_PORT, input_PC_PORT;
wire flag_is_input_PORT_valid;

wire flag_is_IP_frame_valid;

wire flag_is_input_data_type_one, flag_is_input_data_type_two;

assign input_info_valid_read = input_fifo_rdempty_delay[0] & input_fifo_rdempty_delay[15];
assign input_rd_req = input_info_valid_read;
assign input_data = input_last_4_bytes[3][7:0];

//assign local_reset_processing = global_reset_summary | 1'b0;
//assign TX_CLK = ~clk_25;

//wire clk_out = ~TX_CLK;
/*
fifo_doll doll_fifo(
	.clk(RX_DV),
	.srst(1'b0),
	.din({4{RX_D}}),
	.wr_en(RX_DV),
	.rd_en(reset_global_in_1),
	.dout(doll_ground),
	.full(),
	.empty(doll_ground[16])
);
*/

(*keep_hierarchy="yes"*) 
FourToEight fte( //module that translates 25Mhz 4bit Ethernet wire input
				//into 12.5 mhz 8bit format with 25MHz enable signal for
			   //writing into FIFO by 25 MHz clock to switch clock domain
	.clock(RX_CLK),
	.datain(RX_D),
	.ena(RX_DV),
	.dataout(input_8bit_init),
	.ren(input_8bit_init_ena),
	.error_pzdc(local_reset_signal_1)
);

(*keep_hierarchy="yes"*) 
fifo_25_12_5 fifo_input(
	.rst(local_reset_summary),
	.wr_clk(~RX_CLK),
	.rd_clk(clk_12_5),
	.din(input_8bit_init),
	.wr_en(input_8bit_init_ena),
	.rd_en(input_rd_req),
	.dout(input_8bit),
	.full(),
	.empty(input_empty),
	.rd_data_count()
);

//(*mark_debug = "true"*) wire [15:0] packetID_out;
(*keep_hierarchy="yes"*) 
headerCutter hc( //parse Ethernet-header
	.datain(input_data),
	.data_en(preambula_ended),
	.clock(clk_12_5),
	.BOARD_MAC(input_BOARD_MAC),
	.PC_MAC(input_PC_MAC),
	.isIp(flag_is_input_IP),
	.isARP(flag_is_input_ARP),
	.isNotAValidPacket(local_reset_signal_2),
	.sclr(local_reset_summary)//,
	//.packetID_out(packetID_out)
);

(*mark_debug="true"*) 
arp_parser ap(
	.clock(clk_12_5),
	.data_en(flag_is_input_ARP),
	.sclr(local_reset_summary),
	.data(input_data),
	.PC_IP(input_PC_IP),
	.BOARD_IP(input_BOARD_IP),
	.dataen(flag_is_input_IP_valid)
);

(*keep_hierarchy="yes"*) 
ipHeader ih(
	.isIp(flag_is_input_IP),
	.datain(input_data),
	.PC_IP(PC_IP),
	.BOARD_IP(BOARD_IP),
	.clock(clk_12_5),
	.isNotAValidPacket(local_reset_signal_4),
	.dataen(flag_is_IP_frame_valid),
	.sclr(local_reset_summary)
);

(*keep_hierarchy="yes"*) 
udpHeader uh(
	.clock(clk_12_5),
	.datain(input_data),
	.data_en(flag_is_IP_frame_valid),
	.dataen(flag_is_input_PORT_valid),
	.PC_PORT(input_PC_PORT),
	.BOARD_PORT(input_BOARD_PORT),
	.sclr(local_reset_summary)
);


//wire [15:0] data_type_one;
//wire data_type_one_wren;
//wire [31:0] header_parsed[31];

ourHeader oh(
	.datain(input_data),
	.clock(clk_12_5),
	.ena(flag_is_input_PORT_valid),
	.sclr(local_reset_summary),
	.is_type_1(flag_is_input_data_type_one),
	.is_type_2(flag_is_input_data_type_two)
);

ourDataTypeOne odto(
	.datain(input_data),
	.clock(clk_12_5),
	.ena(flag_is_input_data_type_one),
	.sclr(local_reset_summary),
	.wren(data_type_one_wren),
	.data(data_type_one),
	.o_header(header_parsed),
	.header_ena(header_parsed_valid)
);

(*keep_hierarchy="yes"*) 
dataHolder dh(
	.VERIFIED_IP(CONST_BOARD_IP),
	.VERIFIED_MAC(CONST_BOARD_MAC),
	.is_ip_verified(1'b1),
	.is_mac_verified(1'b1),
	.input_BOARD_MAC(input_BOARD_MAC),
	.input_BOARD_IP(input_BOARD_IP),
	.input_BOARD_PORT(input_BOARD_PORT),
	.input_PC_MAC(input_PC_MAC),
	.input_PC_IP(input_PC_IP),
	.input_PC_PORT(input_PC_PORT),
	.input_mac_verified(flag_is_input_IP | flag_is_input_ARP),
	.input_ip_verified(flag_is_input_IP_valid),
	.input_port_verified(flag_is_input_PORT_valid),
	.input_in_process(preambula_ended_short),
	.aclr(global_reset_summary),
	.clock(clk_main),
	
	.BOARD_MAC(BOARD_MAC),
	.BOARD_IP(BOARD_IP),
	.BOARD_PORT(BOARD_PORT),
	.PC_MAC(PC_MAC),
	.PC_IP(PC_IP),
	.PC_PORT(PC_PORT),
	.isNotAValidPacket(local_reset_signal_3)
);

wire tx_ena [1:0];
reg TX_EN_res;
wire [3:0] tx_d [1:0];
reg [3:0] TX_D_res;

reg [7:0] counter_for_solving_answers;
//reg was_there_a_send;
//reg [6:0] in_between_delay;
reg module_ena [1:0];
reg is_there_request_for_send [1:0];
reg [1:0] state_of_solving;

assign TX_EN = TX_EN_res;
assign TX_D = TX_D_res;

always @(negedge TX_CLK) begin
	case(state_of_solving)
		0: 	begin
				is_there_request_for_send[0] <= ~preambula_ended_short & flag_is_input_ARP & ~local_reset_summary;
				is_there_request_for_send[1] <= is_there_256_1 & is_there_256_2;//~rdempty1 & ~rdempty2;
				state_of_solving <= state_of_solving + 1'b1;
				//counter_for_solving_answers <= counter_for_solving_answers + 1'b1;
			end
		1:	begin
				is_there_request_for_send[1] <= is_there_256_1 & is_there_256_2;//~rdempty1 & ~rdempty2;
				if (is_there_request_for_send[0]) begin
					module_ena[0] <= 1;
					is_there_request_for_send[0] <= 0;
					counter_for_solving_answers <= counter_for_solving_answers + 1'b1;
				end else begin
					module_ena[0] <= 0;
					TX_EN_res<=tx_ena[0];
					if (tx_ena[0]) begin
						TX_D_res<=tx_d[0];
						//counter_for_solving_answers <= counter_for_solving_answers + 1'b1;
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
						//counter_for_solving_answers <= counter_for_solving_answers + 1'b1;
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
end


(*mark_debug="true"*) 
(*keep_hierarchy="yes"*) 
ARPanswerFormer aa(
	.clock(TX_CLK),
	.BOARD_MAC(BOARD_MAC),
	.BOARD_IP(BOARD_IP),
	.PC_MAC(PC_MAC),
	.PC_IP(PC_IP),
	.ena(module_ena[0]),
	.dataout(tx_d[0]),
	.tx_en(tx_ena[0]),
	.sclr(global_reset_summary)
);

(*keep_hierarchy="yes"*) 
messagePartialReporter mpr(
	.clock(TX_CLK),
	.BOARD_MAC(BOARD_MAC),
	.BOARD_IP(BOARD_IP),
	.BOARD_PORT(BOARD_PORT),
	.PC_MAC(PC_MAC),
	.PC_IP(PC_IP),
	.PC_PORT(PC_PORT),
	.data_blocks1(data_blocks1),
	.data_blocks2(data_blocks2),
	//.rdempty1(rdempty1),
	//.rdempty2(rdempty2),
	.is_there_256_1(is_there_256_1),
	.is_there_256_2(is_there_256_2),//is_there_256_2),
	.sclr(global_reset_summary),
	.RAW_STATIC_DATA(RAW_STATIC_DATA),
	.ena(module_ena[1]),
	
	.dataout(tx_d[1]),
	.tx_en(tx_ena[1]),
	.rdreq1(rdreq1),
	.rdreq2(rdreq2)
);


always @(negedge clk_12_5) begin
	for (i = 0; i < 15; i = i + 1) begin
		input_fifo_rdempty_delay[i+1]<=input_fifo_rdempty_delay[i];
	end
	input_fifo_rdempty_delay[0]<=~input_empty;
	//отсекание CRC32-суммы в хвосте Ethernet-фрейма от данных
	if (input_info_valid_read) begin 
		input_last_4_bytes[0][7:0]<=input_8bit[7:0];
		for (i = 0; i < 3; i = i + 1) begin
			input_last_4_bytes[i+1][7:0]<=input_last_4_bytes[i][7:0];
		end
	end
	/*if (input_info_valid_read)begin 
		if ( input_8bit == 8'b 1101_0101) preambula_ended <= 1;
	else begin 
		if (preambula_ended) preambula_ended <= 0;
	end*/
end



//CRC Check if needed
//no check rn



always @(posedge clk_12_5) begin
	if (input_info_valid_read) begin
		/*counter_for_skipping_preambula <= counter_for_skipping_preambula + 1;
		if (counter_for_skipping_preambula == PREAMBULA_LENGTH_TO_SKIP) begin
			preambula_ended <= 1;
		end else begin
			//nothing
		end*/
		if (input_data == 8'hD5) begin 
			preambula_ended<=1;
			preambula_ended_short<=1;
		end
	end else begin
		if (preambula_ended) begin
			if (counter_for_prolonging_data_validation == DATA_VALIDATION_PROLONGING) begin
				preambula_ended<=0;
			end else begin
				//nothing
			end
			counter_for_prolonging_data_validation <= counter_for_prolonging_data_validation + 1;
		end else begin
			counter_for_prolonging_data_validation <= 0;
		end
		preambula_ended_short<=0;
		//counter_for_skipping_preambula <= 0;
	end
end


endmodule
