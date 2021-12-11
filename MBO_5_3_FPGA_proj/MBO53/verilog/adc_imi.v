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
	input clk_100,
	input reset,
	input start,
	
	output sck, 
	output CS,
	input mdi,
	output en,
	output [15:00]adc_data
    );

reg [4:0] adc_counter_cycle;
reg [15:00] adc_data_reg;
reg CS_reg, en_reg;

assign CS=CS_reg;
assign  adc_data[15:00] = adc_data_reg [15:00];
assign en=en_reg;

always @(posedge clk_100) begin

	if ( reset ) begin 
		adc_counter_cycle <= 0;
		CS_reg <=0;
		adc_data_reg <=16'd0;
		en_reg <= 0;
	end
	else begin 
		if (start)begin
			if (adc_counter_cycle == 5'd 18) begin
				CS_reg <=0;
				adc_counter_cycle <=0;
				//en_reg <= 0;
			end	
			else adc_counter_cycle <= adc_counter_cycle +1;
			
			if ( adc_counter_cycle == 5'd 14) CS_reg <=1;
			
			if ( adc_counter_cycle == 5'd 13) begin 
				en_reg <= 1;
				adc_data_reg <= adc_data_reg + 1;
			end
		end
		else begin 
			en_reg <= 0;
			CS_reg <=0;
			adc_data_reg <=16'd0;
			adc_counter_cycle <=0;
		end
	end
end

endmodule
