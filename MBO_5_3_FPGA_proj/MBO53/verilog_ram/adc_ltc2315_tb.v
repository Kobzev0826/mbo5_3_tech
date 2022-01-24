`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:48:32 12/11/2021
// Design Name:   adc_ltc2315
// Module Name:   D:/Xilinx/git/mbo5_3_tech/MBO_5_3_FPGA_proj/MBO53/verilog/adc_ltc2315_tb.v
// Project Name:  MBO53
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: adc_ltc2315
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module adc_ltc2315_tb;

	// Inputs
	reg clk_100;
	reg reset;
	reg start;
	reg sdo;

	// Outputs
	wire sck;
	wire CS;
	wire en;
	wire [15:0] adc_data;

	// Instantiate the Unit Under Test (UUT)
	adc_ltc2315 uut (
		.clk_100(clk_100), 
		.reset(reset), 
		.start(start), 
		.sck(sck), 
		.CS(CS), 
		.sdo(sdo), 
		.en(en), 
		.adc_data(adc_data)
	);

	initial begin
		// Initialize Inputs
		clk_100 = 0;
		reset = 1;
		start = 0;
		sdo = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
			reset = 0;
		
		#100
		start=1;
		
		#63
		sdo=1;
		#80
		sdo=0;
	end
      
	always 
		begin 
			#5 clk_100=~clk_100; 
		end
	  
      
endmodule

