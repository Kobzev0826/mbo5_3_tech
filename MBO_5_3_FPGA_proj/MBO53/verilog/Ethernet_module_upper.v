module Ethernet_module_upper #(
parameter CONST_BOARD_IP = {8'd192,8'd168,8'd0,8'd113},
parameter CONST_BOARD_MAC = {24'h902b34,24'h0D0EE6}
)(
input [3:0] RX_D,
input RX_DV,
input RX_CLK,

output [3:0] TX_D,
output TX_EN,
output TX_CLK,

input clk_main,
input clk_25,
input clk_12_5,

input reset_global_in_1,
input reset_global_in_2,

input [15:0] data_blocks1,
input [15:0] data_blocks2,
input rdempty1,
input rdempty2,
input is_there_256_1,
input is_there_256_2,
input [991:0] RAW_STATIC_DATA,
output rdreq1,
output rdreq2

);


localparam DATA_VALIDATION_PROLONGING = 4'd4;
localparam PREAMBULA_LENGTH_TO_SKIP = 4'd13;

integer i;

wire local_reset_signal_3;
wire [16:0] doll_ground;
wire local_reset_summary, global_reset_summary;

wire [7:0] input_8bit_init;
wire input_8bit_init_ena;
wire local_reset_signal_1;

wire input_empty, input_rd_req;
wire [7:0] input_8bit;

reg [15:0] input_fifo_rdempty_delay;//задержка для выхода фифо ( 8 тактов буффер в фифо)

/*genvar k;
generate
for (k = 0; k < 4; k = k + 1) begin : gen
	reg [7:0] input_last_4_bytes;
end
endgenerate*/

reg [7:0] input_last_4_bytes [3:0];

wire input_info_valid_read;

wire [7:0] input_data;

//reg [3:0] counter_for_skipping_preambula, 
reg [3:0] counter_for_prolonging_data_validation;
(*mark_debug = "true"*)reg preambula_ended, preambula_ended_short;

wire [47:0] input_BOARD_MAC, input_PC_MAC;
(*mark_debug = "true"*)wire flag_is_input_ARP;
wire flag_is_input_IP;
wire local_reset_signal_2;

wire [47:0] BOARD_MAC, PC_MAC;
wire [31:0] BOARD_IP, PC_IP;
wire [15:0] BOARD_PORT, PC_PORT;

wire [31:0] input_BOARD_IP, input_PC_IP;
wire flag_is_input_IP_valid;

wire [15:0] input_BOARD_PORT, input_PC_PORT;
wire flag_is_input_PORT_valid;

wire local_reset_signal_4;

wire flag_is_IP_frame_valid;

assign input_info_valid_read = input_fifo_rdempty_delay[0] & input_fifo_rdempty_delay[15];
assign input_rd_req = input_info_valid_read;
assign input_data = input_last_4_bytes[3][7:0];

assign local_reset_summary = global_reset_summary | local_reset_signal_1 | local_reset_signal_2 | local_reset_signal_3 | local_reset_signal_4; 
assign global_reset_summary = 0;//reset_global_in_1 | reset_global_in_2;

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

udpHeader uh(
	.clock(clk_12_5),
	.datain(input_data),
	.data_en(flag_is_IP_frame_valid),
	.dataen(flag_is_input_PORT_valid),
	.PC_PORT(input_PC_PORT),
	.BOARD_PORT(input_BOARD_PORT),
	.sclr(local_reset_summary)
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
	.clock(clk_25),
	
	.BOARD_MAC(BOARD_MAC),
	.BOARD_IP(BOARD_IP),
	.BOARD_PORT(BOARD_PORT),
	.PC_MAC(PC_MAC),
	.PC_IP(PC_IP),
	.PC_PORT(PC_PORT),
	.isNotAValidPacket(local_reset_signal_3)
);

(*mark_debug="true"*) 
ARPanswerFormer aa(
	.clock(clk_25),
	.BOARD_MAC(BOARD_MAC),
	.BOARD_IP(BOARD_IP),
	.PC_MAC(PC_MAC),
	.PC_IP(PC_IP),
	.ena(~preambula_ended & flag_is_input_ARP),
	.dataout(TX_D),
	.tx_en(TX_EN),
	.sclr(local_reset_summary)
);


always @(posedge clk_12_5) begin
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



always @(negedge clk_12_5) begin
	if (input_info_valid_read) begin
		/*counter_for_skipping_preambula <= counter_for_skipping_preambula + 1;
		if (counter_for_skipping_preambula == PREAMBULA_LENGTH_TO_SKIP) begin
			preambula_ended <= 1;
		end else begin
			//nothing
		end*/
		if (input_last_4_bytes[3][7:0] == 8'hD5) begin 
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
