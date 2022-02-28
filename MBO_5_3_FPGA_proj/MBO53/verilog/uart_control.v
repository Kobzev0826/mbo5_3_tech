module uart_control ( 
input 	clk,
input 	rst,
input 	rx_d,
output 	tx_d,
output laser_on

);
//___________________________________________________________________________________________

parameter LISTEN = 0, ANALYZE=1;

(*mark_debug = "true"*)wire 			tx_done; 			// трансивер завершил передачу байта
(*mark_debug = "true"*)wire 			Rx_DV;   			// ресивер принял байт  
(*mark_debug = "true"*) wire 	[7:0] 	Rx_Byte; 			// принятый байт на выходе из ресивера	

wire [7:0] ram_data;
(*mark_debug = "true"*)reg [31:00] data_in_reg;
(*mark_debug = "true"*)reg [15:0] ram_din;
(*mark_debug = "true"*)reg [7:0] ram_addr;
(*mark_debug = "true"*)reg [2:0] UART_STATE,data_in_counter;
(*mark_debug = "true"*) reg wea,start_uart_strob;
//___________________________________________________________________________________________
// speed 115200
(*keep_hierarchy="yes"*) 
MBO_uart_tx #(186)uart_tx 
(
.i_Clock		(clk),
.rst 			(rst),
.i_Tx_DV		(start_uart_strob),
.i_Tx_Byte		(ram_data), 

.o_Tx_Active	(), 
.o_Tx_Serial	(tx_d), 
.o_Tx_Done		(tx_done)	
);

(*keep_hierarchy="yes"*) 
MBO_uart_rx #(186)uart_rx 
(
.i_Clock		(clk),
.rst			(rst),
.i_Rx_Serial	(rx_d), //строб начала выдачи данных

.o_Rx_DV		(Rx_DV),	// строб окончания передачи
.o_Rx_Byte_wire	(Rx_Byte),
.rx_Active 		()
);

(*keep_hierarchy="yes"*) 
RAM_control_data(
.clka	(clk),
.wea	(wea),
.dina	(ram_din),
.addra	(ram_addr),

.douta	(ram_data)
);

//___________________________________________________________________________________________
//-------------------MAIN LOGIC-------------------------------------

always @(posedge clk ) begin 
	
	case ( UART_STATE) 
	
	LISTEN: begin
		if ( Rx_DV) begin 
			data_in_reg[7:0] <= Rx_Byte;
			data_in_reg[31:8] <= data_in_reg [23:0];
			data_in_counter <= data_in_counter;
		end
		
		if (data_in_counter == 4) begin
			data_in_counter <=0;
			UART_STATE <= ANALYZE;
		end
		
		wea <=0;
	end
	
	ANALYZE: begin 
		// пришла команда на запись
		if ( data_in_reg[24])begin
				wea <=1;
				ram_din <= data_in_reg[15:00];
				ram_addr <= data_in_reg[23:16];
			end
			else begin
				wea <=0;
				ram_addr <= data_in_reg[23:16];
				start_uart_strob <= 1;
			end
	
	end
	
	endcase
	
	if ( tx_done) start_uart_strob <= 0; 
	
	
	
end

endmodule