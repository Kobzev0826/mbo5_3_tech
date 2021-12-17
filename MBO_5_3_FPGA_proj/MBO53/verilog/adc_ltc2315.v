`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:38:26 12/11/2021 
// Design Name: 
// Module Name:    adc_ltc2315 
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
module adc_ltc2315(
	input clk_100,
	input reset,
	input start,
	
	output sck, 
	output CS,
	input sdo,
	output en,
	output [15:00]adc_data

    );
localparam DELAY=0;	
	
reg [4:0] adc_counter_cycle;
reg [15:00] adc_data_reg;
reg CS_reg, en_reg;

assign CS=CS_reg;
assign  adc_data[15:00] = adc_data_reg [15:00];
assign en=en_reg;
assign sck= clk_100;//start? clk_100 : 0;

always @(posedge clk_100) begin

	if ( reset ) begin 
		adc_counter_cycle <= 0;
		CS_reg <=1;
		
		en_reg <= 0;
	end
	else begin 
		if (start)begin
			if (adc_counter_cycle == 5'd 24) adc_counter_cycle <=0;
			else adc_counter_cycle <= adc_counter_cycle +1;
			
			case (adc_counter_cycle) 
				5'd00:begin CS_reg <=1;en_reg <= 1;end
				
				5'd03: begin CS_reg <=0;end
				
				5'd05:	en_reg <= 0;
				
				5'd17+DELAY: en_reg <= 1;
				
				5'd17:	begin CS_reg <=1;if (DELAY==0)en_reg <= 1;end
			endcase
			
			
			//else adc_data_reg <= 16'd0;
		end
		else begin 
			en_reg <= 0;
			CS_reg <=1;
			//adc_data_reg <=16'd0;
			adc_counter_cycle <=5'd00;
		end
	end
end

always @(negedge clk_100)begin 
	if ( reset ) adc_data_reg <=16'd0;
	else begin 
		if (~en_reg) begin 
				adc_data_reg [0] <= sdo;
				adc_data_reg [15:01] <= adc_data_reg [14:00];
			end
	end
end

endmodule
