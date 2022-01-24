module arp_parser(
	input clock,
	input data_en,
	input sclr,
	input [7:0] data,
	output [31:0] PC_IP,
	output [31:0] BOARD_IP,
	output dataen

);
reg [31:00] PC_IP_reg, BOARD_IP_reg;
reg [5:0] counter = 0;
reg dataen_reg;

assign PC_IP=PC_IP_reg;
assign BOARD_IP = BOARD_IP_reg;
assign dataen = dataen_reg;

always @(posedge clock) begin
	if (sclr) begin
		dataen_reg <= 0;
		counter <= 0;
		BOARD_IP_reg <= 0;
		PC_IP_reg <= 0;
	end else begin
	if (data_en)
		counter <= counter+6'b1;
	else begin
		counter <= 0;
		dataen_reg <= 0;
	end
	case (counter)
		14: PC_IP_reg[31:24]<=data[7:0];
		15: PC_IP_reg[23:16]<=data[7:0];
		16: PC_IP_reg[15:8]<=data[7:0];
		17: PC_IP_reg[7:0]<=data[7:0];
		24: BOARD_IP_reg[31:24]<=data[7:0];
		25: BOARD_IP_reg[23:16]<=data[7:0];
		26: BOARD_IP_reg[15:8]<=data[7:0];
		27: BOARD_IP_reg[7:0]<=data[7:0];
		28: dataen_reg<=1;
	endcase
	end
end

endmodule
