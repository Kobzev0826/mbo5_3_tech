module ourDataTypeOne (
	input [7:0] datain,
	input clock,
	input ena,
	input sclr,
	output reg wren,
	output reg [15:0] data,
	output wire [991:0] o_header,//[31:0] o_header [30:0],
	output reg header_ena
);

reg [31:00] header[30:0];

reg [9:0] counter;
reg EOP;
integer i;
reg state;

genvar j;
generate
	for (j = 0; j < 31; j = j + 1) begin
		assign o_header[991 - (32*j) : 991 - 31 - (32*j)] = header[j];
	end
endgenerate

always @(posedge clock) begin
	if (sclr) begin
		wren <= 0;
		data <= 0;
		for (i = 0; i < 31; i = i + 1) begin
			header[i]<=0;
		end
		counter <= 0;
		EOP <= 0;
		state <= 0;
		header_ena <= 0;
	end else if (ena) begin
		if (~EOP) counter <= counter + 1'b1;
		for (i = 0; i < 31; i = i + 1) begin
			case (counter)
				(4*i)		:	header[i][31:24] 	<= datain;
				(4*i) + 1	:	header[i][23:16] 	<= datain;
				(4*i) + 2	:	header[i][15:8] 	<= datain;
				(4*i) + 3	:	header[i][7:0] 		<= datain;
			endcase
		end
		if (counter == 124) header_ena <= 1;
		if ((counter > 123) && (counter < 524)) begin
			state <= ~state;
			case (state)
				0:	begin
						data[15:8]	<= datain;
						wren <= 0;
					end
				1:	begin 
						data[7:0] 	<= datain;
						wren <= 1;
					end
			endcase
		end
		if (counter == 524) EOP <= 1;
	end else begin
		wren <= 0;
		counter <= 0;
		EOP <= 0;
		state <= 0;
		header_ena <= 0;
	end
end

endmodule