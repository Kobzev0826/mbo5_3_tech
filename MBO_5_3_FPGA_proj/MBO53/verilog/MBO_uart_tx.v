`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:49:25 11/23/2021 
// Design Name: 
// Module Name:    MBO_uart_tx 
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


module MBO_uart_tx #(parameter CLKS_PER_BIT=1)
(
	input 		i_Clock,
	input 		rst,
	input 		i_Tx_DV,
	input [7:0] i_Tx_Byte,
	
	output reg o_Tx_Active,
	output reg o_Tx_Serial,
	output reg o_Tx_Done
);

parameter 	IDLE 					= 0, 
				s_TX_START_BIT 	= 1, 
				s_TX_DATA_BITS 	= 2, 
				s_TX_STOP_BIT 		= 3, 
				s_CLEANUP 			= 4;

(*mark_debug = "true"*) reg [2:0] 	r_SM_Main;
(*mark_debug = "true"*) reg [7:0] 	r_Clock_Count;	
(*mark_debug = "true"*) reg [2:0] 	r_Bit_Index;
(*mark_debug = "true"*) reg [7:0] 	r_Tx_Data;
(*mark_debug = "true"*) reg [4:0]	cnt_wait;

always @(posedge i_Clock or posedge rst)
begin 
	if (rst) begin
		r_SM_Main 	<= IDLE;
		o_Tx_Done 	<= 0;
		o_Tx_Active <= 0;
		o_Tx_Serial <= 1;
	end
	else begin
		case(r_SM_Main)
		
			IDLE: begin
				o_Tx_Serial 	<= 1;
				o_Tx_Done 		<= 0;
				r_Clock_Count 	<= 0;
				r_Bit_Index 	<= 0;
				cnt_wait 		<= 0;
				if (i_Tx_DV) begin 
					o_Tx_Active <= 1;
					r_Tx_Data <= i_Tx_Byte;
					r_SM_Main <= s_TX_START_BIT;
				end
			end
			
			s_TX_START_BIT: begin
				o_Tx_Serial <= 0;
				if (r_Clock_Count < CLKS_PER_BIT-1) 
					r_Clock_Count <= r_Clock_Count+1;
				else begin 
					r_Clock_Count <= 0;
					r_SM_Main <= s_TX_DATA_BITS;
				end
			end
			
			s_TX_DATA_BITS: begin
				o_Tx_Serial <= r_Tx_Data[r_Bit_Index];
				if (r_Clock_Count < CLKS_PER_BIT-1)
					r_Clock_Count	<= r_Clock_Count +1;
				else begin
					r_Clock_Count <= 0;
					if (r_Bit_Index < 7) 
						r_Bit_Index <= r_Bit_Index + 1;
					else begin
						r_Bit_Index <= 0;
						r_SM_Main	<= s_TX_STOP_BIT;
					end
				end
			end
			
			s_TX_STOP_BIT: begin
				o_Tx_Serial <= 1;
				if (r_Clock_Count < CLKS_PER_BIT-1) 
					r_Clock_Count 	<= r_Clock_Count + 1;
				else begin
					o_Tx_Active		<= 0;
					r_Clock_Count	<= 0;
					r_SM_Main		<= s_CLEANUP;
				end
			end
			
			s_CLEANUP: begin
				o_Tx_Done <= 1;
				r_SM_Main <= IDLE;
			end
			
			default: r_SM_Main <= IDLE;
			
		endcase
	end
end
	


endmodule