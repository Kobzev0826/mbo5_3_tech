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
//---------ETHERNET PHY----------
output [3:0] e_tx_d,
output e_tx_en,
output e_tx_er,
input e_tx_clk,

input [3:0] e_rx_d,
input e_rx_er,
input e_rx_dv,
input e_rx_clk,

input e_crc,
input e_col,
output e_mdc,
inout e_mdio

    );
	
(*mark_debug = "true"*)wire e_rx_clk_bf,BTN_WEST_bf;
//IBUFG	bf1(.I(clk), .O(in_clk_bf));
IBUFG	bf2(.I(BTN_WEST), .O(BTN_WEST_bf));
/*IOBUF (
.O		(rx_mdio),
.IO		(e_mdio),
.I		(tx_mdio),
.T		(mdio_en) //1-tx 0 - rx
);*/
//BUFG	bf2(.I(e_mdio), .O(e_mdio_bf));
//(*mark_debug="yes"*)wire e_mdio_bf;
wire emdc;
wire clk_12, clk_bf_2, locked_2, clk50_double_pll_cross;
assign e_mdc = emdc;
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

/*
(*keep_hierarchy="yes"*) 
ethernet_top ethernet(
.clk			(clk_bf),
.reset			(1'b0),
.BTN			(BTN_WEST_bf),

.e_tx_d			(e_tx_d),
.e_tx_en        (e_tx_en),
.e_tx_er        (e_tx_er),
.e_tx_clk       (e_tx_clk),
				
.e_rx_d         (e_rx_d),
.e_rx_er        (e_rx_er),
.e_rx_dv        (e_rx_dv),
.e_rx_clk       (e_rx_clk),
				
.e_crc          (e_crc),
.e_col          (e_col),
.e_mdc          (emdc),
.mdio_rx		(rx_mdio),
.mdio_en		(mdio_en),
.e_mdio         (tx_mdio)
);*/
reg [991:0] RAW_STATIC_DATA; //128 byte - 4byte packet send counter;
wire eth_rdempty1, eth_rdempty2, eth_rdreq1, eth_rdreq2, is_there_256_1, is_there_256_2;
wire [7:0] eth_data_blocks1, eth_data_blocks2;
wire [15:0] acp_data1, acp_data2;
wire acp_data1_ena, acp_data2_ena;
wire [7:0] ground1, ground2;
(*keep_hierarchy="yes"*) 
Ethernet_module_upper ethernet(

.TX_D		(e_tx_d),
.TX_EN      (e_tx_en),
.TX_CLK     (e_tx_clk),
				
.RX_D       (e_rx_d),
.RX_DV      (e_rx_dv),
.RX_CLK     (e_rx_clk),

.clk_main	(clk_2x),
.clk_25		(clk_dv),
.clk_12_5	(clk_12),

.reset_global_in_1(~locked),
.reset_global_in_2(~locked_2),

.rdempty1(eth_rdempty1),
.rdempty2(eth_rdempty2),
.is_there_256_1(is_there_256_1),
.is_there_256_2(is_there_256_2),
.RAW_STATIC_DATA(RAW_STATIC_DATA), //[991:0]
.rdreq1(eth_rdreq1),
.rdreq2(eth_rdreq2)			
);

//---------------------------debugging part------------------
(*mark_debug = "true"*)reg adc_01_start, BTN_WEST_f, BTN_WEST_ff;
reg BTN_strob=0;
(*mark_debug = "true"*)reg [31:00]BTN_counter;
//----INSERT BUTTON SIGNAL-----------------------------------

always @(posedge clk_2x) begin 
	BTN_WEST_f <= BTN_WEST_bf;
	BTN_WEST_ff <= BTN_WEST_f;
	// при нажатии кнопки включается АЦП имитатор при повторном нажатии выключается 
	if ( BTN_WEST_f & (!BTN_WEST_ff) &(!BTN_strob)) begin 
		adc_01_start <= ~adc_01_start;
		BTN_strob <= 1;
	end
	
	if ( BTN_strob & BTN_counter == 200_000_000) BTN_strob <= 0;
	
	// счетчик сброса сигнала кнопки
	if (BTN_strob) BTN_counter <= BTN_counter +1;
	else BTN_counter <= 0;
end

// insert imitator of ADC 


adc_imi	adc_imi_01
(
.clk_100	(clk_2x), //100_MHZ clock
.reset		(~locked),
.start		(adc_01_start), //строб начала общения с АЦП

//.sck, 
.CS			(acp_data_clock1), // фронт каждый раз когда приняли данные
//.mdi,
.en			(acp_data1_ena), // строб запуска фифо немного дебажный вариант 
.adc_data	(acp_data1) //данные
);

//------------------------------------------------------------------
//ADC -> Ethernet fifo 
fifo_acp fifo_input_acp1(
	.rst(reset),
	.wr_clk(acp_data_clock1),
	.rd_clk(clk2x),
	.din(acp_data1),
	.wr_en(acp_data1_ena),
	.rd_en(eth_rdreq1),
	.dout(eth_data_blocks1),
	.full(),
	.empty(eth_rdempty1),
	.rd_data_count({is_there_256_1,ground1[7:0]})
);

fifo_acp fifo_input_acp2(
	.rst(reset),
	.wr_clk(acp_data_clock2),
	.rd_clk(clk2x),
	.din(acp_data2),
	.wr_en(acp_data2_ena),
	.rd_en(eth_rdreq2),
	.dout(eth_data_blocks2),
	.full(),
	.empty(eth_rdempty2),
	.rd_data_count({is_there_256_2,ground2[7:0]})
);

endmodule
