module convolution_block
#(
// 1 takt delay
parameter MULT_N = 50,
parameter NLOG = $clog2(MULT_N)
)
(
// INPUT
input 						clke,	// тактовая частота загрузки опоры из ethernet
input 						clkf,	// тактовая частота обработки
input 						rst,

input 						koef_en_in,
input 		[15:0] 			KOEF_IN,

input		[15:0]			DATA_IN_A,
input		[15:0]			DATA_IN_B,
input 		[NLOG-1:0]		ADDRB_RAMK,
// OUTPUT
// разрядность пока не огрубляем
output reg signed  [31:0] 	DATA_OUT_A, 
output reg signed  [31:0] 	DATA_OUT_B
);

// ====================== WIRES & REGS ========================================
reg		[NLOG-1:0] 	ADDRA_RAMK;
wire 	[15:0] 		Q_RAM_D;

// Двухпортовая память (50 слов x16)
MEM_OPORA_LCHM			RAM_K(
// INPUT
.clka					(clke),
.ena					(1'b1),//koef_en_in),
.wea					(koef_en_in),
.addra					(ADDRA_RAMK),
.dina					(KOEF_IN), // 16р
.clkb					(clkf),
.addrb					(ADDRB_RAMK),
// OUTPUT
.doutb					(Q_RAM_D)
);

always @(posedge clkf) begin
	DATA_OUT_A <= $signed(DATA_IN_A) * $signed(Q_RAM_D);
	DATA_OUT_B <= $signed(DATA_IN_B) * $signed(Q_RAM_D);
end

always @(posedge clke) begin
	if (rst) ADDRA_RAMK 	<= 0;
	else begin
		if (ADDRA_RAMK == MULT_N) ADDRA_RAMK <= 0; 
			else if (koef_en_in) ADDRA_RAMK <= ADDRA_RAMK + 1;
	end
end

endmodule