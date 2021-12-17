module FourToEight (
	input clock,
	input [3:0] datain,	//входящие данные 4-bit 25MHz
	input ena,			//строб сопровождения входящих данных
	output reg [7:0] dataout,	//данные сконвертированные в 8-bit 12.5 MHz
	output ren,					//строб сопровождения сконвертированных данных
	output reg error_pzdc		//флаг ошибки конвертации (захвачен лишний или пропущен один или несколько тактов информации)
);

reg [7:0] datastorage;
reg state;
reg ena_ft;
reg [9:0] cnt_w;


wire clk_n;
assign clk_n = ~clock;
assign ren = ena_ft & ~state;

reg ena_posedge;

always @(posedge clock) begin
	ena_posedge <= ena;
end

always @(posedge clk_n) begin
	
	if (ena_posedge) begin
		state <= ~state;
		datastorage[3:0] <= datastorage[7:4];
		datastorage[7:4] <= datain[3:0];
	end
	else begin
		datastorage <= 0;
		state <= 1;
	end
	
	ena_ft <= ena_posedge;
	if (!ena_ft) cnt_w <= 0; 
	else if (ren) begin
		dataout <= datastorage;
		cnt_w <= cnt_w + 1'b1;
	end
	
	if (!ena_posedge) error_pzdc <= 0; 
	else if ((cnt_w == 2) && (dataout != 8'h55)) error_pzdc <= 1;
	else if ((cnt_w < 10) && (dataout == 8'h55) && (datastorage[3:0] == 4'hD)) error_pzdc <= 1;

end

endmodule