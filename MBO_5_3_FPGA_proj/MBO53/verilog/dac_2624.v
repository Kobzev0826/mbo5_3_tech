`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:39:11 12/12/2021 
// Design Name: 
// Module Name:    dac_2624 
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
module dac_2624 #(parameter [3:0]address=4'd0, parameter [3:0] command=4'b0011)
(

	input clk,
	input rst, 
	input i_dac_start,
	input [11:00] dac_data,
	
	output spi_mosi,
	output dac_cs, // high min 10 ns
	output spi_sck, //min T=20ns
	output dac_clr,
	input spi_miso
    );

reg [31:00] data_reg;
reg CS_reg, spi_strob;
reg [5:0] dac_cycle_counter;

assign spi_mosi = data_reg[31];
assign spi_sck = spi_strob? ~clk:0;
assign dac_cs = CS_reg;

always @(posedge clk) begin

	if ( rst) begin 
		dac_cycle_counter <=6'd0;
		/*CS_reg <=1;
		spi_strob <=0;
		data_reg <= 32'd0;*/
	end
	else begin
		if ( i_dac_start) begin 
			if ( dac_cycle_counter == 6'd 33 )dac_cycle_counter <=0;
			else dac_cycle_counter <= dac_cycle_counter + 1;
			
			if ( spi_strob) data_reg [31:01] <= data_reg [30:00];
			
		end
		else begin 
			dac_cycle_counter <=0;
			/*CS_reg <=1;
			spi_strob <=0;
			data_reg <= 32'd0;*/
		end
	
	end
	
	case ( dac_cycle_counter) 
				
				00: begin 
						CS_reg <=1;
						spi_strob <=0;
						data_reg <= 32'd0;
					end
				02: begin 	data_reg[23:20]<= command; 
							data_reg[19:16]<= address; 
							data_reg[15:4] <= dac_data;
							CS_reg <=0;
							spi_strob <=1;
					end
				//34: CS_reg <=1;
				
	endcase
end

endmodule
