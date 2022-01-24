module FourToEight (
	input clock,
	input [3:0] datain,			//входящие данные 4-bit 25MHz
	input ena,					//строб сопровождения входящих данных
	output [7:0] dataout,	//данные сконвертированные в 8-bit 12.5 MHz
	output wren,					//строб сопровождения сконвертированных данных
	output reg error_pzdc		//флаг ошибки конвертации (захвачен лишний или пропущен один или несколько тактов информации)
);

reg [7:0] datastorage;
reg state;
reg state_ft;
reg ena_ft;

assign dataout = datastorage;

wire clk_n;
assign clk_n = ~clock;
assign wren = flag_End_of_Sync & state_ft;

reg ena_posedge;

always @(posedge clock) begin
	ena_posedge <= ena;
end

wire flag_End_of_Sync;
reg EOS;
assign flag_End_of_Sync = EOS;

always @(posedge clk_n) begin
	state_ft <= state;
	ena_ft <= ena_posedge;
	if (ena_posedge) begin
		if (EOS) begin
			state <= ~state;
			datastorage[3:0] <= datastorage[7:4];
			datastorage[7:4] <= datain[3:0];
		end else begin
			state <= 0;
			datastorage[3:0] <= datain[3:0];
			if ((datastorage[3:0] == 4'h5) && (datain[3:0] == 4'hD)) begin
				EOS <= 1;
			end
		end
	end else begin
		EOS <= 0;
		datastorage[7:0] <= 0;
		state <= 0;
	end
	if (ena_ft && ~ena_posedge) begin
		if (state) begin
			error_pzdc <= 1;
		end else begin
			error_pzdc <= 0;
		end
	end else if (~ena_ft) error_pzdc <= 0;
end

endmodule