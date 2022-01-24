module udpHeader(
	input clock,
	input [7:0] datain,		//входящая информация
	input data_en,			//является UDP-датаграммой
	output reg dataen,		//строб сопровождения содержимого UDP-датаграммы
	output reg port_wren,
	input sclr
);

reg EOP = 0;
reg [4:0] counter = 0;

always @(posedge clock) begin
	if (sclr) begin
			dataen 	<= 0;
			counter <= 0;
			EOP 	<= 0;
	end else begin
	if(data_en)begin
		case(counter)
			7:dataen	<= 1;
			8:EOP		<= 1;
		endcase
		if(~EOP) counter <= counter + 1'b1;
	end else begin
		dataen 	<= 0;
		counter <= 0;
		EOP 	<= 0;
	end
	end
end

always @(negedge clock) begin
	if (sclr) begin
		port_wren <= 1;
	end else
	if (counter == 4) begin
		port_wren <= 0;
	end else
	if (!data_en) begin
		port_wren <= 1;
	end
end
	
endmodule


	


