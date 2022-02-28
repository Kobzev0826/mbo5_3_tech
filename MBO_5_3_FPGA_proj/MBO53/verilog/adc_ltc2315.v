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
	input clk_90,
	input reset,
	input start,
	
	input clk_dv_new,
	output sck, 
	output CS,
	input sdo,
	output en,
	output reg adc_data_trigger,
	output [15:00] adc_data

    );
localparam DELAY=0;	

//(*mark_debug="yes"*)reg adc_data_trigger;
	
reg [4:0] adc_counter_cycle;
(*IOB="TRUE"*)reg [15:00] adc_data_reg;

reg CS_reg, en_reg, en_sck;

assign CS=CS_reg;
assign  adc_data[15:00] = {4'h0, adc_data_reg [11:00]};
assign en=en_reg;
assign sck= en_sck? clk_100:0 ;//start? clk_100 : 0;

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
				5'd00:begin CS_reg <=1;end
				
				5'd04: begin CS_reg <=0; end
				
				5'd05: begin en_sck<=1; end
				
				5'd06: begin en_reg <= 1; end
				
				5'd17: en_reg <= 0;
				
				//5'd18: en_sck<=1;
				
				5'd19: begin CS_reg <=1; en_sck <= 0;end
			
			endcase
			
			/*if ( DELAY != 0) begin
				if ( adc_counter_cycle == 5'd17 + DELAY) begin 
					
				end
			*/
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
reg [4:0] cnt_reg;
wire sck_n;
assign sck_n = ~sck;
always @(posedge clk_90)begin 
	if (reset) adc_data_reg <=16'd0;
	else begin
		if ( ~CS_reg) begin 
			if (cnt_reg == 14) cnt_reg <= 0;
			else cnt_reg <= cnt_reg + 1;
		end
		else cnt_reg <=0;
		
		if ((cnt_reg > 1) && (cnt_reg < 14)) begin 
			adc_data_reg [0] <= sdo;
			adc_data_reg [15:01] <= adc_data_reg [14:00];
		end
		else adc_data_reg[11:0] <= adc_data_reg[11:0];
		
	end
end
/*
always @(posedge sck)begin 
	if ( reset ) adc_data_reg <=16'd0;
	else begin
		if (cnt_reg == 14) cnt_reg <= 0;
		else cnt_reg <= cnt_reg + 1;
		
		if ((cnt_reg > 0) && (cnt_reg < 13)) begin 
			adc_data_reg [0] <= sdo;
			adc_data_reg [15:01] <= adc_data_reg [14:00];
		end
		else adc_data_reg[11:0] <= adc_data_reg[11:0];
	end
end
*/
reg CS_reg_ft, CS_reg_2ft, CS_reg_3ft;
reg [11:0] adc_data_reg_prev;
wire CS_reg_st;
assign CS_reg_st = CS_reg_2ft && (!CS_reg_3ft);
always @(posedge clk_100) 
begin
	CS_reg_ft <= CS_reg; CS_reg_2ft <= CS_reg_ft; CS_reg_3ft <= CS_reg_2ft;
	if (CS_reg_st) begin
		adc_data_reg_prev <= adc_data_reg[11:0] + 12'd32;
		if (adc_data_reg[11:0] > adc_data_reg_prev) adc_data_trigger <= 1;
		else	adc_data_trigger <= 0;
	end
end

endmodule
