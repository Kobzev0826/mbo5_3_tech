`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:54:53 12/08/2021
// Design Name:   adc_imi
// Module Name:   E:/Xilinx/projects/MBO-5_3/MBO_5_3_FPGA_proj/MBO53/verilog/adc_imi_tb.v
// Project Name:  MBO53
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: adc_imi
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module adc_imi_tb;

	// Inputs
	reg clk_100;
	reg reset;
	reg start;
	reg mdi;

	// Outputs
	wire sck;
	wire CS;
	wire en;
	wire [15:0] adc_data;

	// Instantiate the Unit Under Test (UUT)
	adc_imi uut (
		.clk_100(clk_100), 
		.reset(reset), 
		.start(start), 
		.sck(sck), 
		.CS(CS), 
		.mdi(mdi), 
		.en(en), 
		.adc_data(adc_data)
	);

	initial begin
		// Initialize Inputs
		clk_100 = 0;
		reset = 1;
		start = 0;
		mdi = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		reset = 0;
		
		#100
		start=1;
	end
      
	always 
		begin 
			#5 clk_100=~clk_100; 
		end
	  
endmodule

