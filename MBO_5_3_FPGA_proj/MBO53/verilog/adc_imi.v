`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:20:53 12/06/2021 
// Design Name: 
// Module Name:    adc_imi 
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
module adc_imi(
	input 		clk_25,
	input 		reset,
	input 		start,
	
	output 		sck, 
	output reg 	CS,
	input 		mdi,
	output 		en,
	output [11:00] adc_data
    );

reg [4:0] adc_counter_cycle;
reg [5:0] adc_data_reg;

assign adc_data = {6'h0, adc_data_reg};
assign adc_01_sck = 0;
assign en = 0;

always @(posedge clk_25 or posedge reset) begin

	if (reset) begin 
		adc_counter_cycle 	<= 0;
		CS 					<= 0;
		adc_data_reg 		<= 0;
	end
	else begin 
		if (start) begin
			if (adc_counter_cycle == 24) adc_counter_cycle <=0;
			else adc_counter_cycle <= adc_counter_cycle +1;
			
			case (adc_counter_cycle)
			1: 	adc_data_reg <= adc_data_reg + 1;			
			14: CS <= 1;
			23: CS <= 0; 
			endcase
		end
		else begin 
			adc_counter_cycle 	<= 0;
			CS 					<= 0;
		end
	end
	
end

endmodule
