`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:20:49 11/22/2021 
// Design Name: 
// Module Name:    MBO_uart 
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
module MBO_uart_rx#(parameter CLKS_PER_BIT=1)
(
	input i_Clock,
	input rst,
	input i_Rx_Serial,
	output reg o_Rx_DV,
	output [7:0] o_Rx_Byte_wire,
	output reg rx_Active
);

parameter 	s_IDLE			= 0,
			s_RX_START_BIT	= 1,
			s_RX_DATA_BITS	= 2,
			s_RX_STOP_BIT	= 3,
			s_CLEANUP		= 4;

(*IOB ="True"*) reg r_Rx_Data_R;
reg r_Rx_Data;
(*mark_debug = "true"*) reg [7:0] o_Rx_Byte_reg;
assign o_Rx_Byte_wire = o_Rx_Byte_reg;
(*mark_debug = "true"*) reg [7:0] r_Clock_Count;
(*mark_debug = "true"*) reg [2:0] r_SM_Main;
reg [7:0] o_Rx_Byte;

reg [2:0] r_Bit_Index;
reg stop_bit_true;

always @(posedge i_Clock or posedge rst)
begin
	if (rst) begin
		r_Rx_Data_R <= 1;
		r_Rx_Data 	<= 1;
	end
	else begin
		r_Rx_Data_R <= i_Rx_Serial;
		r_Rx_Data 	<= r_Rx_Data_R;
	end
end

// Purpose: Control RX state machine
always @(posedge i_Clock or posedge rst)
begin
	if (rst) begin
		r_SM_Main 	<= s_IDLE;
		o_Rx_DV 	<= 0;
		rx_Active 		<= 0;
	end
	else begin
		case (r_SM_Main)
		
			s_IDLE: begin
				o_Rx_DV 		<= 0;
				r_Clock_Count 	<= 0;
				r_Bit_Index 	<= 0;
				stop_bit_true <= 0;
	
				if (r_Rx_Data == 0) // Start bit detected
					r_SM_Main <= s_RX_START_BIT;
			end
			
			// Check middle of start bit to make sure it's still low
			s_RX_START_BIT: begin
				if (r_Clock_Count == (CLKS_PER_BIT-1)) begin
					r_Clock_Count 	<= 0; // reset counter, found the middle
					r_SM_Main 		<= s_RX_DATA_BITS;
					rx_Active 		<= 1;
				end
				else r_Clock_Count <= r_Clock_Count + 1;
			end
			
			s_RX_DATA_BITS: begin
				if (r_Clock_Count == (CLKS_PER_BIT-1)/2) 
					o_Rx_Byte[r_Bit_Index] <= r_Rx_Data;
				if (r_Clock_Count < CLKS_PER_BIT-1) 
					r_Clock_Count <= r_Clock_Count + 1;
				else begin
					r_Clock_Count <= 0;
					// Check if we have received all bits
					if (r_Bit_Index < 7) 
						r_Bit_Index <= r_Bit_Index + 1;
					else begin
						r_Bit_Index <= 0;
						r_SM_Main 	<= s_RX_STOP_BIT;
					end
				end
			end
			
			// Receive Stop bit. Stop bit = 1
			s_RX_STOP_BIT: begin
			// Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
				if (r_Clock_Count < (CLKS_PER_BIT-1)/2)
					r_Clock_Count <= r_Clock_Count + 1;
				else begin
					//if (stop_bit_true) o_Rx_DV <= 1;
					o_Rx_DV <= 1;
					o_Rx_Byte_reg <= o_Rx_Byte;
					r_Clock_Count 	<= 0;
					r_SM_Main 		<= s_CLEANUP;
				end
				//if (r_Clock_Count == 50) begin
				//	if (r_Rx_Data == 1)  stop_bit_true <= 1;
				//end
			end // case: s_RX_STOP_BIT
			
			// Stay here 1 clock
			s_CLEANUP: begin
				r_SM_Main 	<= s_IDLE;
				rx_Active 	<= 0;
				o_Rx_DV 		<= 0;
			end
	
			default: r_SM_Main <= s_IDLE;
			
		endcase
	end
end

endmodule