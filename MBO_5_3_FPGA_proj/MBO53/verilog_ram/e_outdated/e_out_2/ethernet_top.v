`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:38:02 11/29/2021 
// Design Name: 
// Module Name:    ethernet_top 
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
module ethernet_top(
	input clk,
	input reset,
	input BTN,
	
	output 	[3:0] e_tx_d,
	output 	e_tx_en,
	output 	e_tx_er,
	input 	e_tx_clk,
	
	input 	[3:0] e_rx_d,
	input 	e_rx_er,
	input 	e_rx_dv,
	input 	e_rx_clk,
	
    input 	e_crc,
    input 	e_col,
    output 	e_mdc,
	input mdio_rx,
	output mdio_en,
    output 	e_mdio

    );
	

(*mark_debug="true"*)reg [15:00] mdio_data_reg;	
(*mark_debug="true"*)wire [15:00] mdio_data;
(*MARK_DEBUG = "true"*)reg e_mdio_reg;
(*mark_debug="true"*) reg [31:00] e_data;
//wire o_mdio;
reg mdio_clk;

reg mdio_write=0;


reg [7:0] mdio_clk_counter = 0;
reg [25:00] read_counter=0;

reg mdio_read,read_strob;
reg mdc_clk;

assign e_mdc = mdc_clk;	
//assign e_mdio = o_mdio;
//----------Управление стробом чтения mdio------------

always @(posedge clk)begin 
	if ( reset) begin 
		mdio_clk_counter <= 0;
		read_counter <= 0;
	end
	else begin
		if ( mdio_clk_counter == 8'd100) mdio_clk_counter <= 0;
		else mdio_clk_counter <= mdio_clk_counter + 1;
		
		case (mdio_clk_counter)
			8'd 00:mdio_clk <=1'b0;
			
			8'd 25:mdc_clk <= 1'b1;
			
			8'd 50:mdio_clk <=1'b1;
			
			8'd 75:mdc_clk <= 1'b0;
			
		endcase
		/*
		if ( read_counter == 26'd 50_000_000) begin
			read_counter <= 0;
			mdio_read <= ~mdio_read;
		end
		else read_counter <= read_counter + 1;*/
		if ( BTN) begin mdio_read <= 1; end
		else if ( read_strob) mdio_read <=0;
		
		if ( read_counter == 26'd 50_000_000) begin read_counter <=0; read_strob <=1; end
		else if ( mdio_read) begin read_counter <= read_counter +1; read_strob <= 0; end
		
		mdio_data_reg [15:00]<= mdio_data[15:00];
		e_mdio_reg <= e_mdio;
	end
end


(*keep_hierarchy="yes"*) 
mdio_control_100 mdio(
.clock	(mdio_clk),//1MHz
.reset	(1),
.start	(mdio_write),
.read	(mdio_read),
.mdio_rx(mdio_rx),
.mdio_en(mdio_en),
.e_mdio (e_mdio),
.Data_reg	(mdio_data)
);

//------------------------------------recive data-----------------------

always @(posedge e_rx_clk) begin
	if ( e_rx_dv) begin 
		e_data[3:0] <= e_rx_d;
		e_data[31:4] <= e_data[27:0];
	end
	

end


endmodule
