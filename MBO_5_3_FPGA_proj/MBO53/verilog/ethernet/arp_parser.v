module arp_parser(
	input clock, 
	input data_en, //входящая информация ЯВЛЯЕТСЯ ARP-запросом
	input sclr,
	input [7:0] data, //входящая информация
	output reg [31:0] PC_IP, //IP общающегося с нами устройства
	output reg [31:0] BOARD_IP,	//IP устройства к которому обращаются в запросе
	output reg dataen //оба IP успешно выдраны из запроса
);

reg [4:0] counter;

always @(posedge clock) begin
	if (sclr) begin
		dataen 		<= 0;
		counter 	<= 0;
		BOARD_IP 	<= 0;
		PC_IP 		<= 0;
	end else begin
	
		if (data_en)
			counter <= counter + 1'b1;
		else begin
			counter <= 0;
			dataen <= 0;
		end
	
		case (counter)
			14: PC_IP[31:24]	<= 	data[7:0];
			15: PC_IP[23:16]	<=	data[7:0];
			16: PC_IP[15:8]		<=	data[7:0];
			17: PC_IP[7:0]		<=	data[7:0];
			24: BOARD_IP[31:24]	<=	data[7:0];
			25: BOARD_IP[23:16]	<=	data[7:0];
			26: BOARD_IP[15:8]	<=	data[7:0];
			27: BOARD_IP[7:0]	<=	data[7:0];
			28: dataen <= 1;
		endcase
	end
end

endmodule
