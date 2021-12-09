module FourToEight (
	input clock,
	input [3:0] datain,
	input ena,
	output reg [7:0] dataout,
	output ren,
	output reg error_pzdc
);

reg [7:0] datastorage;
reg state;
reg ena_ft;
reg [9:0] cnt_w;

//assign ren = ~state;
wire clk_n;
assign clk_n = ~clock;
assign ren = ena_ft & ~state;

always @(posedge clk_n) begin
	
	if (ena) begin
		state <= ~state;
		datastorage[3:0] <= datastorage[7:4];
		datastorage[7:4] <= datain[3:0];
	end
	else begin
		datastorage <= 0;
		state <= 0;
	end
	
	ena_ft <= ena;
	if (!ena_ft) cnt_w <= 0; 
	else if (ren) begin
		dataout <= datastorage;
		cnt_w <= cnt_w + 10'b1;
	end
	
	if (!ena) error_pzdc <= 0; 
	else if ((cnt_w == 1) && (dataout != 8'h55)) error_pzdc <= 1;  
	//if (state) begin
	//	dataout[7:0]<=datastorage[7:0];
	//	datastorage[3:0]<=datain[3:0];
	//end
	//datastorage[7:4]<=datain[3:0];
	//if (ena) state = ~state; else state<=0;

end

endmodule