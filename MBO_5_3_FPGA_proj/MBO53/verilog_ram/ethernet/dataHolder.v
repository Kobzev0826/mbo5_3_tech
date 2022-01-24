module dataHolder(
	input [31:0] VERIFIED_IP,	//установленный (константой или согласно DHCP-протокола) IP нашего устройства
	input [47:0] VERIFIED_MAC,	//установленный MAC нашего устройства
	input is_ip_verified,		//строб установки IP
	input is_mac_verified,		//строб установки MAC
	input [47:0] input_BOARD_MAC,	//входящие данные о MAC		того, к кому обращаются
	input [31:0] input_BOARD_IP,    //входящие данные о	IP		того, к кому обращаются
	input [15:0] input_BOARD_PORT,  //входящие данные о	PORT	того, к кому обращаются
	input [47:0] input_PC_MAC,      //входящие данные о	MAC		того, кто обращается
	input [31:0] input_PC_IP,       //входящие данные о	IP		того, кто обращается
	input [15:0] input_PC_PORT,     //входящие данные о	PORT	того, кто обращается
	input input_mac_verified,		//строб сопровождения входящих данных о MAC
	input input_ip_verified,		//строб сопровождения входящих данных о IP
	input input_port_verified,		//строб сопровождения входящих данных о PORT
	input input_in_process,			//строб сопровождения обработки входящих данных
	input aclr,
	input clock,
	
	output reg [47:0] BOARD_MAC,	//установленно верные данные о текущем соединении
	output reg [31:0] BOARD_IP,     //установленно верные данные о текущем соединении
	output reg [15:0] BOARD_PORT,   //установленно верные данные о текущем соединении
	output reg [47:0] PC_MAC,       //установленно верные данные о текущем соединении
	output reg [31:0] PC_IP,        //установленно верные данные о текущем соединении
	output reg [15:0] PC_PORT,      //установленно верные данные о текущем соединении
	output isNotAValidPacket
);

reg input_in_process_ft;
reg input_mac_verified_ft;
reg input_ip_verified_ft;
reg input_port_verified_ft;

reg input_in_process_negedge;

always @(posedge clock) begin
	input_in_process_ft <= input_in_process;
	input_mac_verified_ft <= input_mac_verified;
	input_ip_verified_ft <= input_ip_verified;
	input_port_verified_ft <= input_port_verified;
	input_in_process_negedge <= input_in_process_ft & ~input_in_process;
end

always @(posedge clock, posedge aclr) begin
	if (aclr) begin
		BOARD_MAC	<=	{48{1'b1}}; //по умолчанию любые данные о соединении должны содержать макрос широковещательного обращения, т.е. 0xFF...FF 
		BOARD_IP	<=	{32{1'b1}};
		BOARD_PORT	<=	{16{1'b1}};
		PC_MAC		<=	{48{1'b1}};
		//PC_IP		<=	{32{1'b1}};
		PC_IP <= {8'd192, 8'd168, 8'd0, 8'd1};
		PC_PORT		<=	{16{1'b1}};
	end else begin
		if (is_ip_verified) begin
			BOARD_IP <= VERIFIED_IP;
		end
		if (is_mac_verified) begin
			BOARD_MAC <= VERIFIED_MAC;
		end
		if (input_in_process_negedge) begin
			if (input_mac_verified_ft && (PC_MAC == {48{1'b1}})) begin
				PC_MAC <= input_PC_MAC;
			end
			//if (input_ip_verified_ft && (PC_IP == {32{1'b1}})) begin
			//	PC_IP <= input_PC_IP;
			//end
			PC_IP <= {8'd192, 8'd168, 8'd0, 8'd1};
			if (input_port_verified_ft) begin
				if (BOARD_PORT == {16{1'b1}}) begin
					BOARD_PORT <= input_BOARD_PORT;
				end
				if (PC_PORT == {16{1'b1}}) begin
					PC_PORT <= input_PC_PORT;
				end
			end
		end
	end
end

wire b_mac_v, b_ip_v, b_port_v, p_mac_v, p_ip_v, p_port_v;
wire mac_v, ip_v, port_v;
wire mac_check, ip_check, port_check;

assign b_mac_v = (BOARD_MAC == input_BOARD_MAC) | (BOARD_MAC == {48{1'b1}});
assign b_ip_v = (BOARD_IP == input_BOARD_IP) | (BOARD_IP == {32{1'b1}});
assign b_port_v = (BOARD_PORT == input_BOARD_PORT) | (BOARD_PORT == {16{1'b1}});

assign p_mac_v = (PC_MAC == input_PC_MAC) | (PC_MAC == {48{1'b1}});
assign p_ip_v = (PC_IP == input_PC_IP) | (PC_IP == {32{1'b1}});
assign p_port_v = (PC_PORT == input_PC_PORT) | (PC_PORT == {16{1'b1}});

assign mac_v = p_mac_v | b_mac_v;
assign ip_v = p_ip_v | b_ip_v;
assign port_v = p_port_v | b_port_v;

assign mac_check = input_in_process_negedge | input_mac_verified;
assign ip_check = input_in_process_negedge | input_ip_verified;
assign port_check = input_in_process_negedge | input_port_verified;

assign isNotAValidPacket = (mac_check & ~mac_v) |
(ip_check & ~ip_v) |
(port_check & ~port_v);

endmodule
