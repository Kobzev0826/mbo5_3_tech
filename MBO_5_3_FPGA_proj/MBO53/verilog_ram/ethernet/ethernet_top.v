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
    inout 	e_mdio

    );
	
assign e_mdio = mdio_clk;	
	
reg [15:00] mdio_data;
assign e_mdio = o_mdio;
reg mdio_write=0;
//----------Управление стробом чтения mdio------------
reg mdio_clk;
reg [5:0] mdio_clk_counter = 0;
reg mdio_read;
always @(posedge clk)begin 
	if ( reset) begin 
		mdio_clk_counter <= 0;
		read_counter <= 0;
	end
	else begin
		if ( mdio_clk_counter == 6'd25) begin
			mdio_clk <= ~mdio_clk;
			mdio_clk_counter <= 0;
		end
		else mdio_clk_counter <= mdio_clk_counter + 1;
		
		if ( read_counter == 26'd 50_000_000) begin
			read_counter <= 0;
			mdio_read <= ~mdio_read;
		end
		else read_counter <= read_counter + 1;
		
	end
end


mdio_control mdio(
.clock	(mdio_clk),//1MHz
.reset	(1),
.start	(mdio_write),
.read	(mdio_read),

.enet_mdio (o_mdio),
.Data_reg	(mdio_data)
);



endmodule
