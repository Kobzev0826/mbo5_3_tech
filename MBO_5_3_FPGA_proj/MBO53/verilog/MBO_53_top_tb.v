`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:23:23 12/08/2021
// Design Name:   MBO_53_top
// Module Name:   E:/Xilinx/projects/MBO-5_3/MBO_5_3_FPGA_proj/MBO53/verilog/MBO_53_top_tb.v
// Project Name:  MBO53
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MBO_53_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module MBO_53_top_tb;

	// Inputs
	reg clk;
	reg BTN_WEST;
	reg e_tx_clk;
	reg [3:0] e_rx_d;
	reg e_rx_er;
	reg e_rx_dv;
	reg e_rx_clk;
	reg e_crc;
	reg e_col;

	// Outputs
	wire [3:0] e_tx_d;
	wire e_tx_en;
	wire e_tx_er;
	wire e_mdc;

	// Bidirs
	wire e_mdio;

	// Instantiate the Unit Under Test (UUT)
	MBO_53_top uut (
		.clk(clk), 
		.BTN_WEST(BTN_WEST), 
		.e_tx_d(e_tx_d), 
		.e_tx_en(e_tx_en), 
		.e_tx_er(e_tx_er), 
		.e_tx_clk(e_tx_clk), 
		.e_rx_d(e_rx_d), 
		.e_rx_er(e_rx_er), 
		.e_rx_dv(e_rx_dv), 
		.e_rx_clk(e_rx_clk), 
		.e_crc(e_crc), 
		.e_col(e_col), 
		.e_mdc(e_mdc), 
		.e_mdio(e_mdio)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		BTN_WEST = 0;
		e_tx_clk = 0;
		e_rx_d = 0;
		e_rx_er = 0;
		e_rx_dv = 0;
		e_rx_clk = 0;
		e_crc = 0;
		e_col = 0;

		// Wait 100 ns for global reset to finish
		#1000;
        
		// Add stimulus here
		BTN_WEST=1;
	end
      
	always 
		begin 
			#10 clk=~clk; 
		end  
	  
	  
endmodule

