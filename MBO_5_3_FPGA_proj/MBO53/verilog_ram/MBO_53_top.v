`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:10:06 11/29/2021 
// Design Name: 
// Module Name:    MBO_53_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module MBO_53_top(
input clk,

input BTN_WEST,
input BTN_NORTH,
//---------ETHERNET PHY----------
output [3:0] e_tx_d,
output e_tx_en,
output e_tx_er,
input  e_tx_clk,

input [3:0] e_rx_d,
input e_rx_er,
input e_rx_dv,
input e_rx_clk,

/*input e_crc,
input e_col,
output e_mdc,
inout e_mdio,*/

//-------ADC_01----------
input adc_01_sdo,
output adc_01_sck,
output adc_01_cs,
//-------ADC_02----------
input 	adc_02_sdo,
output 	adc_02_sck,
output 	adc_02_cs,
//----------LED------------
output [7:0] LED//,

//------DAC KIT SPARTAN----
/*
output SPI_MOSI,
output DAC_CS, 
output SPI_SCK, 
output DAC_CLR,
input SPI_MISO*/
    );
	
(*mark_debug = "true"*)wire e_tx_clk_bf,BTN_WEST_bf,BTN_NORTH_bf,SPI_MISO_bf,adc_01_sdo_bf,adc_02_sdo_bf;
IBUFG	bf3(.I(adc_01_sdo), .O(adc_01_sdo_bf));
IBUFG	bf4(.I(adc_02_sdo), .O(adc_02_sdo_bf));
IBUFG	bf1(.I(BTN_WEST), 	.O(BTN_WEST_bf));
IBUFG	bf6(.I(BTN_NORTH), 	.O(BTN_NORTH_bf));
IBUFG	bf5(.I(e_tx_clk), 	.O(e_tx_clk_bf));
/*IOBUF (
.O		(rx_mdio),
.IO		(e_mdio),
.I		(tx_mdio),
.T		(mdio_en) //1-tx 0 - rx
);*/
//BUFG	bf2(.I(SPI_MISO), .O(SPI_MISO_bf));
//(*mark_debug="yes"*)wire e_mdio_bf;
//wire emdc;
wire DAC_CS_wire;
wire clk_12, clk_bf_2, locked_2, clk50_double_pll_cross;
reg[11:0] dac_data=12'h000;
reg dac_strob_up=1;
//assign e_mdc = emdc;
assign DAC_CS=DAC_CS_wire;
//assign e_mdio = e_mdio_bf;


	
reg [3:0] e_counter;
reg e_tx_er_reg;

assign e_tx_er=0;
/*
assign e_tx_en = e_counter[3];
assign e_mdc = e_counter[3];
assign e_tx_d [3:0]  =  e_counter[3:0];
//assign e_tx_er = e_tx_er_reg;
always @(posedge clk_bf) begin 
	e_counter <= e_counter +1;
	e_tx_er_reg <= ~e_tx_er_reg;
end
*/

//--------LED settings-------------
reg [7:0] Led_reg;
assign LED = Led_reg;
//wire locked, clk_50, clk_dv;

pll pll_1
(
.CLKIN_IN			(clk), //50MHz
.RST_IN				(1'b0),
.CLKDV_OUT			(clk_dv),//devide 2
.CLKIN_IBUFG_OUT	(clk_bf),
.CLK0_OUT			(clk_50),
.CLK2X_OUT			(clk_2x),
.LOCKED_OUT			(locked)
);



pll_2 pll_2
(
.CLKIN_IN			(clk_50), //50... MHz? ? 
.RST_IN				(~locked), 
.CLKDV_OUT			(clk_12), //12.5 MHz ? 
//.CLKIN_IBUFG_OUT	(clk_bf_2), // ?????????? 
.CLK0_OUT			(clk50_double_pll_cross), //-_- 
.LOCKED_OUT			(locked_2)
);

//------------------CONVOLUTION WIRE and REG------------------------------
(*mark_debug = "true"*)wire [15:0]conv_DATA_OUT_A,conv_DATA_OUT_B;
(*mark_debug = "true"*)wire conv_data_out_en;
wire [15:0] SUB_TA_TB;
(*mark_debug = "true"*)wire SUB_TA_TB_en;
//-------------------------------------------------------------------

//-------------ADC WIRE AND REG------------------------------------------
(*mark_debug = "true"*)wire [15:00] adc_01_data, adc_02_data;
(*mark_debug = "true"*)wire [11:0] adc_01_data_true;
wire adc_01_en;
reg adc_01_cs_f,adc_01_cs_ff, adc_02_cs_f, adc_02_cs_ff;
(*mark_debug = "true"*)reg [3:0] error_counter;
//reg adc_01_start;
assign adc_01_data_true = adc_01_data[11:00];
//-------------------------------------------------------------------


//reg [991:0] RAW_STATIC_DATA; //128 byte - 4byte packet send counter;
(*mark_debug = "true"*)wire eth_rdempty1, eth_rdempty2, eth_rdreq1, eth_rdreq2, is_there_256_1, is_there_256_2;
wire [15:0] eth_data_blocks1, eth_data_blocks2;
wire [15:0] acp_data1, acp_data2;
wire acp_data1_ena, acp_data2_ena;
wire acp_data_clock1, acp_data_clock2;
(*mark_debug = "true"*)wire [8:0] rd_data_count_01,wr_data_count_01,rd_data_count_02,wr_data_count_02;
(*mark_debug = "true"*)wire dac_start;
assign dac_start = adc_01_start;

assign is_there_256_1 = rd_data_count_01[8];
assign is_there_256_2 = rd_data_count_02[8];



assign acp_data1 = {4'b0000,adc_01_data[11:00]};
assign acp_data2 = {4'b0000,adc_02_data[11:00]};
assign acp_data1_ena = adc_01_start;
assign acp_data2_ena = adc_01_start;
assign acp_data_clock1 = adc_01_cs_ff;
assign acp_data_clock2 = adc_02_cs_ff;

wire [991:0] header_parsed;//[31:0] header_parsed [30:0];
wire header_parsed_valid;

wire [15:0] eth_comp_data;
wire eth_comp_data_ena;

(*mark_debug = "true"*)reg BTN_NORTH_f, BTN_NORTH_ff;
reg BTN_NORTH_strob=0;
(*mark_debug = "true"*)reg [31:00]BTN_NORTH_counter;

(*mark_debug = "true"*)reg adc_01_start, BTN_WEST_f, BTN_WEST_ff;
reg BTN_WEST_strob=0;
(*mark_debug = "true"*)reg [31:00]BTN_WEST_counter;
//----INSERT BUTTON SIGNAL-----------------------------------
 
always @(posedge clk_2x) begin 
	BTN_NORTH_f <= BTN_NORTH_bf;
	BTN_NORTH_ff <= BTN_NORTH_f;
	if ( BTN_NORTH_f & (!BTN_NORTH_ff) &(!BTN_NORTH_strob)) begin 
		BTN_NORTH_strob <= 1;
	end
	
	if ( BTN_NORTH_strob & BTN_NORTH_counter == 20_000_000) BTN_NORTH_strob <= 0;
	
	// счетчик сброса сигнала кнопки
	if (BTN_NORTH_strob) BTN_NORTH_counter <= BTN_NORTH_counter +1;
	else BTN_NORTH_counter <= 0;
end

reg [15:0] FIX_POROG = 0;

always @(posedge clk_12) begin //ЗАМЕНИТЬ RAM-переходом!!!
	if (~locked_2) begin
		FIX_POROG <= 0;
	end else if (header_parsed_valid) begin
		FIX_POROG <= header_parsed[991:976];
	end
end

(*mark_debug = "true"*)wire ch_a_extremum_en;
(*mark_debug = "true"*)wire [15:00]CH_A_EXTREMUM;
/*
(*keep_hierarchy="yes"*) 
convolution_top convolution_top(
.clks			(adc_01_en), // 1 MHZ
.clkf			(clk_dv), // 50 MHz уменьшим число умножителей в 50 раз
.clke			(clk_12), // клок эзернета для записи опары из ПК в память блока свертки
.rst			(~locked_2), // глобальный асинхронный сброс

.opora_en		(eth_comp_data_ena), // строб сопровождающий запись опоры в память
.OPORA			(eth_comp_data), // Опора из ПК

.data_in_en		(acp_data1_ena),
.DATA_IN_A		(acp_data1), // данные с АЦП1
.DATA_IN_B		(acp_data2), // данные с АЦП2

.FIX_POROG		(FIX_POROG),
.DATA_OUT_A		(conv_DATA_OUT_A),	//{real, image}
.DATA_OUT_B		(conv_DATA_OUT_B),	//{real, image}

.SUB_TA_TB		(SUB_TA_TB),
.SUB_TA_TB_en	(SUB_TA_TB_en),

.CH_A_EXTREMUM	(CH_A_EXTREMUM),
.ch_a_extremum_en(ch_a_extremum_en)
); */

reg SUB_TA_TB_flag;
reg was_there_a_zero;
/*reg [7:0] counter_for_falsification;
reg SUB_TA_TB_en_falsificied;

always @(posedge clk_12) begin
	counter_for_falsification = counter_for_falsification + 1'b1;
	if (counter_for_falsification)
		SUB_TA_TB_en_falsificied <= 0;
	else
		SUB_TA_TB_en_falsificied <= 1;
end*/

always @(posedge clk_12) begin
	if (SUB_TA_TB_en) begin
		SUB_TA_TB_flag <= 1;
		was_there_a_zero <= ~e_tx_en;
	end else if (was_there_a_zero && eth_rdreq1 && SUB_TA_TB_flag) begin
		SUB_TA_TB_flag <= 0;
	end else if (~was_there_a_zero && SUB_TA_TB_flag && ~e_tx_en) begin
		was_there_a_zero <= 1;
	end
end

wire debug_led_2, debug_led_1, debug_reset;

(*keep_hierarchy="yes"*) 
Ethernet_module_upper ethernet(

.TX_D		(e_tx_d),
.TX_EN      (e_tx_en),
.TX_CLK     (e_tx_clk_bf),
				
.RX_D       (e_rx_d),
.RX_DV      (e_rx_dv),
.RX_CLK     (e_rx_clk),

.clk_main	(clk_2x),
//.clk_25		(clk_dv),
.clk_12_5	(clk_12),

.reset_global_in_1(~locked),
.reset_global_in_2(~locked_2),
.reset_global_in_3(BTN_NORTH_strob),

.data_blocks1(eth_data_blocks1),
.data_blocks2(eth_data_blocks2),
//.rdempty1(1'b0),//eth_rdempty1),
//.rdempty2(1'b0),//eth_rdempty2),
.is_there_256_1(is_there_256_1),
.is_there_256_2(is_there_256_2),
//.RAW_STATIC_DATA({31'b0,SUB_TA_TB_flag,SUB_TA_TB,{118{8'b0}}}), //[991:0]
.rdreq1(eth_rdreq1),
.rdreq2(eth_rdreq2),

.RAM_120_IN(),
.RAM_120_RDEN(),
.RAM_120_OUT(),
.RAM_120_WREN(), 

.data_type_one(eth_comp_data),
.data_type_one_wren(eth_comp_data_ena),

.debug_led_2(debug_led_2),
.debug_led_1(debug_led_1),
.local_reset_summary(debug_reset)	
);
/*
Eth_RAM_120_data Eth_120_IN(
	.clka(),
	.wea(),
	.addra(),
	.dina(),
	.clkb(),
	.addrb(),
	.doutb()
);

Eth_RAM_120_data Eth_120_OUT(
	.clka(),
	.wea(),
	.addra(),
	.dina(),
	.clkb(),
	.addrb(),
	.doutb()
);
*/
/*
//---------------очередь с базой свёртки из пакета-------------
fifo_compression_base fcb(
	.rst(~locked_2),
	.wr_clk(~clk_12),
	.rd_clk(SOME_READ_CLOCK_MF),
	.din(eth_comp_data),
	.wr_en(eth_comp_data_ena),
	.rd_en(SOME_READ_REQUEST_MF),
	.dout(SOME_READ_WIRE_MF),
	.full(),
	.empty(SOME_RDEMPTY_MF),
	.rd_data_count(SOME_RD_DATA_COUNT_MF)
);
*/
//---------------------------debugging part------------------

//----INSERT BUTTON SIGNAL-----------------------------------

reg [22:0] counter_for_slowing_down;
reg [7:0] was_there_a_switch;
reg [7:0] input_led_debug;
integer l;
always @(posedge clk_dv) begin
	counter_for_slowing_down <= counter_for_slowing_down + 1'b1;
	input_led_debug[7] <= debug_reset;
	input_led_debug[6] <= e_rx_dv;
	input_led_debug[5] <= e_rx_clk;
	input_led_debug[4] <= e_tx_en;
	input_led_debug[3] <= e_tx_clk_bf;
	input_led_debug[2] <= debug_led_2;
	input_led_debug[1] <= debug_led_1;
	if (counter_for_slowing_down) begin
		for (l = 0; l < 8; l = l + 1) begin
			if (input_led_debug[l] != Led_reg[l])
				was_there_a_switch[l] <= 1;
		end
	end else begin
		for (l = 1; l < 8; l = l + 1) begin
			if (was_there_a_switch[l]) begin
				Led_reg[l] <= ~Led_reg[l];
				was_there_a_switch[l] <= 0;
			end
		end
	end
end

always @(posedge clk_12) begin 
	BTN_WEST_f <= BTN_WEST_bf;
	BTN_WEST_ff <= BTN_WEST_f;
	// при нажатии кнопки включается АЦП имитатор при повторном нажатии выключается 
	if ( BTN_WEST_f & (!BTN_WEST_ff) &(!BTN_WEST_strob)) begin 
		adc_01_start <= ~adc_01_start;
		BTN_WEST_strob <= 1;
	end
	
	if ( BTN_WEST_strob & BTN_WEST_counter == 20_000_000) BTN_WEST_strob <= 0;
	
	// счетчик сброса сигнала кнопки
	if (BTN_WEST_strob) BTN_WEST_counter <= BTN_WEST_counter +1;
	else BTN_WEST_counter <= 0;
	
	if (adc_01_start) Led_reg[0] <= 1'b1;
	else Led_reg[0] <= 1'd0;
	
end

//-------------------------------------------------------------------------
// insert imitator of ADC 

/*
adc_imi	adc_imi_01
(
.clk_100	(clk_dv), //100_MHZ clock
.reset		(~locked),
.start		(adc_01_start), //строб начала общения с АЦП

//.sck, 
.CS			(acp_data_clock1), // фронт каждый раз когда приняли данные
//.mdi,
.en			(acp_data1_ena), // строб запуска фифо немного дебажный вариант 
.adc_data	(acp_data1) //данные
);
*/
//------------------------------------------------------------------
//ADC -> Ethernet fifo 
fifo_acp 		fifo_input_acp1(
	.rst			(~locked_2),
	.wr_clk			(acp_data_clock1),
	.rd_clk			(~e_tx_clk_bf),
	.din			(acp_data1),
	.wr_en			(acp_data1_ena),
	.rd_en			(eth_rdreq1),
	.dout			(eth_data_blocks1),
	.full			(),
	.empty			(eth_rdempty1),
	.rd_data_count	(rd_data_count_01),//{is_there_256_1,ground1[7:0]})
	.wr_data_count	(wr_data_count_01)
);

fifo_acp 		fifo_input_acp2(
	.rst			(~locked_2),
	.wr_clk			(acp_data_clock2),
	.rd_clk			(~e_tx_clk_bf),
	.din			(conv_DATA_OUT_A),
	.wr_en			(acp_data2_ena),
	.rd_en			(eth_rdreq2),
	.dout			(eth_data_blocks2), 
	.full			(),
	.empty			(eth_rdempty2),
	.rd_data_count	(rd_data_count_02),
	.wr_data_count	(wr_data_count_02)
);

parameter address=4'd0,command=4'b0011;

/*
dac_2624 dac 
( 
.clk			(clk_50),
.rst			(~locked), 
.i_dac_start	(dac_start),
.dac_data		(12'hfff),//dac_data),

.spi_mosi		(SPI_MOSI),
.dac_cs			(DAC_CS_wire), // high min 10 ns
.spi_sck		(SPI_SCK), //min T=20ns
.dac_clr		(DAC_CLR),
.spi_miso		(SPI_MISO_bf)
);

always @(posedge DAC_CS_wire)begin 
	if ( dac_start) begin
		if (dac_strob_up) dac_data<= dac_data+1;
		else dac_data<= dac_data-1;
		
		if (dac_data == 12'hffe) dac_strob_up<=0;
		else if ( dac_data == 12'h 001) dac_strob_up<=1;
	end
	else begin dac_data <= 12'h 001; dac_strob_up <=1;end

end*/
//-------------------------------------------------------------------------
//--------------ADC LTC2315 block------------------------------------------

adc_ltc2315 adc_01(
.clk_100	(clk_dv),
.reset		(~locked_2),
.start		(adc_01_start),

.sck		(adc_01_sck), 
.CS			(adc_01_cs),
.sdo		(adc_01_sdo_bf),
.en			(adc_01_en),
.adc_data	(adc_01_data)
 );

adc_ltc2315 adc_02(
.clk_100	(clk_dv),
.reset		(~locked_2),
.start		(adc_01_start),

.sck		(adc_02_sck), 
.CS			(adc_02_cs),
.sdo		(adc_02_sdo_bf),
.en			(adc_02_en),
.adc_data	(adc_02_data)
 );
(*mark_debug = "true"*)reg signed [15:0] acp_add1, acp_add2;
(*mark_debug = "true"*)reg [15:0] acp_data1_ft, acp_data2_ft;
(*mark_debug = "true"*)reg triger_setup;
// сдвиг на 2 такта
always @(posedge clk_12) begin 
	adc_01_cs_f<= adc_01_cs;
	adc_01_cs_ff <= adc_01_cs_f;
	adc_02_cs_f<= adc_01_cs;
	adc_02_cs_ff <= adc_01_cs_f;
	
	/*
	acp_data1_ft <= acp_data1; 
	acp_data2_ft <= acp_data2; 
	acp_add1 <= $signed(acp_data1_ft) - $signed(acp_data1);
	acp_add2 <= $signed(acp_data2_ft) - $signed(acp_data2);
	if (acp_add1[15]) begin
		if (acp_add1 < 16'hFF80) triger_setup <= 1;
		else triger_setup <= 0;
	end
	else begin
		if (acp_add1 > 16'h0080) triger_setup <= 1;
		else triger_setup <= 0;
	end*/
end

//-------------------------------------------------------------------------


endmodule
