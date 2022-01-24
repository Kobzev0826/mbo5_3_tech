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

reg [3:0] e_counter;
reg e_tx_er_reg;

assign e_tx_en = e_counter[3];
assign [3:0] e_tx_d = [3:0]e_counter;
assign e_tx_er = e_tx_er_reg;
always @(posedge clk) begin 
	e_counter <= e_counter +1;
	e_tx_er_reg <= ~e_tx_er_reg;
end


//ethernet_top ethernet();


endmodule
