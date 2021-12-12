`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:08:30 12/12/2021
// Design Name:   dac_2624
// Module Name:   D:/Xilinx/git/mbo5_3_tech/MBO_5_3_FPGA_proj/MBO53/verilog/dac_2624_tb.v
// Project Name:  MBO53
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: dac_2624
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module dac_2624_tb;

	// Inputs
	reg clk;
	reg rst;
	reg i_dac_start;
	reg [11:0] dac_data;
	reg spi_miso;

	// Outputs
	wire spi_mosi;
	wire dac_cs;
	wire spi_sck;
	wire dac_clr;

	// Instantiate the Unit Under Test (UUT)
	dac_2624 uut (
		.clk(clk), 
		.rst(rst), 
		.i_dac_start(i_dac_start), 
		.dac_data(dac_data), 
		.spi_mosi(spi_mosi), 
		.dac_cs(dac_cs), 
		.spi_sck(spi_sck), 
		.dac_clr(dac_clr), 
		.spi_miso(spi_miso)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		i_dac_start = 0;
		dac_data = 0;
		spi_miso = 0;

		// Wait 100 ns for global reset to finish
		#100;
        rst = 0;
		// Add stimulus here
		#50
		dac_data = 12'd 234;
		#20
		i_dac_start = 1;
	end
     
	always 
		begin 
			#10 clk=~clk; 
		end
	  
endmodule

