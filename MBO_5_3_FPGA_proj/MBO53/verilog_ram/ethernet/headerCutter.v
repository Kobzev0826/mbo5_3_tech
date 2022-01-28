module headerCutter(
	input [7:0] datain, //входящая информация
	input data_en,		//входящая информация ЯВЛЯЕТСЯ Ethernet-фреймом
	input clock,
	output reg mac_wren,
	output reg isIp,				//строб сопровождения протокола IP
	output reg isARP,				//строб сопровождения протокола ARP
	output reg isNotAValidPacket,
	input sclr
);

reg [3:0] counter = 4'h0;
reg EOP = 0;
always @(posedge clock) begin
	if (sclr) begin
		isIp 				<= 0;
		isARP 				<= 0;
		isNotAValidPacket 	<= 0;
	end else
	if (data_en) begin
		if (~EOP) counter <= counter + 1'b1;
		case (counter)
			12:	begin 
					if (datain[7:0] != 8'h08)
						isNotAValidPacket <= 1; //Если протокол общения не x08?? то пакет сбрасывается
				end
			13:	begin 
					if (datain[7:0] == 8'h00)
						isIp <= 1;				//Если протокол общения x0800 то дальнейшие данные - IP пакет
					else if (datain[7:0] == 8'h06)
						isARP <= 1;				//Если протокол общения x0806 то дальнейшие данные - ARP запрос
					else
						isNotAValidPacket <= 1; //Иначе - пакет сбрасывается
				end
			14: EOP <= 1;
		endcase
	end else begin
		counter 			<= 4'h0;
		EOP 				<= 0;
		isIp 				<= 0;
		isARP 				<= 0;
		isNotAValidPacket 	<= 0;
	end
end

always @(negedge clock) begin
	if (sclr) begin
		mac_wren <= 1;
	end else
	if (counter == 12) begin
		mac_wren <= 0;
	end else
	if (~data_en) begin
		mac_wren <= 1;
	end
end

endmodule
