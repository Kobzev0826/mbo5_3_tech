module mdio_control_100(

input clock,
input reset,
input start,
input read,

input mdio_rx,
output reg mdio_en ,
output e_mdio,
output reg [15:0] Data_reg
);
(*mark_debug="yes"*)reg enet_mdio;
assign e_mdio = enet_mdio;
//--------------------управление MDIO интерфейсом ------------------------------------
localparam 	mdio_controlreg_rst 	= 0,	// 0-Normal 1-Reset
			mdio_controlreg_LB 		= 0,	// 0-Normal 1-Enable - closes the loop-back from TX to RX at xMII
			mdio_controlreg_SSL		= 1,	// выбор скорости 0-10 1-100 2-1000 3-Reserved; работает в сочетании с SSM, доступно только при ANEN=0
			mdio_controlreg_SSM 	= 0,
			mdio_controlreg_ANEN	= 1,	// 0-Disable 1-Enable Auto-Negotation Enable
			mdio_controlreg_PD		= 0, 	// 0-Normal 1-PowerDown
			mdio_controlreg_ISOL	= 0,	// 0-Normal 1-Isolate
			mdio_controlreg_ANRS	= 1,	// 0-stay in current mode 1-restart auto-negotation
			mdio_controlreg_DPLX	= 1,	// 0-Half duplex 1-Full duplex; доступен только при ANEN=0
			mdio_controlreg_COL		= 0,	//0-Normal operational mode 1-Enable Actives the collision test
			mdio_controlreg_RES		= 0;	// Write as zero, ignore on read 

reg [4:0] PHY_addr =5'd1;
reg [4:0] REG_control_addr = 5'd0;

reg [6:0] counter_mdio;

integer i;

reg start_strob, start_st, start_previous;
reg read_strob, read_st, read_previous;

reg command_strob, command_strob_st;

always @(posedge clock)
begin
	read_previous <= read;
	read_st <= read & (!read_previous);//ловим фронт read
	if (read_st) read_strob <= 1;
	
	start_previous <= start;
	start_st <= start & (!start_previous);//ловим фронт start
	if (start_st) start_strob <=1;
//end


//always @(posedge clock)
//begin

	if (start_strob)
		begin
			if (~reset) counter_mdio<=0;
			else counter_mdio <= counter_mdio + 1;
			
			case (counter_mdio)
				00:	enet_mdio <= 1'bz ;
				01: enet_mdio <= 1'bz ;
				
				02: begin enet_mdio <= 1'b1 ;  end
				03: enet_mdio <= 1'b1 ;
				
				04: enet_mdio <= 1'b0 ;
				05: enet_mdio <= 1'b1 ;
				
				06: enet_mdio <= 1'b0 ;
				07: enet_mdio <= 1'b1 ;
				
				08: enet_mdio <= PHY_addr[4];
				09: enet_mdio <= PHY_addr[3];
				10: enet_mdio <= PHY_addr[2];
				11: enet_mdio <= PHY_addr[1];
				12: enet_mdio <= PHY_addr[0];
				
				13: enet_mdio <= REG_control_addr[4];
				14: enet_mdio <= REG_control_addr[3];
				15: enet_mdio <= REG_control_addr[2];
				16: enet_mdio <= REG_control_addr[1];
				17: enet_mdio <= REG_control_addr[0];
				
				18: enet_mdio <= 1'bz;
				19: enet_mdio <= 1'bz;
				
				20: begin enet_mdio <= mdio_controlreg_rst 	; command_strob<=1; end
				21: enet_mdio <= mdio_controlreg_LB 	;
				22: enet_mdio <= mdio_controlreg_SSL	;
				23: enet_mdio <= mdio_controlreg_ANEN	; 
				24: enet_mdio <= mdio_controlreg_PD		;
				25: enet_mdio <= mdio_controlreg_ISOL	;
				26: enet_mdio <= mdio_controlreg_ANRS	;
				27: enet_mdio <= mdio_controlreg_DPLX	;
				28: enet_mdio <= mdio_controlreg_COL	;
				29: enet_mdio <= mdio_controlreg_SSM	;
				30: enet_mdio <= mdio_controlreg_RES	;
				/*31: enet_mdio <= mdio_controlreg_RES	;
				32: enet_mdio <= mdio_controlreg_RES	;
				33: enet_mdio <= mdio_controlreg_RES	;
				34: enet_mdio <= mdio_controlreg_RES	;
				*/
				35: command_strob<=0;
				
				36: enet_mdio <= 1'bz;
				37: begin enet_mdio <= 1'bz; start_strob<=0; counter_mdio<=0; end
				
			endcase
		end
	

	if (read_strob )
		begin

			if (~reset) counter_mdio<=0;
			else counter_mdio <= counter_mdio + 1;
			
			case (counter_mdio)
				00:	enet_mdio <= 1'bz ;
				01: enet_mdio <= 1'bz ;
				
				02: begin enet_mdio <= 1'b1 ; mdio_en <=1'b1; end
				03: enet_mdio <= 1'b1 ;
				
				30 + 04: enet_mdio <= 1'b0 ;
				30 +05: enet_mdio <= 1'b1 ;
				
				30 +06: enet_mdio <= 1'b1 ;
				30 +07: enet_mdio <= 1'b0 ;
				
				30 +08: enet_mdio <= PHY_addr[4];
				30 +09: enet_mdio <= PHY_addr[3];
				30 +10: enet_mdio <= PHY_addr[2];
				30 +11: enet_mdio <= PHY_addr[1];
				30 +12: enet_mdio <= PHY_addr[0];
				
				30 +13: enet_mdio <= REG_control_addr[4];
				30 +14: enet_mdio <= REG_control_addr[3];
				30 +15: enet_mdio <= REG_control_addr[2];
				30 +16: enet_mdio <= REG_control_addr[1];
				30 +17: begin enet_mdio <= REG_control_addr[0];  end
				
				30 +18: begin enet_mdio <= 1'bz; mdio_en <=1'b0; end//1'b1;
				30 +19: enet_mdio <= 1'bz;//1'b0;
				
				30 +20: begin enet_mdio <= 1'bz; command_strob <=1; mdio_en <=1'b0; end
				30 +35: command_strob<=0;
				30 +37: begin enet_mdio <= 1'bz; read_strob <=0; counter_mdio<=0; mdio_en <=1'b0;end
			endcase
		end
	command_strob_st<=command_strob;
	if (command_strob_st)
		begin
			Data_reg [0] <= mdio_rx;
			for (i=1; i<16; i=i+1) Data_reg[i] <= Data_reg[i-1];
		end
end



endmodule