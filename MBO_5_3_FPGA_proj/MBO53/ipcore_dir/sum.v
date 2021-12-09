////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: P.20131013
//  \   \         Application: netgen
//  /   /         Filename: sum.v
// /___/   /\     Timestamp: Wed Dec 08 16:26:36 2021
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -w -sim -ofmt verilog E:/Xilinx/projects/MBO-5_3/MBO_5_3_FPGA_proj/MBO53/ipcore_dir/tmp/_cg/sum.ngc E:/Xilinx/projects/MBO-5_3/MBO_5_3_FPGA_proj/MBO53/ipcore_dir/tmp/_cg/sum.v 
// Device	: 3s500efg320-5
// Input file	: E:/Xilinx/projects/MBO-5_3/MBO_5_3_FPGA_proj/MBO53/ipcore_dir/tmp/_cg/sum.ngc
// Output file	: E:/Xilinx/projects/MBO-5_3/MBO_5_3_FPGA_proj/MBO53/ipcore_dir/tmp/_cg/sum.v
// # of Modules	: 1
// Design Name	: sum
// Xilinx        : E:\Xilinx\14.7\ISE_DS\ISE\
//             
// Purpose:    
//     This verilog netlist is a verification model and uses simulation 
//     primitives which may not represent the true implementation of the 
//     device, however the netlist is functionally correct and should not 
//     be modified. This file cannot be synthesized and should only be used 
//     with supported simulation tools.
//             
// Reference:  
//     Command Line Tools User Guide, Chapter 23 and Synthesis and Simulation Design Guide, Chapter 6
//             
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/1 ps

module sum (
  c_out, c_in, s, a, b
)/* synthesis syn_black_box syn_noprune=1 */;
  output c_out;
  input c_in;
  output [15 : 0] s;
  input [15 : 0] a;
  input [15 : 0] b;
  
  // synthesis translate_off
  
  wire \blk00000001/sig00000051 ;
  wire \blk00000001/sig00000050 ;
  wire \blk00000001/sig0000004f ;
  wire \blk00000001/sig0000004e ;
  wire \blk00000001/sig0000004d ;
  wire \blk00000001/sig0000004c ;
  wire \blk00000001/sig0000004b ;
  wire \blk00000001/sig0000004a ;
  wire \blk00000001/sig00000049 ;
  wire \blk00000001/sig00000048 ;
  wire \blk00000001/sig00000047 ;
  wire \blk00000001/sig00000046 ;
  wire \blk00000001/sig00000045 ;
  wire \blk00000001/sig00000044 ;
  wire \blk00000001/sig00000043 ;
  wire \blk00000001/sig00000042 ;
  wire \blk00000001/sig00000041 ;
  wire \blk00000001/sig00000040 ;
  wire \blk00000001/sig0000003f ;
  wire \blk00000001/sig0000003e ;
  wire \blk00000001/sig0000003d ;
  wire \blk00000001/sig0000003c ;
  wire \blk00000001/sig0000003b ;
  wire \blk00000001/sig0000003a ;
  wire \blk00000001/sig00000039 ;
  wire \blk00000001/sig00000038 ;
  wire \blk00000001/sig00000037 ;
  wire \blk00000001/sig00000036 ;
  wire \blk00000001/sig00000035 ;
  wire \blk00000001/sig00000034 ;
  wire \blk00000001/sig00000033 ;
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk00000031  (
    .I0(b[0]),
    .I1(a[0]),
    .O(\blk00000001/sig00000042 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk00000030  (
    .I0(b[1]),
    .I1(a[1]),
    .O(\blk00000001/sig00000049 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk0000002f  (
    .I0(b[2]),
    .I1(a[2]),
    .O(\blk00000001/sig0000004a )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk0000002e  (
    .I0(b[3]),
    .I1(a[3]),
    .O(\blk00000001/sig0000004b )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk0000002d  (
    .I0(b[4]),
    .I1(a[4]),
    .O(\blk00000001/sig0000004c )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk0000002c  (
    .I0(b[5]),
    .I1(a[5]),
    .O(\blk00000001/sig0000004d )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk0000002b  (
    .I0(b[6]),
    .I1(a[6]),
    .O(\blk00000001/sig0000004e )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk0000002a  (
    .I0(b[7]),
    .I1(a[7]),
    .O(\blk00000001/sig0000004f )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk00000029  (
    .I0(b[8]),
    .I1(a[8]),
    .O(\blk00000001/sig00000050 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk00000028  (
    .I0(b[9]),
    .I1(a[9]),
    .O(\blk00000001/sig00000051 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk00000027  (
    .I0(b[10]),
    .I1(a[10]),
    .O(\blk00000001/sig00000043 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk00000026  (
    .I0(b[11]),
    .I1(a[11]),
    .O(\blk00000001/sig00000044 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk00000025  (
    .I0(b[12]),
    .I1(a[12]),
    .O(\blk00000001/sig00000045 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk00000024  (
    .I0(b[13]),
    .I1(a[13]),
    .O(\blk00000001/sig00000046 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk00000023  (
    .I0(b[14]),
    .I1(a[14]),
    .O(\blk00000001/sig00000047 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk00000022  (
    .I0(b[15]),
    .I1(a[15]),
    .O(\blk00000001/sig00000048 )
  );
  MUXCY   \blk00000001/blk00000021  (
    .CI(c_in),
    .DI(a[0]),
    .S(\blk00000001/sig00000042 ),
    .O(\blk00000001/sig00000033 )
  );
  XORCY   \blk00000001/blk00000020  (
    .CI(c_in),
    .LI(\blk00000001/sig00000042 ),
    .O(s[0])
  );
  XORCY   \blk00000001/blk0000001f  (
    .CI(\blk00000001/sig00000038 ),
    .LI(\blk00000001/sig00000048 ),
    .O(s[15])
  );
  MUXCY   \blk00000001/blk0000001e  (
    .CI(\blk00000001/sig00000038 ),
    .DI(a[15]),
    .S(\blk00000001/sig00000048 ),
    .O(c_out)
  );
  MUXCY   \blk00000001/blk0000001d  (
    .CI(\blk00000001/sig00000033 ),
    .DI(a[1]),
    .S(\blk00000001/sig00000049 ),
    .O(\blk00000001/sig00000039 )
  );
  XORCY   \blk00000001/blk0000001c  (
    .CI(\blk00000001/sig00000033 ),
    .LI(\blk00000001/sig00000049 ),
    .O(s[1])
  );
  MUXCY   \blk00000001/blk0000001b  (
    .CI(\blk00000001/sig00000039 ),
    .DI(a[2]),
    .S(\blk00000001/sig0000004a ),
    .O(\blk00000001/sig0000003a )
  );
  XORCY   \blk00000001/blk0000001a  (
    .CI(\blk00000001/sig00000039 ),
    .LI(\blk00000001/sig0000004a ),
    .O(s[2])
  );
  MUXCY   \blk00000001/blk00000019  (
    .CI(\blk00000001/sig0000003a ),
    .DI(a[3]),
    .S(\blk00000001/sig0000004b ),
    .O(\blk00000001/sig0000003b )
  );
  XORCY   \blk00000001/blk00000018  (
    .CI(\blk00000001/sig0000003a ),
    .LI(\blk00000001/sig0000004b ),
    .O(s[3])
  );
  MUXCY   \blk00000001/blk00000017  (
    .CI(\blk00000001/sig0000003b ),
    .DI(a[4]),
    .S(\blk00000001/sig0000004c ),
    .O(\blk00000001/sig0000003c )
  );
  XORCY   \blk00000001/blk00000016  (
    .CI(\blk00000001/sig0000003b ),
    .LI(\blk00000001/sig0000004c ),
    .O(s[4])
  );
  MUXCY   \blk00000001/blk00000015  (
    .CI(\blk00000001/sig0000003c ),
    .DI(a[5]),
    .S(\blk00000001/sig0000004d ),
    .O(\blk00000001/sig0000003d )
  );
  XORCY   \blk00000001/blk00000014  (
    .CI(\blk00000001/sig0000003c ),
    .LI(\blk00000001/sig0000004d ),
    .O(s[5])
  );
  MUXCY   \blk00000001/blk00000013  (
    .CI(\blk00000001/sig0000003d ),
    .DI(a[6]),
    .S(\blk00000001/sig0000004e ),
    .O(\blk00000001/sig0000003e )
  );
  XORCY   \blk00000001/blk00000012  (
    .CI(\blk00000001/sig0000003d ),
    .LI(\blk00000001/sig0000004e ),
    .O(s[6])
  );
  MUXCY   \blk00000001/blk00000011  (
    .CI(\blk00000001/sig0000003e ),
    .DI(a[7]),
    .S(\blk00000001/sig0000004f ),
    .O(\blk00000001/sig0000003f )
  );
  XORCY   \blk00000001/blk00000010  (
    .CI(\blk00000001/sig0000003e ),
    .LI(\blk00000001/sig0000004f ),
    .O(s[7])
  );
  MUXCY   \blk00000001/blk0000000f  (
    .CI(\blk00000001/sig0000003f ),
    .DI(a[8]),
    .S(\blk00000001/sig00000050 ),
    .O(\blk00000001/sig00000040 )
  );
  XORCY   \blk00000001/blk0000000e  (
    .CI(\blk00000001/sig0000003f ),
    .LI(\blk00000001/sig00000050 ),
    .O(s[8])
  );
  MUXCY   \blk00000001/blk0000000d  (
    .CI(\blk00000001/sig00000040 ),
    .DI(a[9]),
    .S(\blk00000001/sig00000051 ),
    .O(\blk00000001/sig00000041 )
  );
  XORCY   \blk00000001/blk0000000c  (
    .CI(\blk00000001/sig00000040 ),
    .LI(\blk00000001/sig00000051 ),
    .O(s[9])
  );
  MUXCY   \blk00000001/blk0000000b  (
    .CI(\blk00000001/sig00000041 ),
    .DI(a[10]),
    .S(\blk00000001/sig00000043 ),
    .O(\blk00000001/sig00000034 )
  );
  XORCY   \blk00000001/blk0000000a  (
    .CI(\blk00000001/sig00000041 ),
    .LI(\blk00000001/sig00000043 ),
    .O(s[10])
  );
  MUXCY   \blk00000001/blk00000009  (
    .CI(\blk00000001/sig00000034 ),
    .DI(a[11]),
    .S(\blk00000001/sig00000044 ),
    .O(\blk00000001/sig00000035 )
  );
  XORCY   \blk00000001/blk00000008  (
    .CI(\blk00000001/sig00000034 ),
    .LI(\blk00000001/sig00000044 ),
    .O(s[11])
  );
  MUXCY   \blk00000001/blk00000007  (
    .CI(\blk00000001/sig00000035 ),
    .DI(a[12]),
    .S(\blk00000001/sig00000045 ),
    .O(\blk00000001/sig00000036 )
  );
  XORCY   \blk00000001/blk00000006  (
    .CI(\blk00000001/sig00000035 ),
    .LI(\blk00000001/sig00000045 ),
    .O(s[12])
  );
  MUXCY   \blk00000001/blk00000005  (
    .CI(\blk00000001/sig00000036 ),
    .DI(a[13]),
    .S(\blk00000001/sig00000046 ),
    .O(\blk00000001/sig00000037 )
  );
  XORCY   \blk00000001/blk00000004  (
    .CI(\blk00000001/sig00000036 ),
    .LI(\blk00000001/sig00000046 ),
    .O(s[13])
  );
  MUXCY   \blk00000001/blk00000003  (
    .CI(\blk00000001/sig00000037 ),
    .DI(a[14]),
    .S(\blk00000001/sig00000047 ),
    .O(\blk00000001/sig00000038 )
  );
  XORCY   \blk00000001/blk00000002  (
    .CI(\blk00000001/sig00000037 ),
    .LI(\blk00000001/sig00000047 ),
    .O(s[14])
  );

// synthesis translate_on

endmodule

// synthesis translate_off

`ifndef GLBL
`define GLBL

`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;

    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule

`endif

// synthesis translate_on
