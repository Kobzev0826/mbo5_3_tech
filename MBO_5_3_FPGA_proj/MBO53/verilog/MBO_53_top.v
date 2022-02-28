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
module 			MBO_53_top(
input 			clk,

input 			BTN_WEST,
input 			BTN_NORTH,
//-----------  ETHERNET PHY  -------------
output 	[3:0] 	e_tx_d,
output 			e_tx_en,
output 			e_tx_er,
input  			e_tx_clk,

input 	[3:0] 	e_rx_d,
input 			e_rx_er,
input 			e_rx_dv,
input 			e_rx_clk,

//input 			e_crc,
//input 			e_col,
//output 			e_mdc,
//inout 			e_mdio,

//--------------  ADC_01  ----------------
input 			adc_01_sdo,
output 			adc_01_sck,
output 			adc_01_cs,

//--------------  ADC_02  ----------------
input 			adc_02_sdo,
output 			adc_02_sck,
output 			adc_02_cs,

//-----------  Laser_cntrl  --------------
input 			Laser_rx_d,
output 			Laser_tx_d,

//-------------UART_control---------------
input uart_rx_d,
output uart_tx_d,

//---------------  LED  ------------------
output 	[7:0] 	LED//,

//------DAC KIT SPARTAN----
/*
output SPI_MOSI,
output DAC_CS, 
output SPI_SCK, 
output DAC_CLR,
input SPI_MISO*/
);

//=====================  PLLs  ===================================================
wire locked, locked_2, locked_3;
wire clk_dv, clk_bf, clk_50, clk_12, clk_2x, clk_bf_2, clk_dv_90, clk_laser_uart;

pll 				pll_1
(
.CLKIN_IN			(clk), 		//50MHz
.RST_IN				(1'b0),
.CLKDV_OUT			(clk_dv),	//devide 2
.CLKIN_IBUFG_OUT	(clk_bf),
.CLK0_OUT			(clk_50),
.CLK2X_OUT			(clk_2x),
.LOCKED_OUT			(locked)
);

pll_2 				pll_2
(
.CLKIN_IN			(clk_dv), 	// 25 MHz
.RST_IN				(~locked), 
.CLKDV_OUT			(clk_12), 	// 12.5 MHz
.CLK90_OUT			(clk_dv_90),// 25 MHz 90grad
.CLK0_OUT			(),
.LOCKED_OUT			(locked_2)
);

pll_laser 			pll_3
(
.CLKIN_IN			(clk_12), 
.RST_IN				(~locked_2), 
.CLKDV_OUT			(clk_laser_uart), // 12.5Mhz/7
.CLK0_OUT			(),
.LOCKED_OUT			(locked_3)
);

//=================  ADC LTC2315 block  ==========================================
wire [15:0] adc_01_data, adc_02_data;

adc_ltc2315 		adc_01
(
.clk_100			(clk_dv),
.clk_90				(clk_dv_90),
.reset				(~locked_2),
.start				(1'b1),

.sck				(adc_01_sck), 
.CS					(adc_01_cs),
.sdo				(adc_01_sdo),
.en					(),
.adc_data			(adc_01_data)
);
 
adc_ltc2315 		adc_02
(
.clk_100			(clk_dv),
.clk_90				(clk_dv_90),
.reset				(~locked_2),
.start				(1'b1),

.sck				(adc_02_sck), 
.CS					(adc_02_cs),
.sdo				(adc_02_sdo),
.en					(),
.adc_data			(adc_02_data)
);

//==================  LASER CONTROL  =============================================
wire laser_eth, laser_connected, laser_status; 

(*keep_hierarchy="yes"*) 
laser_connect_top 	laser_cntrl(
.pll_rst			(~locked_3), 		// !locked pll3
.clk				(clk_laser_uart), 	// 12.5Mhz/7
.rx_d				(Laser_rx_d), 		// 
.laser_on			(laser_eth), 		// команда от эзернета 1 - вкл, 0 - выкл

.tx_d				(Laser_tx_d),		//
.laser_connected	(laser_connected), 	// статус наличия соединения с лазером (проверяется во время отработки команд на включение и выключение)
.laser_on_status	(laser_status)		// статус лазера (включен или отключен)
);

//======================  GigE  ==================================================
wire 			e_tx_clk_bf;
wire	[15:0]	eth_data_blocks1, eth_data_blocks2; // данные из ПЛИС в ПК
wire 			is_there_256_1, is_there_256_2;	
wire 	[23:0] 	SUB_TA_TB;
wire 			eth_rdreq1, eth_rdreq2;	
wire 	[991:0] header_parsed;
wire 			header_parsed_valid;
wire 	[15:0] 	eth_comp_data;
wire 			eth_comp_data_ena;
wire 			start_eth;

assign e_tx_er=0;
IBUFG					bf_e_tx_clk
(
.I						(e_tx_clk), 	
.O						(e_tx_clk_bf)
);

Ethernet_module_upper 	ethernet
(
.TX_D					(e_tx_d),
.TX_EN      			(e_tx_en),
.TX_CLK     			(e_tx_clk_bf),
				
.RX_D       			(e_rx_d),
.RX_DV      			(e_rx_dv),
.RX_CLK     			(e_rx_clk),

.clk_main				(clk_2x),
.clk_12_5				(clk_12),

.reset_global_in_1		(~locked),
.reset_global_in_2		(~locked_2),
.reset_global_in_3		(1'b0),

.data_blocks1			(eth_data_blocks1),
.data_blocks2			(eth_data_blocks2),

.is_there_256_1			(is_there_256_1),
.is_there_256_2			(is_there_256_2),
.RAW_STATIC_DATA		({31'b0,1'b1,SUB_TA_TB,{3'b0,laser_eth,4'h7,4'b0,3'b0,laser_connected,3'b0,start_eth,4'h8,4'b0,3'b0,laser_status},{113{8'b0}}}), //[991:0]
.rdreq1					(eth_rdreq1),
.rdreq2					(eth_rdreq2),
.header_parsed			(header_parsed),
.header_parsed_valid	(header_parsed_valid),
 
.data_type_one			(eth_comp_data),
.data_type_one_wren		(eth_comp_data_ena),

.laser					(laser_eth),
.start					(start_eth)	
);

//==================  BUFF Ethernet  =============================================
//reg 	[15:0] 	fifo_eth_in_data_1, fifo_eth_in_data_2;
wire 			adc_01_cs_st, adc_02_cs_st;
wire [8:0] 		rd_data_count_01, rd_data_count_02;

assign is_there_256_1 = rd_data_count_01[8];
assign is_there_256_2 = rd_data_count_02[8];

fifo_acp 				fifo_input_acp1
(
	.rst				(~locked_2),
	.wr_clk				(clk_12),
	.rd_clk				(e_tx_clk_bf),
	.din				(adc_01_data),
	.wr_en				(start_eth & adc_01_cs_st),
	.rd_en				(eth_rdreq1),
	.dout				(eth_data_blocks1),
	.full				(),
	.empty				(),
	.rd_data_count		(rd_data_count_01),
	.wr_data_count		()
);

fifo_acp 				fifo_input_acp2
(
	.rst				(~locked_2),
	.wr_clk				(clk_12),
	.rd_clk				(e_tx_clk_bf),
	.din				(adc_02_data),
	.wr_en				(start_eth & adc_02_cs_st),
	.rd_en				(eth_rdreq2),
	.dout				(eth_data_blocks2),
	.full				(),
	.empty				(),
	.rd_data_count		(rd_data_count_02),
	.wr_data_count		()
);

//===================  CONVOLUTION  ==============================================
wire [15:0] conv_DATA_OUT_A, conv_DATA_OUT_B;
reg [15:0] FIX_POROG;

always @(posedge clk_12) begin //ЗАМЕНИТЬ RAM-переходом!!!
	if (header_parsed_valid) begin
		FIX_POROG <= header_parsed[991:976];
	end
end
/*
(*keep_hierarchy="yes"*) 
convolution_top convolution_top(
.clks				(clk_12), 				// 
.clkf				(clk_dv), 				// 
.clke				(clk_12), 				// клок эзернета для записи опары из ПК в память блока свертки
.rst				(~locked_2), 			// глобальный асинхронный сброс
	
.opora_en			(eth_comp_data_ena), 	// строб сопровождающий запись опоры в память
.OPORA				(eth_comp_data), 		// Опора из ПК
	
.data_in_en			(adc_01_cs_st),
.DATA_IN_A			(adc_01_data), 			// данные с АЦП1
.DATA_IN_B			(adc_02_data), 			// данные с АЦП2
	
.FIX_POROG			(FIX_POROG),
.DATA_OUT_A			(conv_DATA_OUT_A),		//{real, image}
.DATA_OUT_B			(conv_DATA_OUT_B),		//{real, image}
	
.SUB_TA_TB			(SUB_TA_TB),
.SUB_TA_TB_en		()
);
*/
//======================  OTHER  =================================================
//--------LED settings-------------
reg [7:0] Led_reg;
reg [1:0] CONTROL_MULT;

assign LED = Led_reg;
/*
always @(posedge clk_12) begin
	case (CONTROL_MULT)
		0 : begin
			fifo_eth_in_data_1 <= adc_01_data;
			fifo_eth_in_data_2 <= adc_02_data;
		end
		1 : begin
			fifo_eth_in_data_1 <= adc_01_data;
			fifo_eth_in_data_2 <= conv_DATA_OUT_A;
		end
		2: begin
			fifo_eth_in_data_1 <= adc_02_data;
			fifo_eth_in_data_2 <= conv_DATA_OUT_B;
		end
		3: begin
			fifo_eth_in_data_1 <= conv_DATA_OUT_A;
			fifo_eth_in_data_2 <= conv_DATA_OUT_B;
		end
		default: begin
			fifo_eth_in_data_1 <= adc_01_data;
			fifo_eth_in_data_2 <= adc_02_data;
		end
	endcase
	if (~locked_2) begin
		CONTROL_MULT <= 0;
	end else if (header_parsed_valid) begin
		CONTROL_MULT <= header_parsed[961:960];
	end
end
*/
reg adc_01_cs_f,adc_01_cs_ff, adc_02_cs_f, adc_02_cs_ff;
assign adc_01_cs_st = adc_01_cs_f && (!adc_01_cs_ff);
assign adc_02_cs_st = adc_02_cs_f && (!adc_02_cs_ff);
always @(posedge clk_12) begin 
	adc_01_cs_f		<= adc_01_cs;
	adc_01_cs_ff 	<= adc_01_cs_f;
	adc_02_cs_f		<= adc_01_cs;
	adc_02_cs_ff 	<= adc_01_cs_f;
end


uart_control uart_control(

.clk	(clk_laser_uart),
.rst	(~locked_3),
.rx_d 	(uart_rx_d),
.tx_d 	(uart_tx_d)
);


endmodule
//-------------------------------------------------------------------------
/*
adc_imi adc_01(
.clk_25					(clk_dv),
.reset					(~locked_2),
.start					(adc_01_start),

.sck					(adc_01_sck), 
.CS						(adc_01_cs),

.adc_data				(adc_01_data)
 );

adc_imi adc_02(
.clk_25					(clk_dv),
.reset					(~locked_2),
.start					(adc_01_start),

.sck					(adc_02_sck), 
.CS						(adc_02_cs),

.adc_data				(adc_02_data)
 );
*/

	
//wire e_tx_clk_bf,BTN_WEST_bf,BTN_NORTH_bf,SPI_MISO_bf,adc_01_sdo_bf,adc_02_sdo_bf;

//IBUFG	bf3(.I(adc_01_sdo), .O(adc_01_sdo_bf));
//IBUFG	bf4(.I(adc_02_sdo), .O(adc_02_sdo_bf));
//IBUFG	bf1(.I(BTN_WEST), 	.O(BTN_WEST_bf));
//IBUFG	bf6(.I(BTN_NORTH), 	.O(BTN_NORTH_bf));

/*IOBUF (
.O		(rx_mdio),
.IO		(e_mdio),
.I		(tx_mdio),
.T		(mdio_en) //1-tx 0 - rx
);*/
//BUFG	bf2(.I(SPI_MISO), .O(SPI_MISO_bf));
//(*mark_debug="yes"*)wire e_mdio_bf;
//wire emdc;
//wire DAC_CS_wire;

//reg[11:0] dac_data;
//reg dac_strob_up=1;
//assign e_mdc = emdc;
//assign DAC_CS=DAC_CS_wire;
//assign e_mdio = e_mdio_bf;
	
//reg [3:0] e_counter;
//reg e_tx_er_reg;
//
//assign e_tx_er=0;
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


/*
//------------------CONVOLUTION WIRE and REG------------------------------
(*mark_debug = "true"*)wire [15:0] conv_DATA_OUT_A, conv_DATA_OUT_B;
(*mark_debug = "true"*)wire conv_data_out_en;

(*mark_debug = "true"*)wire SUB_TA_TB_en;
//-------------------------------------------------------------------

//-------------ADC WIRE AND REG------------------------------------------
(*mark_debug = "true"*)wire [15:00] adc_01_data, adc_02_data;
(*mark_debug = "true"*)wire [11:0] adc_01_data_true;


(*mark_debug = "true"*)reg [3:0] error_counter;
//reg adc_01_start;
assign adc_01_data_true = adc_01_data[11:00];
//-------------------------------------------------------------------


//reg [991:0] RAW_STATIC_DATA; //128 byte - 4byte packet send counter;
(*mark_debug = "true"*)wire eth_rdempty1, eth_rdempty2, eth_rdreq1, eth_rdreq2, is_there_256_1, is_there_256_2;

wire [15:0] acp_data1, acp_data2;
wire acp_data1_ena, acp_data2_ena;
//wire acp_data_clock1, acp_data_clock2;
(*mark_debug = "true"*)wire [8:0] rd_data_count_01,wr_data_count_01,rd_data_count_02,wr_data_count_02;
(*mark_debug = "true"*)wire dac_start;
assign dac_start = adc_01_start;



assign acp_data1 = {4'd0,adc_01_data[11:00]};
assign acp_data2 = {4'd0,adc_02_data[11:00]};
assign acp_data1_ena = adc_01_start;
assign acp_data2_ena = adc_01_start;
//assign acp_data_clock1 = adc_01_cs_ff;
//assign acp_data_clock2 = adc_02_cs_ff;


wire header_parsed_valid;





reg BTN_NORTH_f, BTN_NORTH_ff;
reg BTN_NORTH_strob;
reg [23:00] BTN_NORTH_counter;

reg adc_01_start, BTN_WEST_f, BTN_WEST_ff;
reg BTN_WEST_strob;
reg [23:00] BTN_WEST_counter;
//----INSERT BUTTON SIGNAL-----------------------------------
 
 
wire clk_dv_n;

wire adc_01_cs_st, adc_02_cs_st;
assign adc_01_cs_st = adc_01_cs_f && (!adc_01_cs_ff);
assign adc_02_cs_st = adc_02_cs_f && (!adc_02_cs_ff);
assign clk_dv_n = ~clk_dv; 

always @(posedge clk_12) begin 
	BTN_NORTH_f <= BTN_NORTH_bf;
	BTN_NORTH_ff <= BTN_NORTH_f;
	if ( BTN_NORTH_f & (!BTN_NORTH_ff) &(!BTN_NORTH_strob)) begin 
		BTN_NORTH_strob <= 1;
	end
	
	if ( BTN_NORTH_strob && BTN_NORTH_counter[23]) BTN_NORTH_strob <= 0;
	
	// счетчик сброса сигнала кнопки
	if (BTN_NORTH_strob) BTN_NORTH_counter <= BTN_NORTH_counter +1;
	else BTN_NORTH_counter <= 0;
end
*/







//---------------------------debugging part------------------

//----INSERT BUTTON SIGNAL-----------------------------------
/* 
always @(posedge clk_12) begin 
	BTN_WEST_f <= BTN_WEST_bf;
	BTN_WEST_ff <= BTN_WEST_f;
	// при нажатии кнопки включается АЦП имитатор при повторном нажатии выключается 
	if ( BTN_WEST_f & (!BTN_WEST_ff) &(!BTN_WEST_strob)) begin 
		adc_01_start <= ~adc_01_start;
		BTN_WEST_strob <= 1;
	end
	
	if ( BTN_WEST_strob && BTN_WEST_counter[23]) BTN_WEST_strob <= 0;
	
	// счетчик сброса сигнала кнопки
	if (BTN_WEST_strob) BTN_WEST_counter <= BTN_WEST_counter +1;
	else BTN_WEST_counter <= 0;
	
	if (adc_01_start) Led_reg <= 8'b10101010;
	else Led_reg <= 8'd0;
end
*/



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


//(*mark_debug = "true"*)reg [15:0] acp_data1_ft, acp_data2_ft;
//(*mark_debug = "true"*)reg triger_setup;
// сдвиг на 2 такта
/*always @(posedge clk_12) begin 
	adc_01_cs_f		<= adc_01_cs;
	adc_01_cs_ff 	<= adc_01_cs_f;
	adc_02_cs_f		<= adc_01_cs;
	adc_02_cs_ff 	<= adc_01_cs_f;
	

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
end


*/

