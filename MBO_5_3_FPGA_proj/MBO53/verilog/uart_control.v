module uart_control ( 
input 	clk,
input 	rst,
input 	rx_d,
output 	tx_d,
output laser_on

);
//___________________________________________________________________________________________

parameter LISTEN = 0, ANALYZE=1 , send =2, waiting =0 ;

(*mark_debug = "true"*)wire 			tx_done; 			// трансивер завершил передачу байта
(*mark_debug = "true"*)wire 			Rx_DV;   			// ресивер принял байт  
(*mark_debug = "true"*) wire 	[7:0] 	Rx_Byte; 			// принятый байт на выходе из ресивера	

wire [15:0] ram_data;
reg [7:0] tx_data = 8'hd0;
(*mark_debug = "true"*)reg [31:00] data_in_reg,data_in_uart;
(*mark_debug = "true"*)reg [15:0] ram_din;
(*mark_debug = "true"*)reg [7:0] ram_addr;
(*mark_debug = "true"*)reg [2:0] UART_STATE,data_in_counter,send_cnt,send_case;
(*mark_debug = "true"*) reg wea,start_uart_strob,uart_start, uart_start_ft;
//___________________________________________________________________________________________
// speed 115200
(*keep_hierarchy="yes"*) 
MBO_uart_tx #(186)uart_tx 
(
.i_Clock		(clk),
.rst 			(rst),
.i_Tx_DV		(uart_start),
.i_Tx_Byte		(data_in_uart[31:24]), 

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
	
	/*uart_start_ft <= uart_start;
	if ( uart_start_ft ) uart_start <= 0;*/
	
	case ( UART_STATE) 
	
	LISTEN: begin
		if ( Rx_DV) begin 
			data_in_reg[7:0] <= Rx_Byte;
			data_in_reg[31:8] <= data_in_reg [23:0];
			data_in_counter <= data_in_counter+1;
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
				
				//режим отправки
				if ((data_in_reg[23:16] == 8'h00)) begin 
					if ((data_in_reg[11:08] == 4'h1)) begin 
						UART_STATE <= SEND;
						start_uart_strob <= 1; // строб запуска отправки
					end
				
				end
				else UART_STATE <= LISTEN;
				
			end
		else begin
				wea <=0;
				ram_addr <= data_in_reg[23:16];
				start_uart_strob <= 1; // строб запуска отправки
				send_case <= send;
				
				//debug part
				data_in_uart <= {8'hff,ram_addr,ram_data};
				UART_STATE <= LISTEN;
			end
		
		
		
	end
	
	SEND:	begin 
	
		// слушаем что приходит 
		
		if ( Rx_DV) begin 
			data_in_reg[7:0] <= Rx_Byte;
			data_in_reg[31:8] <= data_in_reg [23:0];
			data_in_counter <= data_in_counter+1;
		end
		
		if (data_in_counter == 4) begin
			data_in_counter <=0;
			if (data_in_reg[24] && (data_in_reg[23:16] == 8'h00) && (data_in_reg[11:08] == 4'h0)) UART_STATE <= LISTEN;
		end
		
		wea <=0;
		
		
		
		
	
	end
	
	
	endcase
	
	if ( start_uart_strob ) begin
		
		
		case ( send_case) 
		
		send: begin 
				uart_start <= 1;
				send_case <= waiting;
			end
			
		waiting: begin 
				if ( tx_done) begin
					if ( send_cnt == 3) begin send_cnt <= 0;start_uart_strob <= 0;  end
					else begin send_cnt <= send_cnt+1; send_case <= send; data_in_uart <= data_in_uart << 8 ;end
				end
				
				uart_start <= 0;
				
			end
		endcase
	end
	
end

endmodule