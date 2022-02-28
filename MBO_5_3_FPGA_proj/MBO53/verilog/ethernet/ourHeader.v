module ourHeader (
	input [7:0] datain, //входящая информация
	input clock,		
	input ena,			//входящая информация является направленным нам пакетом
	input sclr,
	output reg is_type_1,	//строб сопровождения информации являющейся пакетом типа ONE
	output reg is_type_2,	//строб сопровождения информации являющейся пакетом типа TWO
	output reg is_type_2_2,
	output reg is_start_signal,
	output reg is_sync_signal,
	output reg is_stop_signal
);

reg [31:0] flag_type;
reg [2:0] counter;
reg EOP;

always @(posedge clock) begin
	if (sclr) begin
		is_type_1 <= 0;
		is_type_2 <= 0;
		is_type_2_2 <= 0;
		is_start_signal <= 0;
		is_sync_signal <= 0;
		is_stop_signal <= 0;
		flag_type <= 0;
		counter <= 0;
		EOP <= 0;
	end else if (ena) begin
		if (~EOP) counter <= counter + 1'b1;
		case (counter)
			0: 	begin 
					flag_type[31:24] <= datain[7:0];
				end
			1: 	begin
					flag_type[23:16] <= datain[7:0];
				end
			2: 	begin
					flag_type[15:8]  <= datain[7:0];
				end
			3: 	begin
					flag_type[7:0]   <= datain[7:0];
						case (datain[7:0])
							8'h00: is_type_1 <= 1;
							8'h01: is_type_2 <= 1;
							8'h02: is_type_2_2 <= 1;
							8'h30: is_start_signal <= 1;
							8'h31: is_stop_signal <= 1;
							8'hC0: is_sync_signal <= 1;
						endcase
				end
			4: 	EOP <= 1;
		endcase
	end else begin
		is_type_1 <= 0;
		is_type_2 <= 0;
		is_type_2_2 <= 0;
		is_start_signal <= 0;
		is_sync_signal <= 0;
		is_stop_signal <= 0;
		flag_type <= 0;
		counter <= 0;
		EOP <= 0;
	end
end

endmodule
