module arp_parser(
	input clock, 
	input data_en, //входящая информация ЯВЛЯЕТСЯ ARP-запросом
	input sclr,
	input [7:0] data, //входящая информация
	output reg ip_wren,
	output reg ip_wren2
);

reg [4:0] counter;

always @(posedge clock) begin
	if (sclr) begin
		counter 	<= 0;
	end else begin
	
		if (data_en)
			counter <= counter + 1'b1;
		else begin
			counter <= 0;
		end
	end
end

always @(negedge clock) begin
	if (sclr) begin
		ip_wren <= 0;
		ip_wren2 <= 0;
	end else begin
		case (counter)
			14: ip_wren <= 1;
			18: ip_wren <= 0;
			24: ip_wren2 <= 1;
			28: ip_wren2 <= 0;
		endcase
	end
end

endmodule
