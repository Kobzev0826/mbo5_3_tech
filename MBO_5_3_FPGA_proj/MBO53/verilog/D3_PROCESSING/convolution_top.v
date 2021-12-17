// На вход блока свертки подаются отчеты АЦП (доп. код) с двух каналов на частоте 1 МГц.
// Если говорить об экспериментальном АЦП (12 разрядов, 5 МГц), то отчеты необходимо 
// проредить в 5 раз и поднять разрядность до 16.
// Кроме АЦПшных данных сюда же грузится опора с эзернета

module convolution_top
(
// ==================== INPUT ===================================
input 						clks, // 1 MHZ
input 						clkf, // 50 MHz уменьшим число умножителей в 50 раз
input 						clke, // клок эзернета для записи опары из ПК в память блока свертки
input 						rst, // глобальный асинхронный сброс
	// Записать опору в блок из ПК
input 						opora_en, // строб сопровождающий запись опоры в память
input 		[15:0] 			OPORA, // Опора из ПК

	// предполагается, что данные с ацп снхронизированы как-то в фифо или еще как
input 						data_in_en,
input		[15:0]			DATA_IN_A, // данные с АЦП1
input		[15:0]			DATA_IN_B, // данные с АЦП2

input 		[15:0] 			FIX_POROG,
output 		[4:0] 			data_read_cnt,

output 		[4:0] 			data_write_cnt,

// ==================== OUTPUT ===================================
//output 					data_out_en,
output [15:0] 				DATA_OUT_A,	//{real, image}
output [15:0] 				DATA_OUT_B,	//{real, image}
	
output reg [15:0]			SUB_TA_TB,
output reg					SUB_TA_TB_en,
	
output reg [15:0] 			CH_A_EXTREMUM,
output reg					ch_a_extremum_en,
output reg [15:0] 			CH_B_EXTREMUM,
output reg					ch_b_extremum_en
);

parameter N = 4;  // количество блоков свертки. 200/50 = 4. Чем выше частота тем меньше блоков. 
// Чем длинее опора, тем больше блоков. На данный момент считаю опору равной 200, а частоту 50 МГц
parameter MULT_N = 25; // во сколько раз частота clkf превосходит clks
parameter NLOG = $clog2(MULT_N); // некоторые регистры будут иметь разрядность ориентируясь на MULT_N
parameter CELL = 18+NLOG;

localparam NUM_OPORA = 200; // сделал намек на параметризуемость, но пока лучше не пытаться менять.

// ====================== WIRES & REGS ========================================

reg [7:0] 					cnt_opora;
reg 						read_conv;
reg	[MULT_N:0]				read_buf;
reg [NLOG-1:0] 				cnt_x_rate;
reg [NLOG-1:0] 				cnt_x_rate_50ft;
wire 						t_acc;
reg 						t_acc_1ft, t_acc_2ft, t_acc_3ft, t_acc_4ft;
wire [N-1:0]				koef_en;

reg [31:0]	DATA_REG	[N-1:0][MULT_N:0];

wire [31:0] Q_RAM_D;
//wire [4:0] 	data_read_cnt;
//
//wire [4:0] data_write_cnt;

wire [31:0] Q_CONV_CORE_A [(N-1):0];
wire [31:0] Q_CONV_CORE_B [(N-1):0];

reg signed [32:0] 	SUM_1_chA; 
reg signed [32:0] 	SUM_2_chA;
reg signed [33:0] 	SUM_3_chA;

reg signed [32:0] 	SUM_1_chB; 
reg signed [32:0] 	SUM_2_chB;
reg signed [33:0] 	SUM_3_chB;

reg signed [33+NLOG:0]	acc_chA;
reg signed [33+NLOG:0]	acc_chB;

wire [15:0] conv_in_chA;
wire [15:0] conv_in_chB;

reg [15:0] DATA_OUT_A_1ft, DATA_OUT_A_2ft;
reg [15:0] DATA_OUT_B_1ft, DATA_OUT_B_2ft;

reg	[31:0] cnt_sub;

integer i, j, k, h;

// ======================= BUFFERS ==============================================

// FIFO на вход (16 слов, 32 разряда)
FIFO_CONV_IN 				DATA_BUFFER(
    .rst					(rst),
    .wr_clk					(clks),
    .rd_clk					(clkf),
    .din					({DATA_IN_A, DATA_IN_B}),
    .wr_en					(data_in_en),
    .rd_en					(read_buf[0] && (cnt_x_rate == 0)),
    .dout					(Q_RAM_D),
    .rd_data_count			(data_read_cnt)
);


assign conv_in_chA = acc_chA[33+NLOG-CELL:18+NLOG-CELL];
assign conv_in_chB = acc_chB[33+NLOG-CELL:18+NLOG-CELL];

// FIFO на выход (16 слов, 16 разрядов на каждый канал - итого, x32)
FIFO_CONV_OUT 				CONV_BUFFER(
    .rst					(rst),
    .wr_clk					(clkf), 
    .rd_clk					(clks),
    .din					({conv_in_chA, conv_in_chB}),
    .wr_en					(t_acc_4ft), // будет запись 1 раз в 50 тактов частоты clkf
    .rd_en					(read_conv), // будет чтение каждый такт на частоте clks
    .dout					({DATA_OUT_A, DATA_OUT_B}),
    .rd_data_count			(data_write_cnt)
);

// ============================ Processing ============================================

always @(posedge clke or posedge rst) begin
	if (rst) cnt_opora <= 0;
	else begin
	// вводится счетчик со сбросом на запись опоры, чтобы была возможность повторно перезаписать массив опоры
		if (cnt_opora == NUM_OPORA) cnt_opora <= 0;     
        else if (opora_en) cnt_opora <= cnt_opora + 1;
	end
end	

always @(posedge clks or posedge rst) begin
	if (rst) read_conv		<= 0;
	else begin	
	// чтение результата свертки из буфера (будем считать данные на выход по факту наличия 6 слов в фифо)
		if (data_write_cnt > 5) read_conv <= 1;
		else read_conv <= 0;
	end
end 

assign t_acc = (cnt_x_rate_50ft == 1); 

always @(posedge clkf or posedge rst) begin
	if (rst) begin	
		read_buf[0]	<= 0;
		cnt_x_rate 	<= 0;	
	end
	else begin
		t_acc_1ft <= t_acc; t_acc_2ft <= t_acc_1ft; t_acc_3ft <= t_acc_2ft; t_acc_4ft <= t_acc_3ft;
	
		if (data_read_cnt > 5) read_buf[0] <= 1;
		//else read_buf[0] <= 0;
		
		if (cnt_x_rate == MULT_N-1) cnt_x_rate <= 0;
		else if (read_buf[0]) cnt_x_rate <= cnt_x_rate + 1;
		else cnt_x_rate <= 0;	
		
		for (k=1; k<MULT_N+1; k=k+1) read_buf[k] <= read_buf[k-1];
		
		if (cnt_x_rate == MULT_N-1) cnt_x_rate_50ft <= 0;
		else if (read_buf[MULT_N]) cnt_x_rate_50ft <= cnt_x_rate_50ft + 1;
		else cnt_x_rate_50ft <= 0;

		if (cnt_x_rate == 1) DATA_REG[0][0][31:00] <= Q_RAM_D[31:00];
			else DATA_REG[0][0][31:00] <= DATA_REG[0][MULT_N][31:00];
		
		for (i=1; i<N; i=i+1) begin
			if (cnt_x_rate == 1) DATA_REG[i][0][31:00] <= DATA_REG[i-1][0][31:00];
			else DATA_REG[i][0][31:00] <= DATA_REG[i][MULT_N][31:00];
		end
		for (j=0; j<N; j=j+1) begin
			for (i=1; i<MULT_N+1; i=i+1)
			DATA_REG[j][i][31:00] <= DATA_REG[j][i-1][31:00];
		end
	end
end

genvar a;
generate
	for (a=0; a<N; a=a+1) begin: GEN_N_BLOCKS
	
	assign koef_en[a] = opora_en && (cnt_opora < ((a+1)*MULT_N)) && (cnt_opora >= (a*MULT_N) && (cnt_opora<100));
	// 6 taktov for fix
		convolution_block	#( 
		.MULT_N			(MULT_N),
		.NLOG			(NLOG))
		CONV_CORE(
		// INPUT
			.clke					(clke),
			.clkf					(clkf),
			.rst					(rst),
			.koef_en_in				(koef_en[a]),
			.KOEF_IN				(OPORA),
			.DATA_IN_A				(DATA_REG[a][0][31:16]),
			.DATA_IN_B				(DATA_REG[a][0][15:0]),
			.ADDRB_RAMK				(cnt_x_rate_50ft),
		// OUTPUT
			.DATA_OUT_A				(Q_CONV_CORE_A[a]),
			.DATA_OUT_B				(Q_CONV_CORE_B[a])
		);	
		
	end
endgenerate

// для параллельного сумматора не скэйлю N
always @(posedge clkf) begin
	SUM_1_chA[32:0] <= $signed(Q_CONV_CORE_A[0][31:0]) + $signed(Q_CONV_CORE_A[1][31:0]);
	SUM_2_chA[32:0] <= $signed(Q_CONV_CORE_A[2][31:0]) + $signed(Q_CONV_CORE_A[3][31:0]);
	SUM_3_chA[33:0] <= SUM_1_chA[32:0] + SUM_2_chA[32:0];
	
	SUM_1_chB[32:0] <= $signed(Q_CONV_CORE_B[0][31:0]) + $signed(Q_CONV_CORE_B[1][31:0]);
	SUM_2_chB[32:0] <= $signed(Q_CONV_CORE_B[2][31:0]) + $signed(Q_CONV_CORE_B[3][31:0]);
	SUM_3_chB[33:0] <= SUM_1_chB[32:0] + SUM_2_chB[32:0];
end


always @(posedge clkf)
begin
	if (t_acc_4ft) begin
			acc_chA 	<= $signed({{NLOG{SUM_3_chA[33]}},	SUM_3_chA[33:0]});
			acc_chB 	<= $signed({{NLOG{SUM_3_chB[33]}},	SUM_3_chB[33:0]});
	end
	else begin
			acc_chA 	<= acc_chA 	+ $signed({{NLOG{SUM_3_chA[33]}},	SUM_3_chA[33:0]});
			acc_chB 	<= acc_chB 	+ $signed({{NLOG{SUM_3_chB[33]}},	SUM_3_chB[33:0]});
	end
end

always @(posedge clks)
begin
	DATA_OUT_A_1ft <= DATA_OUT_A; DATA_OUT_A_2ft <= DATA_OUT_A_1ft;
	if ( (DATA_OUT_A_1ft > DATA_OUT_A_2ft) && (DATA_OUT_A_1ft < DATA_OUT_A) && (DATA_OUT_A_1ft > FIX_POROG))
	begin
		ch_a_extremum_en <= 1; CH_A_EXTREMUM <= DATA_OUT_A_1ft; cnt_sub <= 0;
	end
	else begin ch_a_extremum_en <= 0; cnt_sub <= cnt_sub + 1; end
	
	DATA_OUT_B_1ft <= DATA_OUT_B; DATA_OUT_B_2ft <= DATA_OUT_B_1ft;
	if ( (DATA_OUT_B_1ft > DATA_OUT_B_2ft) && (DATA_OUT_B_1ft < DATA_OUT_B) && (DATA_OUT_B_1ft > FIX_POROG))
	begin
		ch_b_extremum_en <= 1; CH_B_EXTREMUM <= DATA_OUT_B_1ft; 
		if (cnt_sub > 16'hFFFF) SUB_TA_TB <= 16'hFFFF;
		else SUB_TA_TB <= cnt_sub[15:0];	
		SUB_TA_TB_en <= 1;
	end
	else begin ch_b_extremum_en <= 0; SUB_TA_TB_en <= 0; end
end
	

endmodule