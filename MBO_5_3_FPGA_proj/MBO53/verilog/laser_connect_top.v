module laser_connect_top(
input 	pll_rst,
input 	clk,
input 	rx_d,
input 	laser_on, // 1 - вкл, 0 - выкл

output 	tx_d,
output 	reg laser_connected,
output	reg laser_on_status,
output 	reg error_uart
);

parameter 	IDLE 				= 0,
			READ_ROM 			= 1, 
			UART_WRITE	 		= 2,
			UART_READ	 		= 3,			
			UART_PAUSE 			= 4, 
			UART_WAITING		= 5,
			UART_ANALYSE		= 6,
			UART_CHECK_STATUS	= 7;
			
parameter 	INIT_WORDS 	= 24,  // количество слов для инициализации лазера (включая промежуточные для фиксации ответа лазера)
			OFF_WORDS 	= 6;   // количество слов для выключения лазера

//счетчик отсрочки формирования строба начала процедуры инициализации лазера
wire 			tx_done; 			// трансивер завершил передачу байта
wire 			Rx_DV;   			// ресивер принял байт
(*mark_debug = "true"*) wire 	[7:0] 	Rx_Byte; 			// принятый байт на выходе из ресивера	
reg 	[4:0] 	rom_addr;			// шина адреса на входе ROM
reg 	[1:0] 	cnt_wait_rom;		// пауза для того, чтобы память успела установить данные по заданному адресу
wire 	[31:0] 	rom_data;			// шина данных на выходе ROM
reg 	[31:0] 	uart_data_reg;		// сдвиговый регистр для отправки по байту 32-разрядного слова
reg 			laser_on_ft; 		// сдвинутый на такт строб инициализации (включения) лазера
wire 			laser_init, 	
				laser_off;			// фронт и спад строба инициализации (включения) лазера
reg 			laser_off_comand;	// выставление флага на выключение лазера
reg 			laser_init_comand;	// выставление флага на инициализацию лазера
reg 			start_uart_strob;	// команда для трансивера на отправку байта
reg 	[31:0] 	word_read;			// слово считанное из лазера
(*mark_debug = "true"*) reg 	[2:0] 	uart_cntrl_st;		// state-machine для управления лазером
(*mark_debug = "true"*) reg 	[2:0] 	cnt_send_b;			// счетчик отправленных байтов из 4-байтного слова
(*mark_debug = "true"*) reg 	[2:0] 	cnt_read_b;			// счетчик считанных байтов из 4-байтного слова
(*mark_debug = "true"*) reg 	[4:0] 	cnt_words;			// счетчик слов для отправки внутри команды инициализации или выключения лазера
reg 	[24:0] 	cnt_wait_read;		// счетчик ожидания ответа от лазера
reg 	[23:0]  cnt_pause;

wire tx_d_uart;
reg flag_uart_reset;
assign tx_d = (flag_uart_reset)? 0: tx_d_uart;
(*keep_hierarchy="yes"*) 
MBO_uart_tx #(186)uart_tx 
(
.i_Clock		(clk),
.rst 			(pll_rst),
.i_Tx_DV		(start_uart_strob),
.i_Tx_Byte		(uart_data_reg[31:24]), 

.o_Tx_Active	(), 
.o_Tx_Serial	(tx_d_uart), 
.o_Tx_Done		(tx_done)	
);

(*keep_hierarchy="yes"*) 
MBO_uart_rx #(186)uart_rx 
(
.i_Clock		(clk),
.rst			(pll_rst),
.i_Rx_Serial	(rx_d), //строб начала выдачи данных

.o_Rx_DV		(Rx_DV),	// строб окончания передачи
.o_Rx_Byte_wire	(Rx_Byte),
.rx_Active 		()
);

ROM_UART_DATA uart_data_rom(
.clka  (clk),
.addra (rom_addr),
.douta (rom_data)
);

assign laser_init = laser_on & (!laser_on_ft);
assign laser_off = laser_on_ft & (!laser_on);

always @(posedge clk or posedge pll_rst) begin
	if (pll_rst) begin
		uart_cntrl_st 		<= IDLE;
		start_uart_strob 	<= 0;
		cnt_wait_rom		<= 0;
		laser_off_comand	<= 0;
		laser_init_comand 	<= 0;
		laser_on_status		<= 0;
		error_uart			<= 0;
		cnt_wait_read		<= 0;
		flag_uart_reset 	<= 0;
	end
	else begin
	
		laser_on_ft <= laser_on;
		
		case (uart_cntrl_st)
		
			IDLE: begin
				cnt_words 		<= 0;
				cnt_send_b 		<= 0;
				cnt_read_b 		<= 0;
				flag_uart_reset <= 0;
				
				if (laser_off) laser_off_comand <= 1;
				if (laser_init) laser_init_comand <= 1;
				
				if (laser_init_comand) begin
					cnt_wait_rom 	<= cnt_wait_rom + 1;
					rom_addr 		<= 0;
					if (&cnt_wait_rom) begin
						uart_cntrl_st <= READ_ROM;
						uart_data_reg <= rom_data;
					end
				end
				else if (laser_off_comand) begin
					cnt_wait_rom 	<= cnt_wait_rom + 1;
					rom_addr 		<= 24;
					if (&cnt_wait_rom) begin
						uart_cntrl_st <= READ_ROM;
						uart_data_reg <= rom_data;
					end
				end
				
			end
			
			READ_ROM: begin
				rom_addr <= rom_addr + 1;
				// по идее в 26 бите флаг того, что отвечает модуль хосту
				// поэтому если мы видим, что из памяти торчит это слово, значит мы должны прочитать
				// что ответил лазер
				if (uart_data_reg[26]) uart_cntrl_st <= UART_READ; 
				else uart_cntrl_st <= UART_WRITE;
			end
			
			UART_WRITE: begin
				start_uart_strob 	<= 1;
				cnt_send_b 			<= cnt_send_b + 1;				
				uart_cntrl_st 		<= UART_WAITING;
			end
			
			UART_READ: begin
				if (cnt_wait_read[24]) begin
					uart_cntrl_st <= IDLE;
					laser_connected <= 0;
					error_uart <= 1;
					cnt_wait_read <= 0;
					//word_read[31:0] <= 32'hDEADBEEF;
				end
				else if (Rx_DV) begin
					laser_connected <= 1; 
					cnt_read_b <= cnt_read_b + 1;
					word_read[31:0] <= {word_read[23:0], Rx_Byte[7:0]};
					cnt_wait_read <= 0;
					if (cnt_read_b == 3) uart_cntrl_st <= UART_PAUSE;					
				end
				else cnt_wait_read <= cnt_wait_read + 1;
			end
			
			UART_WAITING: begin
				start_uart_strob <= 0;
				if (tx_done) begin
					uart_data_reg <= uart_data_reg << 8;
					if (cnt_send_b == 4) uart_cntrl_st <= UART_ANALYSE; // UART_PAUSE
					else uart_cntrl_st <= UART_WRITE;
				end
			end
			
			UART_CHECK_STATUS: begin
				cnt_read_b <= 0;
				if ((word_read[23:16] == 0) && (word_read[3:0] != 0)) begin
					if (cnt_wait_read == 0) rom_addr <= rom_addr - 2; 
					cnt_wait_read <= cnt_wait_read + 1;
					if (&cnt_wait_rom) begin
						uart_cntrl_st <= READ_ROM;
						uart_data_reg <= rom_data;
						cnt_words <= cnt_words - 1;
					end
				end
				else uart_cntrl_st <= UART_ANALYSE;
			end
			
			// pause 0.5sec
			UART_PAUSE: begin
				if (cnt_pause[20]) begin
					cnt_pause <= 0;
					uart_cntrl_st <= UART_ANALYSE;
				end	
				else cnt_pause <= cnt_pause + 1;
			end
			
			UART_ANALYSE: begin
				uart_data_reg <= rom_data;
				cnt_send_b <= 0;
				cnt_read_b <= 0;
				cnt_words <= cnt_words + 1;
				if (laser_init_comand && (cnt_words == INIT_WORDS - 1)) begin
					uart_cntrl_st 		<= IDLE;
					laser_init_comand 	<= 0;
					laser_on_status		<= 1;
					cnt_wait_rom		<= 0;
				end
				else if (laser_off_comand && (cnt_words == OFF_WORDS - 1)) begin
					uart_cntrl_st 		<= IDLE;
					laser_off_comand 	<= 0;
					laser_on_status		<= 0;
					cnt_wait_rom		<= 0;
				end
				else uart_cntrl_st <= READ_ROM;
			end
			
			
		endcase
	end
end
	
endmodule